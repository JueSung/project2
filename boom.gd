extends Area2D
class_name Boom

var time_melee_exists = 1 #time melee circular area exists
var isProjectile = false
var SPEED = 600

var velocity = Vector2(0,0)

var data = {}

#isProjectile whether it was left or right click - melee or start projectile
#rot for rotation which is same as direction
func setUp(isProj, pos, rot):
	global_position = pos
	rotation = rot
	isProjectile = isProj
	
	

func _ready():
	data["type"] = "Boom"
		
	if isProjectile:
		isProjectile = true
		$ProjectileShape.disabled = false
		$MeleeShape.disabled = true
		
		velocity = SPEED * Vector2(cos(rotation), sin(rotation))
		
		#animation stuff
		$ProjectileSprite.visible = true
		$MeleeSprite.visible = false
		
	else:
		#isProjectile = false #default value
		$ProjectileShape.disabled = true
		$MeleeShape.disabled = false
		#animation stuff
		$ProjectileSprite.visible = false
		$MeleeSprite.visible = true
	
	if get_parent().my_ID != 1:
		$ProjectileShape.disabled = true
		$MeleeShape.disabled = true
		
		set_process(false)
	else:
		
		data["position"] = global_position
		data["rotation"] = rotation
		
		data["MeleeSprite_visible"] = $MeleeSprite.visible
		data["Projectile_visible"] = $ProjectileSprite.visible

func _process(delta):
	if isProjectile:
		position += velocity * delta
	else:
		time_melee_exists -= delta
		if time_melee_exists <= 0:
			get_tree().root.get_node("Main").main_delete_object(self)
	
	#update animation stuff
	data["position"] = global_position
	#prob don't need to do rotation

#from projectile to melee
func becomeMelee():
	velocity = Vector2(0,0)
	isProjectile = false
	$ProjectileShape.disabled = true
	$MeleeShape.disabled = false
	$MeleeShape.shape = $MeleeShape.shape.duplicate()
	
	$ProjectileSprite.visible = false
	$MeleeSprite.visible = true
	
	data["MeleeSprite_visible"] = $MeleeSprite.visible
	data["Projectile_visible"] = $ProjectileSprite.visible
	
	force_update_transform()

#i guess just apply instantenous velocity?... continuous would be complicated
#velocity dependent on distance from center aka pos of the boom
func area_entered(area):
	if isProjectile and not area is Boom:
		becomeMelee()
		return
	if area.get_parent() is Sawblade:
		var sawblade = area.get_parent()
		var dist = (sawblade.global_position - global_position).length()
		sawblade.linear_velocity += (sawblade.global_position - global_position).normalized() * (3200 - 3200/400 * dist)#max dist is 300 rn?
	if area is Boom and area.isProjectile:
		var dist = (area.global_position - global_position).length()
		area.velocity += (area.global_position - global_position).normalized() * (3200 - 3200/400 * dist)
		
func body_entered(body):
	if isProjectile:
		becomeMelee()

	
	if body is Player:
		var dist = (body.global_position - global_position).length()
		body.velocity += (body.global_position - global_position).normalized() * (3200 - 3200/400 * dist)#max dist is 300 rn?


func get_data():
	return data

func update_game_state(dataa):
	position = dataa["position"]
	rotation = dataa["rotation"]
	#animation stuff
	$MeleeSprite.visible = dataa["MeleeSprite_visible"]
	$ProjectileSprite.visible = dataa["Projectile_visible"]
