extends Control

signal connected

onready var username = $CenterContainer/VBoxContainer/Username

func _ready():
	var existing = _get_existing_id()
	if existing:
		_login(existing)

func connect_client():
	if not username.text:
		print("No username specified")
		return

	var id = _new_unique_id()
	if not id:
		print("Invalid id")
		return

	_login(id)

func _login(id):
	var client = Online.get_nakama_client()
	var session : NakamaSession = yield(client.authenticate_custom_async(id, username.text), "completed")
	if session.is_exception():
		print("An error occured: %s" % session)
		return
	
	print("Successfully authenticated: %s" % session)
	Online.nakama_session = session
	emit_signal("connected")

func _new_unique_id():
	var id_file = File.new()
	
	if id_file.open("user://unique_id", File.WRITE) == OK:
		var id = UUID.v4()
		id_file.store_line(id)
		return id
	else:
		print("Failed to open id file for write")
	return ""

func _get_existing_id():
	var file = File.new()
	if file.open("user://unique_id", File.READ) == OK:
		return file.get_line()
	return ""
