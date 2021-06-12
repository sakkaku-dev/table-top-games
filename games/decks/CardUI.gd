extends Node2D

class_name CardUI

signal clicked()
signal hold()

enum CardSide {FRONT, BACK}

export(Vector2) var size: Vector2 = Vector2(0.0, 0.0)

var _inst: Card = null
var side = CardSide.FRONT setget set_side
var interactive: bool = true

onready var _placeholder = $AnimContainer/Placeholder
onready var _front = $AnimContainer/Front
onready var _back  = $AnimContainer/Back

export var mouse_hold_threshold = 2000

func set_instance(inst: Card) -> void:
	_inst = inst
	_update_visibility()

func instance() -> Card:
	return _inst


func set_side(side_up: int) -> void:
	if side == side_up:
		return

	side = side_up
	_update_visibility()

func change_side() -> void:
	if side == CardSide.FRONT:
		set_side(CardSide.BACK)
	else:
		set_side(CardSide.FRONT)


func set_root_trans(transform: CardTransform):
	position = transform.pos
	scale = transform.scale
	rotation = transform.rot


func set_interactive(state: bool) -> void:
	interactive = state


func _update_visibility() -> void:
	if _inst == null:
		_placeholder.visible = true
		_back.visible = false
		_front.visible = false
		return
	else:
		_placeholder.visible = false

	if side == CardSide.FRONT:
		_back.visible = false
		_front.visible = true
	elif side == CardSide.BACK:
		_front.visible = false
		_back.visible = true


func is_activated() -> bool:
	return modulate.a < 1

func activate() -> void:
	modulate.a = 0.5
	
func deactivate() -> void:
	modulate.a = 1


func _on_MouseArea_pressed() -> void:
	if not interactive:
		return

	emit_signal("clicked")


func _on_MouseArea_hold():
	if not interactive:
		return

	emit_signal("hold")
