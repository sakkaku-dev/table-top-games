extends Board

class_name CardBoard

onready var hand_node := $Hand
onready var discard_node := $DiscardPile
onready var deck_node := $DeckPile
onready var card_manager := $CardManager

const ACTIVE_TURN_OFFSET = 40

var player_ids = []
var turn = -1
var reverse_turn = false

var deck_type = UnoDeck.new()
var rule = load("res://games/decks/uno/UnoRule.gd").new()

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
	rule.setup(self, players.keys())
	
	if OnlineMatch.is_network_server():
		player_ids = players.keys()
		next_turn()


func set_playable_cards(count: int) -> void:
	hand_node.max_active_cards = count


func _get_custom_rpc_methods() -> Array:
	return [
		'_play_cards_from_player',
		'_draw_card',
		'_set_player_turn',
		'_pick_up_discarded',
		'_end_turn',
	]

func reverse_player_turn() -> void:
	reverse_turn = not reverse_turn

func player_id_of_turn(offset = 0) -> int:
	return player_ids[_continue_turn(turn, offset) % player_ids.size()]

func next_turn(turns = 1):
	turn = _continue_turn(turn, turns)
	var id = player_id_of_turn()
	OnlineMatch.custom_rpc_sync(self, "_set_player_turn", [id])

func _continue_turn(turn: int, offset: int) -> int:
	if reverse_turn:
		return turn - offset
	else:
		return turn + offset

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
	if player_id_of_turn() == id:
		card_manager.player_draw(id)


func _on_Hand_cards_played(cards):
	if not player_turn: return
	var refs = []
	for card in cards:
		refs.append(card.ref())
	OnlineMatch.custom_rpc_id(self, 1, "_play_cards_from_player", [OnlineMatch.get_network_unique_id(), refs])

func _play_cards_from_player(id, refs) -> void:
	if player_id_of_turn() == id:
		rule.play_cards(id, refs)


func _on_DiscardPile_clicked():
	if player_turn:
		OnlineMatch.custom_rpc_id(self, 1, "_pick_up_discarded", [OnlineMatch.get_network_unique_id()])
		
func _pick_up_discarded(id):
	if player_id_of_turn() == id:
		card_manager.player_pickup(id)


func _on_DeckPile_card_hold(card):
	if player_turn:
		OnlineMatch.custom_rpc_id(self, 1, "_end_turn", [OnlineMatch.get_network_unique_id()])

func _end_turn(id):
	if player_id_of_turn() == id:
		next_turn()
