extends Node
class_name Main

var my_ID = 1 #for instantiation

var players_IDs = [] #for host, #in order as joined from host perspective
var player_objects = {}
var players_inputs = {} #dictionary of player id : dictionary of inputs
var player_datas = {}

var PlayerScene = preload("res://player.tscn")
var MapScene = preload("res://map.tscn")


func _ready():
	#$HUD.show()
	$Lobby.player_loaded.rpc_id(1)

#called by Lobby sets self either to 1 or the randomly generated id if not host
func set_ID(id):
	my_ID = id
	$Multiplayer_Processing.set_ID(id)

#recieved from lobby _register_player when player joins both server and clients
func add_player(peer_id: Variant, player_info: Variant):
	players_IDs.append(peer_id)

#signal recieved from lobby _on_player_disconnected if any peer disconnecs
func player_disconnected(peer_id: Variant):
	players_IDs.remove_at(players_IDs.find(peer_id))

#for client when/if server disconnects
func server_disconnected():
	pass # Replace with function body.

#homepage stuff
func host_game():
	$Lobby.create_game()
	$HUD.host_game()

func join_game():
	if get_node("HUD").get_node("IP").text == "": #needs to enter ip/port info still
		$HUD.enter_ip_info()
	else:
		$HUD.join_game()
		var ip = $HUD.get_node("IP").text
		var port = $HUD.get_node("Port").text
		$Lobby.join_game(ip, port)

func start_game():
	$HUD.start_game()
	
	if my_ID == 1:
		$Multiplayer_Processing.start_the_games()
	
	#initialize map
	var map = MapScene.instantiate()
	add_child(map)
	
	#initialize players
	var count = 0
	for peer_id in players_IDs:
		var player_instance = PlayerScene.instantiate()
		player_instance.set_ID(peer_id)
		
		#figure out player position, may be handled by Map in the future
		if my_ID == 1:
			# do some calculation to figure out placements of players
			player_instance.position = Vector2(300,300 + count * 50)
		else:
			#just yeet them up there, their positions will be updated shortly
			player_instance.position = Vector2(-100, 540)

		player_objects[peer_id] = player_instance		
		add_child(player_instance)
		count += 1
	
	

func return_to_title_page():
	#player_datas = {}
	#player_objects = {}
	#player_IDs = []
	#need to clear all child nodes, players, etc.
	
	$Lobby.remove_multiplayer_peer()
	$HUD.return_to_title_page()

func set_player_inputs(id, inputs):
	players_inputs[id] = inputs


func _process(delta):
	if my_ID == 1:
		
		for id in player_objects:
			if id in players_inputs:
				player_objects[id].update_inputs(players_inputs[id])
			
			player_datas[id] = player_objects[id].get_data()
		$Multiplayer_Processing.send_player_info(player_datas)

func update_player_datas(player_datass):
	player_datas = player_datass
	for id in player_objects:
		player_objects[id].update_game_state(player_datas[id])
