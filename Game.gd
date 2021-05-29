extends Node2D

export var enable_only_for_web = false

signal unsupported

func _ready():
	if enable_only_for_web and not OS.has_feature("Javascript"):
		emit_signal("unsupported")

