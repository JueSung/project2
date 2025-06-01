extends Node
class_name Multiplayer_Processing
#handles game state related multiplayer network stuff

var inputs = {}
var my_ID = 1 #for instantiation
#var in_a_game = false #only collects inputs if in a game


# Called when the node enters the scene tree for the first time.
func _ready():
	inputs = {
		"left" : false,
		"right" : false,
		"up" : false,
		"left_click" : false,
		"right_click" : false,
		"mouse_position_x" : 0,
		"mouse_position_y" : 0
	}

func set_ID(id):
	my_ID = id

func _process(delta):
	inputs["left"] = Input.is_action_pressed("left")
	inputs["right"] = Input.is_action_pressed("right")
	inputs["up"] = Input.is_action_pressed("up")
	inputs["left_click"] = Input.is_action_pressed("left_click")
	inputs["right_click"] = Input.is_action_pressed("right_click")

	inputs["mouse_position_x"] = get_viewport().get_mouse_position().x
	inputs["mouse_position_y"] = get_viewport().get_mouse_position().y
	
	var packet = JSON.stringify(inputs)
	send_inputs_to_server(packet)
	
#get inputs from own Multiplayer_Processing to own Main
func send_inputs_to_server(packet: Variant):
	if my_ID != 1:
		rpc_id(1, "recieve_client_inputs", my_ID, packet)
	else:
		recieve_client_inputs(1, packet)

#recieving client inputs from client Main
@rpc("any_peer", "reliable")
func recieve_client_inputs(id, packet):
	var inputs = JSON.parse_string(packet)
	get_parent().set_player_inputs(id, inputs)
	
#from server main send out signal to start games to clients
func start_the_games():
	#peer id 0 means all peers besides self
	rpc_id(0, "recieve_start_game")

#recieve start game signal from server, tells client main to start game
@rpc("any_peer", "reliable")
func recieve_start_game():
	get_parent().start_game()

#recieve update information for a particular object based on some id string thing

#called by main to send out updated player info
func send_player_info(player_datas):
	rpc_id(0, "recieve_player_info", player_datas)

@rpc("any_peer", "reliable")
func recieve_player_info(player_datas):
	get_parent().update_player_datas(player_datas)


#recieve information to create object

#recieve information to delete object


#is called by main when game starts
func is_in_a_game(id):
	my_ID = id
	#in_a_game = true
