extends RigidBody2D
class_name Sawblade

#note linear dampening is at -.1 because that makes it have 0 loss in linear velocity while moving through air
#idk why it needs that but it works so i no touch it

var t_to_go
var LVELOCITY = Vector2(300,300).length()
var direction = Vector2(1,0) #normalize vector

var marks = 0 #num times been jumped over (and landed) once reaches 4, dies

var data = {}

func set_direction(dir):
	direction = dir.normalized()

func _ready():
	data["type"] = "Sawblade"
	t_to_go = 3
	
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	
	if get_tree().root.get_node("Main").my_ID != 1:
		$CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D.disabled = true
		$Area2D.monitorable = false
		$Area2D.monitoring = false
		
		set_process(false)
	
	else:
		$AnimatedSprite2D.animation = "Normal"
		$AnimatedSprite2D.play()
		
		data["position"] = global_position
		data["rotation"] = rotation
		data["pre_mark_animation"] = $Pre_mark_sprite.animation
		data["animation"] = $AnimatedSprite2D.animation
		data["animation_frame"] = $AnimatedSprite2D.frame
		#animation states

func _process(delta):
	if t_to_go > 0:
		t_to_go -= delta
		if t_to_go < 0:
			linear_velocity = direction.normalized() * LVELOCITY
			$CollisionShape2D.disabled = false
			$Area2D/CollisionShape2D.disabled = false
	
	data["position"] = global_position
	data["rotation"] = rotation
	data["pre_mark_animation"] = $Pre_mark_sprite.animation
	data["animation"] = $AnimatedSprite2D.animation
	data["animation_frame"] = $AnimatedSprite2D.frame
	
#when a player is over sawblade, but hasn't landed yet
func premark():
	if $Pre_mark_sprite.animation == "Green":
		$Pre_mark_sprite.animation = "Yellow"
	elif $Pre_mark_sprite.animation == "Yellow":
		$Pre_mark_sprite.animation = "Red"
	elif $Pre_mark_sprite.animation == "Red":
		pass
	else: #Normal
		if $AnimatedSprite2D.animation == "Normal":
			$Pre_mark_sprite.animation = "Green"
		elif $AnimatedSprite2D.animation == "Green":
			$Pre_mark_sprite.animation = "Yellow"
		elif $AnimatedSprite2D.animation == "Yellow":
			$Pre_mark_sprite.animation = "Red"
		else: #Red
			pass

#called when player lands after jumped over this sawblade
#if marks = 4, then it dies
func mark():
	marks += 1
	$Pre_mark_sprite.animation = "None"
	if marks == 1:
		$AnimatedSprite2D.animation = "Green"
	elif marks == 2:
		$AnimatedSprite2D.animation = "Yellow"
	elif marks == 3:
		$AnimatedSprite2D.animation = "Red"
	elif marks == 4:
		die()

#die (animation + queuefree stuff)
func die():
	get_tree().root.get_node("Main").main_delete_object(self) #change later if hay animation

#from area2D node signal
func body_entered(body):
	if body == self:
		return
	if body is Sawblade:
		pass
		#mark() #if to many sawblades become generated, can do this to limit sawblades
	elif body is Player:
		#deal damage to player or kill player
		body.take_damage() #player takes damage


func get_data():
	return data

func update_game_state(dataa):
	global_position = dataa["position"]
	rotation = dataa["rotation"]
	#animation stuff
	
	$Pre_mark_sprite.animation = dataa["pre_mark_animation"]
	$AnimatedSprite2D.animation = dataa["animation"]
	$AnimatedSprite2D.frame = dataa["animation_frame"]
