extends Board

var deck = []
var deck_type = PokerDeck.new()

var hands = {}

var hand_store = CardHand.new()
var discard_store = CardPile.new()

onready var hand_node = $Hand
onready var discard_node = $DiscardPile

export var config: Resource = load("res://games/boards/DealAll.tres")


func _ready():
	hand_node.set_store(hand_store)
	discard_node.set_store(discard_store)


func _get_custom_rpc_methods() -> Array:
	return [
		'_play_card_from_player',
		'_card_removed',
		'_card_added',
	]
	

func setup_client() -> void:
	hand_node.card_visual = deck_type.get_ui()
	discard_node.card_visual = deck_type.get_ui()

func setup_server(players: Dictionary) -> void:
	deck = deck_type.init_deck()
	deck.shuffle()
	
	hands = {}

	discard_store.connect("card_removed", self, "_card_remove", [null, null])
	discard_store.connect("card_added", self, "_card_add", [null, null])
	
	var player_ids = players.keys()
	for id in players:
		var card_hand = CardHand.new()
		card_hand.connect("card_removed", self, "_card_remove", [id, "hand"])
		card_hand.connect("card_added", self, "_card_add", [id, "hand"])
		hands[id] = card_hand
	
	var count = 0
	while not _is_hands_full(config.deal_cards) and deck.size() > 0:
		var idx = count % player_ids.size()
		var id = player_ids[idx]
		hands[id].add_card(deck.pop_front())
		count += 1

func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.count() != max_cards:
			return false
	
	return true

func _card_add(ref, id, store) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_added", [ref, store])
	else:
		OnlineMatch.custom_rpc(self, "_card_added", [ref, store])

func _card_added(ref, store_id) -> void:
	var store = hand_store if store_id == "hand" else discard_store
	store.add_card(deck_type.create_from_ref(ref))

func _card_remove(ref, id, store) -> void:
	if id:
		OnlineMatch.custom_rpc_id(self, id, "_card_removed", [ref, store])
	else:
		OnlineMatch.custom_rpc(self, "_card_removed", [ref, store])
	
func _card_removed(ref, store_id) -> void:
	var store = hand_store if store_id == "hand" else discard_store
	store.remove_card(ref)

func play_card(card: Card) -> void:
	OnlineMatch.custom_rpc_id(self, 1, "_play_card_from_player", [OnlineMatch.get_network_unique_id(), card.ref()])

func _play_card_from_player(id, ref) -> void:
	if hands.has(id):
		hands[id].play_card(ref, discard_store)
