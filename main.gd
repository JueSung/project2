extends Node
class_name Main

var my_ID = 1 #for instantiation

var players_IDs = [] #for host, #in order as joined from host perspective
var player_objects = {}
var players_inputs = {} #dictionary of player id : dictionary of inputs
var player_datas = {}

var objects = {} #types: Sawblade, Boom
var objects_datas = {}
var objects_to_be_deleted = []

var PlayerScene = preload("res://player.tscn")
var MapScene = preload("res://map.tscn")

#For client instantiation scenes
var Scenes = {
	"Sawblade" : preload("res://sawblade.tscn"),
	"Boom" : preload("res://boom.tscn")
}


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
		
		for key in objects:
			if is_instance_valid(objects[key]):
				objects_datas[key] = objects[key].get_data()
		
		$Multiplayer_Processing.send_object_states(objects_datas) #handles objects to be added via seeing new objects
		$Multiplayer_Processing.send_delete_objects(objects_to_be_deleted)
		objects_to_be_deleted = []
		

#only for server
func main_add_child(type, object):
	#the formula for consistent stringified name based on object is everything after the ":" in the object name
	var str = str(object)
	str = str.substr(str.find(":") + 1)
	objects[str] = object
	objects_datas[str] = object.get_data()
	add_child(object)

#only for server
func main_delete_object(object):
	#the formula for consistent stringified name based on object is everything after the ":" in the object name
	var str = str(object)
	str = str.substr(str.find(":") + 1)
	objects_to_be_deleted.append(str)
	objects.erase(str)
	objects_datas.erase(str)
	object.queue_free()

#only for clients
func client_delete_objects(objects_to_be_deletedd):
	for i in range(len(objects_to_be_deletedd)):
		var key = objects_to_be_deletedd[i]
		if objects.has(key) and is_instance_valid(objects[key]):
			objects[key].free()
			objects.erase(key)
			objects_datas.erase(key)
		

func update_player_datas(player_datass):
	player_datas = player_datass
	for id in player_objects:
		player_objects[id].update_game_state(player_datas[id])

func update_object_states(objects_datass):
	for key in objects_datass:
		#handle new objects, creation
		if not objects.has(key):
			var type = objects_datass[key]["type"]
			match type:
				"Sawblade":
					var obj = Scenes[type].instantiate()
					objects[key] = obj
					add_child(obj)
				"Boom":
					var obj = Scenes[type].instantiate()
					objects[key] = obj
					add_child(obj)
		else:
			if is_instance_valid(objects[key]):
				objects[key].update_game_state(objects_datass[key])
