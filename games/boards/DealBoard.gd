extends Board

var deck_type = PokerDeck.new()

var hands = {}

var deck_store = CardPile.new()
var hand_store = CardHand.new()
var discard_store = CardPile.new()

onready var hand_node := $Hand
onready var discard_node := $DiscardPile
onready var deck_node := $DeckPile

export var config: Resource = load("res://games/boards/DealAll.tres")


func _ready():
	hand_node.set_store(hand_store)
	discard_node.set_store(discard_store)
	deck_node.set_store(deck_store)
	
	hand_node.set_board(self)
	discard_node.set_board(self)
	deck_node.set_board(self)


func _get_custom_rpc_methods() -> Array:
	return [
		'_play_card_from_player',
		'_card_removed',
		'_card_added',
		'_deck_count',
		'_draw_card',
	]
	

func setup_client() -> void:
	hand_node.card_visual = deck_type.get_ui()
	discard_node.card_visual = deck_type.get_ui()
	deck_node.card_visual = deck_type.get_ui()
	deck_store.add_card(deck_type.dummy_card())

func setup_server(players: Dictionary) -> void:
	deck_store.populate(deck_type.init_deck())
	deck_store.shuffle()
	
	hands = {}

	sync_cards(discard_store)
	
	var player_ids = players.keys()
	for id in players:
		var card_hand = CardHand.new()
		sync_cards(card_hand, id, "hand")
		hands[id] = card_hand
	
	var count = 0
	while not _is_hands_full(config.deal_cards) and deck_store.count() > 0:
		var idx = count % player_ids.size()
		var id = player_ids[idx]
		hands[id].add_card(deck_store.draw())
		count += 1
	
	deck_store.connect("changed", self, "_sync_deck_count")
	_sync_deck_count()

func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.count() != max_cards:
			return false
	
	return true


func _sync_deck_count():
	OnlineMatch.custom_rpc_sync(self, "_deck_count", [deck_store.count()])


func _deck_count(count: int):
	if count == 0:
		deck_node.hide()
	else:
		deck_node.show()


func sync_cards(store, id = null, store_id = null):
	store.connect("card_added", self, "_card_add", [id, store_id])
	store.connect("card_removed", self, "_card_remove", [id, store_id])
	
func _card_add(ref, id, store_id) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_added", [ref, store_id])
	else:
		OnlineMatch.custom_rpc(self, "_card_added", [ref, store_id])

func _card_added(ref, store_id) -> void:
	var store = hand_store if store_id == "hand" else discard_store
	store.add_card(deck_type.create_from_ref(ref))

func _card_remove(ref, id, store_id) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_removed", [ref, store_id])
	else:
		OnlineMatch.custom_rpc(self, "_card_removed", [ref, store_id])
	
func _card_removed(ref, store_id) -> void:
	var store = hand_store if store_id == "hand" else discard_store
	store.remove_card(ref)


func play_card(card: Card) -> void:
	OnlineMatch.custom_rpc_id(self, 1, "_play_card_from_player", [OnlineMatch.get_network_unique_id(), card.ref()])

func _play_card_from_player(id, ref) -> void:
	if hands.has(id):
		hands[id].play_card(ref, discard_store)

func draw_card(dummy_card) -> void:
	OnlineMatch.custom_rpc_id(self, 1, "_draw_card", [OnlineMatch.get_network_unique_id()])

func _draw_card(id) -> void:
	if hands.has(id):
		hands[id].add_card(deck_store.draw())
