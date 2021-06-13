extends Pile

signal cards_played(cards)

export var max_active_cards = 1 setget _set_max_active_cards
var _active_cards = []

func _set_max_active_cards(value: int) -> void:
	max_active_cards = value
	$Cards.max_active_cards = value


func _on_Cards_card_clicked(card: CardUI):
	if max_active_cards <= 1:
		emit_signal("cards_played", [card.instance()])
	else:
		if card.is_activated():
			_active_cards.erase(card)
			card.deactivate()
		elif _active_cards.size() < max_active_cards:
			_active_cards.append(card)
			card.activate()


func _on_Cards_card_hold(card: CardUI):
	emit_signal("cards_played", _get_active_cards())
	_clear_active_cards()


func _get_active_cards() -> Array:
	var cards = []
	for c in _active_cards:
		cards.append(c.instance())
	return cards
	
	
func _clear_active_cards() -> void:
	for c in _active_cards:
		c.deactivate()
	_active_cards.clear()
