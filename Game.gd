extends Node2D

signal unsupported

export var enable_only_for_web = false

func _ready():
	if enable_only_for_web and not OS.has_feature("Javascript"):
		emit_signal("unsupported")

