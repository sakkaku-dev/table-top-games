# Modified from original "Fish Game" code
# To using single identifier for easier/simpler login

extends "res://main/Screen.gd"

onready var username_field := $Login/VBoxContainer/HBoxContainer/Username

const ID_FILENAME = 'user://unique_id'

var id: String = ''
var username: String = ''

var _reconnect: bool = false
var _next_screen

func _ready() -> void:
	var file = File.new()
	if file.file_exists(ID_FILENAME):
		file.open(ID_FILENAME, File.READ)
		id = file.get_line()
		file.close()

func _save_credentials() -> void:
	var file = File.new()
	file.open(ID_FILENAME, File.WRITE)
	file.store_line(id)
	file.close()

func _show_screen(info: Dictionary = {}) -> void:
	_reconnect = info.get('reconnect', false)
	_next_screen = info.get('next_screen', 'MatchScreen')
	
	if id != '':
		do_login()

func do_login(save_credentials: bool = false) -> void:
	visible = false
	
	if _reconnect:
		ui_layer.show_message("Session expired! Reconnecting...")
	else:
		ui_layer.show_message("Logging in...")
	
	var nakama_session: NakamaSession = yield(Online.nakama_client.authenticate_device_async(id, username, save_credentials), "completed")
	
	if nakama_session.is_exception():
		visible = true
		ui_layer.show_message("Login failed!")
		
		if nakama_session.exception.status_code == 404:
			id = ''
		
		# We always set Online.nakama_session in case something is yielding
		# on the "session_changed" signal.
		Online.nakama_session = null
	else:
		if save_credentials:
			_save_credentials()
		Online.nakama_session = nakama_session
		ui_layer.hide_message()
		
		if _next_screen:
			ui_layer.show_screen(_next_screen)


func _on_ConnectButton_pressed() -> void:
	username = username_field.text.strip_edges()
	
	if username == '':
		ui_layer.show_message("Must provide username")
		return
	
	var new_id = id == ''
	if new_id:
		id = UUID.v4()
	
	do_login(new_id)
