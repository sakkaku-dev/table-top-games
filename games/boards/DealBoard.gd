extends Board

var deck = []
var deck_type = PokerDeck.new()

var hands = {}

var hand = []

export var config: Resource = load("res://games/boards/DealAll.tres")

func _get_custom_rpc_methods() -> Array:
	return [
		'_set_hand'
	]

func setup_board(players: Dictionary) -> void:
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
	
	for id in hands:
		var hand = hands[id]
		if OnlineMatch.get_network_unique_id() == id:
			_set_hand(hand)
		else:
			# TODO: cannot send cards, convert to json?
			OnlineMatch.custom_rpc_id(self, id, "_set_hand", [hand])


func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.size() != max_cards:
			return false
	
	return true


func _set_hand(cards: Array) -> void:
	hand = cards
	print(hand)
