extends Board

onready var hand_node := $Hand
onready var discard_node := $DiscardPile
onready var deck_node := $DeckPile
onready var card_manager := $CardManager

export var deal_count = 5

const ACTIVE_TURN_OFFSET = 40

var player_ids = []
var turn = -1
var hands = {}

var deck_type = UnoDeck.new()
var player_turn = false

func prepare(players: Dictionary) -> void:
	hand_node.deck = deck_type
	discard_node.deck = deck_type
	deck_node.deck = deck_type

	card_manager.deck_type = deck_type
	card_manager.prepare(players.keys())

	hand_node.store = card_manager.hands[OnlineMatch.get_network_unique_id()]
	discard_node.store = card_manager.discard_store
	deck_node.store = card_manager.deck_store
	
	player_turn = false


func setup(players: Dictionary) -> void:
	if OnlineMatch.is_network_server():
		card_manager.setup_cards(players.keys(), 7)
		player_ids = players.keys()
		_next_turn()


func _is_hands_full(max_cards: int) -> bool:
	if max_cards == -1: return false
	
	for id in hands:
		var hand = hands[id]
		if hand.count() != max_cards:
			return false
	
	return true


func _get_custom_rpc_methods() -> Array:
	return [
		'_play_cards_from_player',
		'_card_removed',
		'_card_added',
		'_deck_count',
		'_draw_card',
		'_set_player_turn',
		'_pick_up_discarded',
		'_end_turn',
	]


func _deck_count(count: int):
	if count == 0:
		deck_node.hide()
	else:
		deck_node.show()


func _current_player_id_turn() -> int:
	return player_ids[turn % player_ids.size()]

func _next_turn():
	turn += 1
	var id = _current_player_id_turn()
	OnlineMatch.custom_rpc_sync(self, "_set_player_turn", [id])

func _set_player_turn(player_id: int) -> void:
	if player_turn:
		hand_node.rect_position.y += ACTIVE_TURN_OFFSET
	
	player_turn = OnlineMatch.get_network_unique_id() == player_id
	_update_interactive()
	
	if player_turn:
		hand_node.rect_position.y -= ACTIVE_TURN_OFFSET
	

func _update_interactive():
	hand_node.set_interactive(player_turn)
	deck_node.set_interactive(player_turn)


func draw_card(dummy_card) -> void:
	if player_turn:
		OnlineMatch.custom_rpc_id(self, 1, "_draw_card", [OnlineMatch.get_network_unique_id()])

func _draw_card(id) -> void:
	if _current_player_id_turn() == id:
		card_manager.player_draw(id)


func _on_Hand_cards_played(cards):
	if not player_turn: return
	var refs = []
	for card in cards:
		refs.append(card.ref())
	OnlineMatch.custom_rpc_id(self, 1, "_play_cards_from_player", [OnlineMatch.get_network_unique_id(), refs])

func _play_cards_from_player(id, refs) -> void:
	if _current_player_id_turn() == id:
		card_manager.player_discard(id ,refs)


func _on_DiscardPile_clicked():
	if player_turn:
		OnlineMatch.custom_rpc_id(self, 1, "_pick_up_discarded", [OnlineMatch.get_network_unique_id()])
		
func _pick_up_discarded(id):
	if _current_player_id_turn() == id:
		card_manager.player_pickup(id)


func _on_DeckPile_card_hold(card):
	if player_turn:
		OnlineMatch.custom_rpc_id(self, 1, "_end_turn", [OnlineMatch.get_network_unique_id()])

func _end_turn(id):
	if _current_player_id_turn() == id:
		_next_turn()
