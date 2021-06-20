extends Node

class_name CardManager

var deck_type = UnoDeck.new()

var hands = {}
var deck_store = CardPile.new()
var discard_store = CardPile.new()

var discard_group = []

const DECK_ID = -1
const DISCARD_ID = -2

func prepare(player_ids: Array):
	for id in player_ids:
		hands[id] = CardHand.new()
		if OnlineMatch.is_network_server() and id != OnlineMatch.get_network_unique_id():
			_sync_cards(hands[id], id, id)

func setup_cards(player_ids: Array, deal_count: int):
	if OnlineMatch.is_network_server():
		_sync_count(DECK_ID)
		deck_store.populate(deck_type.init_deck())
		deck_store.shuffle()
	
		var count = 0
		while not _is_hands_full(deal_count) and deck_store.count() > 0:
			var idx = count % player_ids.size()
			var id = player_ids[idx]
			hands[id].add_card(deck_store.draw())
			count += 1

func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.count() != max_cards:
			return false
	
	return true


func _get_custom_rpc_methods() -> Array:
	return [
		'_card_removed',
		'_card_added',
		'_store_count',
	]

func _sync_count(id):
	var store = _get_store_by_id(id)
	store.connect("changed", self, "_send_count", [id])
	
func _send_count(id):
	var store = _get_store_by_id(id)
	OnlineMatch.custom_rpc_sync(self, "_store_count", [id, store.cards().size()])

func _store_count(id: int, count: int):
	var store = _get_store_by_id(id)
	if OnlineMatch.is_network_server() or count == store.cards().size(): return
	
	var dummy_cards = []
	for i in range(0, count):
		dummy_cards.append(deck_type.dummy_card())
	
	store.populate(dummy_cards)

func _sync_cards(store, id = null, store_id = null):
	store.connect("card_added", self, "_card_add", [id, store_id])
	store.connect("card_removed", self, "_card_remove", [id, store_id])
	
func _card_add(ref, id, store_id) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_added", [ref, store_id])
	else:
		OnlineMatch.custom_rpc(self, "_card_added", [ref, store_id])

func _card_added(ref, store_id) -> void:
	var store = _get_store_by_id(store_id)
	store.add_card(deck_type.create_from_ref(ref))

func _card_remove(ref, id, store_id) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_removed", [ref, store_id])
	else:
		OnlineMatch.custom_rpc(self, "_card_removed", [ref, store_id])
	
func _card_removed(ref, store_id) -> void:
	var store = _get_store_by_id(store_id)
	store.remove_card(ref)

func _get_store_by_id(id: int) -> AbstractStore:
	if id == DECK_ID: return deck_store
	if id == DISCARD_ID: return discard_store
	return hands[id]

func player_cards(id: int, refs: Array) -> Array:
	if hands.has(id):
		return hands[id].get_cards(refs)
	return []

func player_draw(id: int, amount = 1) -> void:
	if hands.has(id):
		for i in range(0, amount):
			hands[id].add_card(draw_card())

func player_discard(id: int, refs: Array) -> void:
	if hands.has(id):
		hands[id].play_cards(refs, discard_store)

func player_pickup(id: int) -> void:
	if hands.has(id):
		var refs = []
		for c in last_played_cards():
			refs.append(c.ref())
		discard_group.pop_back()
		discard_store.move_cards(refs, hands[id])

func last_played_cards() -> Array:
	if discard_group.size() == 0: return []
	return discard_store.most_recent_cards(discard_group[discard_group.size() - 1])
		
func draw_card() -> Card:
	return deck_store.draw()

func discard_cards(cards: Array) -> void:
	discard_store.add_cards(cards)
	discard_group.append(cards.size())

func peek_deck(offset = 0) -> Card:
	var deck = deck_store.cards()
	return deck[(deck.size() - 1) - offset]
		
