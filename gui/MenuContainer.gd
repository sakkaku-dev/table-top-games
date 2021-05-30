extends Node

class_name MenuContainer

signal screen_changed

func _ready():
	for c in get_children():
		c.connect("visibility_changed", self, "_hide_other", [c])

func _hide_other(node: Control) -> void:
	if node.visible:
		emit_signal("screen_changed")
		for c in get_children():
			if c != node:
				c.hide()

func get_active_screen() -> Control:
	for c in get_children():
		if c.visible:
			return c
	return null
