# Modified from original "Fish Game" code
# Kept some game initialization part

extends Node

var deal_board = preload("res://games/boards/DealBoard.tscn")

var game_started := false
var game_over := false
var players_alive := {}
var players_setup := {}
var board: Board

signal game_started ()
signal player_dead (player_id)
signal game_over (player_id)


func _ready():
	OnlineMatch.connect("disconnected", self, "game_stop")


func _get_custom_rpc_methods() -> Array:
	return [
		'_do_game_setup',
		'_finished_game_setup',
		'_do_game_start',
	]

func game_start(players: Dictionary) -> void:
	if GameState.online_play:
		OnlineMatch.custom_rpc_sync(self, '_do_game_setup', [players])
	else:
		_do_game_setup(players)

# Initializes the game so that it is ready to really start.
func _do_game_setup(players: Dictionary) -> void:
	get_tree().set_pause(true)
	
	if game_started:
		game_stop()
	
	game_started = true
	game_over = false
	players_alive = players
	
	board = deal_board.instance()
	add_child(board)
	board.setup_client()
	
#	for player_id in players:
#		var other_player = Player.instance()
#		other_player.name = str(player_id)
#		players_node.add_child(other_player)
#
#		other_player.set_network_master(player_id)
#		other_player.set_player_skin(player_id - 1)
#		other_player.set_player_name(players[player_id])
#		other_player.position = map.get_node("PlayerStartPositions/Player" + str(player_id)).position
#		other_player.rotation = map.get_node("PlayerStartPositions/Player" + str(player_id)).rotation
#		other_player.connect("player_dead", self, "_on_player_dead", [player_id])
#
#		if not GameState.online_play:
#			other_player.player_controlled = true
#			other_player.input_prefix = "player" + str(player_id) + "_"
#
#	camera.update_position_and_zoom(false)
#
#	if GameState.online_play:
	var my_id := OnlineMatch.get_network_unique_id()
#	var my_player := players_node.get_node(str(my_id))
#	my_player.player_controlled = true

	# Tell the host that we've finished setup.
	OnlineMatch.custom_rpc_id_sync(self, 1, "_finished_game_setup", [my_id])
#	else:
#		_do_game_start()

# Records when each player has finished setup so we know when all players are ready.
func _finished_game_setup(player_id: int) -> void:
	players_setup[player_id] = players_alive[player_id]
	if players_setup.size() == players_alive.size():
		# Once all clients have finished setup, tell them to start the game.
		OnlineMatch.custom_rpc_sync(self, "_do_game_start")

# Actually start the game on this client.
func _do_game_start() -> void:
	emit_signal("game_started")
	
	# Setup here so the nodes exist on all clients
	if OnlineMatch.is_network_server():
		board.setup_server(players_alive)
	
	get_tree().set_pause(false)

func game_stop() -> void:
	game_started = false
	players_setup.clear()
	players_alive.clear()
	
	for child in get_children():
		remove_child(child)

#func kill_player(player_id) -> void:
#	var player_node = players_node.get_node(str(player_id))
#	if player_node:
#		if player_node.has_method("die"):
#			player_node.die()
#		else:
#			# If there is no die method, we do the most important things it
#			# would have done.
#			player_node.queue_free()
#			_on_player_dead(player_id)
#
#func _on_player_dead(player_id) -> void:
#	emit_signal("player_dead", player_id)
#
#	players_alive.erase(player_id)
#	if not game_over and players_alive.size() == 1:
#		game_over = true
#		var player_keys = players_alive.keys()
#		emit_signal("game_over", player_keys[0])
