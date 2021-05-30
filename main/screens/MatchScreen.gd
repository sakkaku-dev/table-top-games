# Modified from original "Fish Game" code
# Removed matchmaking related code

extends "res://main/Screen.gd"

onready var create_button = $PanelContainer/VBoxContainer/CreatePanel/HBoxContainer/CreateButton
onready var join_button = $PanelContainer/VBoxContainer/JoinPanel/HBoxContainer/JoinButton
onready var join_match_id_control := $PanelContainer/VBoxContainer/JoinPanel/HBoxContainer/LineEdit

func _ready() -> void:
	create_button.connect("pressed", self, "_on_match_button_pressed", [OnlineMatch.MatchMode.CREATE])
	join_button.connect("pressed", self, "_on_match_button_pressed", [OnlineMatch.MatchMode.JOIN])
	
	OnlineMatch.connect("match_created", self, "_on_OnlineMatch_created")
	OnlineMatch.connect("match_joined", self, "_on_OnlineMatch_joined")

func _show_screen(_info: Dictionary = {}) -> void:
	join_match_id_control.text = ''

func _on_match_button_pressed(mode) -> void:
	# If our session has expired, show the ConnectionScreen again.
	if Online.nakama_session == null or Online.nakama_session.is_expired():
		ui_layer.show_screen("ConnectionScreen", { reconnect = true, next_screen = null })
		
		# Wait to see if we get a new valid session.
		yield(Online, "session_changed")
		if Online.nakama_session == null:
			return
	
	# Connect socket to realtime Nakama API if not connected.
	if not Online.is_nakama_socket_connected():
		Online.connect_nakama_socket()
		yield(Online, "socket_connected")
	
	ui_layer.hide_message()
	
	# Call internal method to do actual work.
	match mode:
		OnlineMatch.MatchMode.CREATE:
			_create_match()
		OnlineMatch.MatchMode.JOIN:
			_join_match()

func _create_match() -> void:
	OnlineMatch.create_match(Online.nakama_socket)

func _on_OnlineMatch_created(match_id: String):
	ui_layer.show_screen("ReadyScreen", { match_id = match_id, clear = true })

func _join_match() -> void:
	var match_id = join_match_id_control.text.strip_edges()
	if match_id == '':
		ui_layer.show_message("Need to paste Match ID to join")
		return
	if not match_id.ends_with('.'):
		match_id += '.'
	
	OnlineMatch.join_match(Online.nakama_socket, match_id)

func _on_OnlineMatch_joined(match_id: String):
	ui_layer.show_screen("ReadyScreen", { match_id = match_id, clear = true })

func _on_PasteButton_pressed() -> void:
	join_match_id_control.text = OS.clipboard
