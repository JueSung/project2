extends CharacterBody2D
class_name Player

var my_ID #the ID of the client/user that it "belongs"/is assigned to

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

var right_click_has_released = true
var left_click_has_released = true

var marked_sawblades = []
var sawblades_leaped = 0 #jump over 10 sawblades to get one charge (charge is ability)
var charges = 0 #num of ability uses

var health = 5
var frozenFor = 0 #when take damage frozne for amount of time


var BoomScene = preload("res://boom.tscn")

func set_ID(id):
	my_ID = id

func _ready():
	player_data["position"] = position
	velocity.y = -1
	
	if get_tree().root.get_node("Main").my_ID != 1:
		$CollisionShape2D.disabled = true
		$RayCastSurface.enabled = false
		$RayCastSawblade.enabled = false
		
		set_process(false)
	

func _process(delta):
	#when take damage, freezes for a second
	if frozenFor > 0:
		frozenFor -= delta
		return
	
	#reset double jump and when landing on floor, mark sawblades
	if is_on_floor():
		$RayCastSurface.enabled = false
		$RayCastSawblade.enabled = false
		can_double_jump = true
		for i in range(len(marked_sawblades)):
			if is_instance_valid(marked_sawblades[i]):
				marked_sawblades[i].mark()
				sawblades_leaped += 1
				if sawblades_leaped == 5:
					sawblades_leaped -= 5
					charges += 1
					#do obtain charge animation
		marked_sawblades = []	
	
	#jumping stuff
	if not is_on_floor(): #if in the air
		if velocity.y <= 0 || (up && not up_has_released):
			velocity.y += gravity * delta #gravity applied less if going up
		else:
			velocity.y += gravity * 1.5 * delta
	#handle jump
	if up and (is_on_floor() or (up_has_released and (can_jump or can_double_jump))):
		$RayCastSawblade.enabled = true
		$RayCastSurface.enabled = true
		velocity.y = JUMP_VELOCITY
		if not (is_on_floor() or can_jump) and up_has_released:
			can_double_jump = false
		up_has_released = false
	#in air but not jumping
	elif not up and not is_on_floor() and velocity.y < 0:
		velocity.y -= (5 * velocity.y) * delta
	if not up:
		up_has_released = true
			
	if can_jump:
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
	
	#raycast stuff -------------------------------------------------------------------------------
	#RayCastSurface is always len 1080 or max length of screen
	#RayCastSawblade len dynamically changes to be length to nearest surface on ground detected by RayCastSurface
	
	#establish distance of Raycast Sawblade using RayCastSurface
	if $RayCastSurface.is_colliding(): #basically always is
		var collider = $RayCastSurface.get_collider()
		$RayCastSawblade.set_target_position(Vector2(0,\
		($RayCastSurface.get_collision_point() - $RayCastSurface.global_position).length()))
		
	#checking if over sawblade
	if $RayCastSawblade.is_colliding():
		var collider = $RayCastSawblade.get_collider() #collider is the first collider along raycast path
		if marked_sawblades.find(collider) == -1:
			marked_sawblades.append(collider)
	#------------------------------------------------------------------------------------------------
	
	#ability
	if left_click and left_click_has_released and charges > 0:
		#projectile ability use
		left_click_has_released = false
		charges -= 1
		var boom = BoomScene.instantiate()
		var dir = mouse_position - global_position
		boom.setUp(true, dir.normalized() * 80 + global_position, atan2(dir.y,dir.x))
		get_tree().root.get_node("Main").main_add_child(boom)
		
	if right_click and right_click_has_released and charges > 0:
		#"melee" ability use
		right_click_has_released = false
		charges -= 1
		var boom = BoomScene.instantiate()
		boom.setUp(false, global_position, 0)
		get_tree().root.get_node("Main").main_add_child("Boom", boom)
	
	
	if not left_click:
		left_click_has_released = true
	if not right_click:
		right_click_has_released = true
	
	
	player_data["position"] = position

#player takes damage upon hitting sawblade, called by sawblade
func take_damage():
	velocity /= 3
	frozenFor = .2 #freezes a bit when take damage
	health -= 1
	if health <= 0:
		#do some die animation
		die()

#when player runs out of health, dies, called by take_damage()
func die():
	print(my_ID, ", ", get_parent().my_ID)
	get_tree().root.get_node("Main").player_died(my_ID) #tell main that player died to check if game is done
	#set_process(false)
	#$CollisionShape2D.disabled = true

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
