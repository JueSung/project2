extends Node2D
class_name Map
#gonna say rn theres only one possible map

var SurfaceScene = preload("res://surface.tscn")
var SawbladeDispenserScene = preload("res://dispenser.tscn")

func _ready():
	
	#create all map elements
	#floor
	var floor = SurfaceScene.instantiate()
	floor.setUp(Vector2(1920, 40), Vector2(1920/2, 1080), 0)
	add_child(floor)
	#walls
	var wall_instance = SurfaceScene.instantiate()
	wall_instance.setUp(Vector2(40,1080), Vector2(0, 540), 0)
	add_child(wall_instance)
	
	wall_instance = SurfaceScene.instantiate()
	wall_instance.setUp(Vector2(40,1080), Vector2(1920, 540), 0)
	add_child(wall_instance)
	
	#ceiling
	var ceiling = SurfaceScene.instantiate()
	ceiling.setUp(Vector2(1920,40), Vector2(1920/2, 0), 0)
	add_child(ceiling)
	
	
	#sawblade dispenser
	var dispenser = SawbladeDispenserScene.instantiate()
	dispenser.position = Vector2(1920/2, 1080/2)
	add_child(dispenser)
