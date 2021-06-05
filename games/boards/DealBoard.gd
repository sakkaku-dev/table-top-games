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
		'_set_hand'
	]
	

func setup_client() -> void:
	hand_node.card_visual = deck_type.get_ui()
	discard_node.card_visual = deck_type.get_ui()

func setup_server(players: Dictionary) -> void:
	deck = deck_type.init_deck()
	deck.shuffle()
	
	hands = {}
	
	var player_ids = players.keys()
	for id in players:
		hands[id] = []
	
	var count = 0
	while not _is_hands_full(config.deal_cards) and deck.size() > 0:
		var idx = count % player_ids.size()
		var id = player_ids[idx]
		hands[id].append(deck.pop_front())
		count += 1
	
	discard_store.populate(deck)
	
	for id in hands:
		var hand = hands[id]
		OnlineMatch.custom_rpc_id(self, id, "_set_hand", [hand])


func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.size() != max_cards:
			return false
	
	return true


func _set_hand(cards: Array) -> void:
	hand_store.populate(cards)
