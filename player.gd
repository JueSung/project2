extends CharacterBody2D
class_name Player

var my_ID

var gravity = 1470 * 1.5

const SPEED = 420 * 1.5
var JUMP_VELOCITY = -1 * sqrt(gravity * 2 * 240)

var AIR_FRICTION = 420

#user input info
var left = false
var right = false
var up = false
var left_click = false
var right_click = false
var side_mouse_click = false

var mouse_position = Vector2(0,0)

var player_data = {}

#based completely whether touching another player or wall or whatever
var can_jump = 0 #is a timer for extra time bout .4 seconds
var can_double_jump = false
var up_has_released = true

func set_ID(id):
	my_ID = id

func _ready():
	player_data["position"] = position
	velocity.y = -1
	
	

func _process(delta):
	if get_tree().root.get_node("Main").my_ID == 1:
		
		#jumping stuff
		if not is_on_floor(): #if in the air
			if velocity.y <= 0 || (up && not up_has_released):
				velocity.y += gravity * delta #gravity applied less if going up
			else:
				velocity.y += gravity * 1.5 * delta
		#handle jump
		if up and (is_on_floor() or (up_has_released and (can_jump or can_double_jump))):
			velocity.y = JUMP_VELOCITY
			if not (is_on_floor() or can_jump) and up_has_released:
				can_double_jump = false
			up_has_released = false
		#in air but not jumping
		elif not up and not is_on_floor() and velocity.y < 0:
			velocity.y -= (5 * velocity.y) * delta

		if not up:
			up_has_released = true

		#reset double jump
		if is_on_floor() or can_jump:
			can_double_jump = true
		
		
		#left, right
		var direction = 0
		if right:
			direction += 1
		if left:
			direction -= 1
		
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 30)
			
			#animation stuff
			
		else:
			velocity.x = move_toward(velocity.x, 0, 20 * SPEED * delta)
		
		
		
		move_and_slide()
		
		if can_jump:
			can_jump -= delta
			if can_jump < 0:
				can_jump = 0
		
		var collision_count = get_slide_collision_count()
		for i in range(collision_count):
			var collision = get_slide_collision(i)
			if collision.get_collider() is Player:
				can_jump = .4
		
		
		player_data["position"] = position

#called by main to get info to send to clients
func get_data():
	return player_data
	
#for client side to update game state
func update_game_state(player_dataa):
	position = player_dataa["position"]

#ran by server to update inputs sent by clients
func update_inputs(inputs):
	left = inputs["left"]
	right = inputs["right"]
	up = inputs["up"]
	left_click = inputs["left_click"]
	right_click = inputs["right_click"]
	mouse_position.x = inputs["mouse_position_x"]
	mouse_position.y = inputs["mouse_position_y"]
