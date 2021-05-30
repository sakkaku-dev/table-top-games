extends Control

signal connected

onready var container = $CenterContainer/VBoxContainer
onready var username = $CenterContainer/VBoxContainer/Username
onready var error = $CenterContainer/VBoxContainer/Error

onready var reconnect_label = $CenterContainer/Reconnect

export var return_screen_path: NodePath
onready var return_screen = get_node(return_screen_path)

func _ready():
	var existing = _get_existing_id()
	if existing:
		username.hide()
		_login(existing)


func reconnect(screen):
	return_screen = screen
	
	show()
	container.hide()
	reconnect_label.show()
	_login(_get_existing_id())
	
	if not Online.is_authenticated():
		container.show()
		reconnect_label.hide()


func connect_client():
	if not username.text:
		error.text = "No username specified"
		return
	
	var id = _get_existing_id()
	if not id:
		id = UUID.v4()
	
	_login(id, true)
	

func _login(id, save = false):
	var client = Online.get_nakama_client()
	
	var session : NakamaSession = yield(client.authenticate_device_async(id, username.text), "completed")
	if session.is_exception():
		print("An error occured: %s" % session)
		error.text = Online.get_error_message(session)
		return
	
	print("Successfully authenticated: %s" % session)
	Online.nakama_session = session
	if save: _save_id(id)
	
	if return_screen:
		return_screen.show()

func _save_id(id):
	var id_file = File.new()
	
	if id_file.open("user://unique_id", File.WRITE) == OK:
		id_file.store_line(id)
	else:
		print("Failed to open id file for write")

func _get_existing_id():
	var file = File.new()
	if file.open("user://unique_id", File.READ) == OK:
		return file.get_line()
	return ""
