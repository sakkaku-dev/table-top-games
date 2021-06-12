extends Control

class_name Pile

signal card_clicked(card)

export var face_up = false
export var interactive = true

var store: AbstractStore = null setget _set_store
var deck: Deck = null setget _set_deck

onready var _cards = $Cards

func _ready():
	if _cards:
		_cards.face_up = face_up
		set_interactive(interactive)


func _set_deck(value: Deck) -> void:
	deck = value
	_cards.card_visual = deck.get_ui()


func _set_store(value: AbstractStore) -> void:
	store = value
	store.connect("changed", self, "_update_container")
	_update_container()


func _update_container() -> void:
	if not store: return
	_cards.update_cards(store.cards())


func _on_Cards_card_clicked(card: CardUI):
	emit_signal("card_clicked", card.instance())


func set_interactive(value: bool) -> void:
	_cards.interactive = value
