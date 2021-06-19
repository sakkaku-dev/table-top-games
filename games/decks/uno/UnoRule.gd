extends CardRule

class_name UnoRule

var card_board: CardBoard
var card_manager: CardManager

var color_select = preload("res://games/decks/uno/UnoColorSelect.tscn")

func setup(board: CardBoard, players: Array):
	card_board = board
	card_manager = board.card_manager
	card_board.set_playable_cards(1)

	if OnlineMatch.is_network_server():
		card_manager.setup_cards(players, 7)
		var card: UnoCard = null
		
		var offset = 0
		while card == null or card.is_special_card():
			card = card_manager.peek_deck(offset)
			offset += 1
		
		card_manager.discard_cards([card])

func end_turn(id: int) -> void:
	pass

func pickup_discarded(id: int) -> void:
	pass

func draw_card(id: int) -> void:
	card_manager.player_draw(id)
	card_board.next_turn()

func play_cards(id: int, refs: Array) -> void:
	var cards = card_manager.player_cards(id, refs)
	if cards.size() != 1:
		print("Only one card can be played: " + str(cards.size()))
		return
		
	if _can_play_card(cards[0]):
		card_manager.player_discard(id, refs)
		_handle_played_card(cards[0])
	else:
		print("Cannot play card")

func _can_play_card(card: UnoCard) -> bool:
	var previous = card_manager.last_played_cards()
	print(previous)
	if previous.size() == 0:
		return true
	
	var previous_card: UnoCard = previous[0]
	return card.is_black_card() or \
			card.value == previous_card.value or \
			card.colour == previous_card.colour

func _handle_played_card(card: UnoCard) -> void:
	var next_turn_offset = 1
	
	if card.is_plus_2():
		_next_player_draw(2)
	elif card.is_reverse():
		card_board.reverse_player_turn()
	elif card.is_stop():
		next_turn_offset = 2
	elif card.is_plus_4():
		_next_player_draw(4)
		card_board.add_child(color_select.instance())
		# TODO: change colour
		
	card_board.next_turn(next_turn_offset)

func _next_player_draw(card_count: int) -> void:
	var next_player = card_board.player_id_of_turn(1)
	card_manager.player_draw(next_player, card_count)
