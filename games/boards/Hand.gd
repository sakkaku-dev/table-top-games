extends Control

signal cards_played(cards)

var store: AbstractStore = null setget _set_store
var deck: Deck = null setget _set_deck

export var max_active_cards = 1 setget _set_max_active_cards
var _active_cards = []

onready var _cards = $Cards

func _set_max_active_cards(value: int) -> void:
	max_active_cards = value
	$Cards.max_active_cards = value

func _set_deck(_deck: Deck) -> void:
	deck = _deck
	_cards.card_visual = deck.get_ui()


func _set_store(_store: AbstractStore) -> void:
	store = _store
	store.connect("changed", self, "_update_container")
	_update_container()


func _update_container() -> void:
	if not store: return
	_cards.update_cards(store.cards())


func _on_Cards_card_clicked(card: CardUI):
	if max_active_cards <= 1:
		emit_signal("cards_played", [card.instance()])
	elif _active_cards.size() < max_active_cards:
		if card.is_activated():
			_active_cards.erase(card)
			card.deactivate()
		else:
			_active_cards.append(card)
			card.activate()
			
	print(_active_cards.size())


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
