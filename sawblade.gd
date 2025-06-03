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
		data["position"] = global_position
		data["rotation"] = rotation
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
	

#called when player lands after jumped over this sawblade
#if marks = 4, then it dies
func mark():
	marks += 1
	if marks == 1:
		$TextureRect.modulate = Color(0,1,0)
	elif marks == 2:
		$TextureRect.modulate = Color(1,1,0)
	elif marks == 3:
		$TextureRect.modulate = Color(1,0,0)
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
	
