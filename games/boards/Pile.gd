extends Control

class_name Pile

signal cards_clicked(cards)
signal card_clicked(card)

export var pile_config: Resource

var card_visual: PackedScene = null setget _set_card_visual

var _store: AbstractStore = null

onready var _cards = $Cards
onready var _play = $Play

export var select_multiple = false setget _set_select_multiple

func _ready():
	_cards.connect("card_clicked", self, "_card_clicked")


func _set_card_visual(scene) -> void:
	_cards.card_visual = scene


func store() -> AbstractStore:
	return _store


func set_store(store: AbstractStore) -> void:
	_store = store
	_store.connect("changed", self, "_update_container")
	_update_container()


func _set_select_multiple(value: bool) -> void:
	select_multiple = value
	if _play:
		_update_play_btn()
	
func _update_play_btn() -> void:
	_play.visible = select_multiple and _cards.get_active_cards().size() > 0

func _card_clicked(card: CardUI) -> void:
	if not select_multiple:
		emit_signal("card_clicked", card.instance())
	else:
		_update_play_btn()

func play_active_cards() -> void:
	emit_signal("cards_clicked", _cards.get_active_cards())
	_cards.clear_active_cards()
	_update_play_btn()


func _update_container() -> void:
	if not _store: return
	_cards.update_cards(_store.cards())


#func _map_from(trans: CardTransform) -> CardTransform:
#	var result := CardTransform.new()
#
#	result.pos = trans.pos + rect_position
#	result.scale = trans.scale * rect_scale
#	result.rot = trans.rot + rect_rotation
#
#	return result
#
#
#func _map_to(trans: CardTransform) -> CardTransform:
#	var result := CardTransform.new()
#
#	result.pos = trans.pos - rect_position
#	result.scale = trans.scale / rect_scale
#	result.rot = trans.rot - rect_rotation
#
#	return result


func _on_AbstractContainer_resized() -> void:
	_update_container()

