extends Control

signal hold()

export var mouse_hold_time_in_sec = 1

onready var hold_timer := $HoldTimer


func _on_HoldTimer_timeout():
	emit_signal("hold")


func _on_MouseArea_button_down():
	hold_timer.start(mouse_hold_time_in_sec)


func _on_MouseArea_button_up():
	hold_timer.stop()
