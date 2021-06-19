class_name UnoRule

var card_manager: CardManager

func get_max_playable() -> int:
	return 1

func setup(board, players: Array):
	card_manager = board.card_manager
	card_manager.setup_cards(players, 7)

	if OnlineMatch.is_network_server():
		var card = card_manager.draw_card()
		card_manager.discard_cards([card])

func play_cards(cards: Array) -> void:
	if cards.size() != 1:
		print("Only one card can be played")
		return
	
	if _can_play_card(cards[0]):
		card_manager.discard_cards(cards)
	else:
		print("Cannot play card")

func _can_play_card(card: UnoCard) -> bool:
	var previous = card_manager.last_played_cards()
	if previous.size() == 0:
		return true
	
	var previous_card: UnoCard = previous[0]
	return card.colour == UnoCard.Colour.BLACK or \
			card.value == previous_card.value or \
			card.colour == previous_card.colour
