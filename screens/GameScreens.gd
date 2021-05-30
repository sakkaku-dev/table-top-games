extends MenuContainer

onready var connection_screen = $ConnectionScreen

func check_session():
	var client = Online.get_nakama_client()
	
	if Online.nakama_session == null or Online.nakama_session.is_expired():
		connection_screen.reconnect(get_active_screen())
