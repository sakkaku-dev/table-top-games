extends Control

onready var username = $Username

func _ready():
	Online.connect("session_connected", self, "_set_user_info")

func _set_user_info(session: NakamaSession):
	username.text = session.username
