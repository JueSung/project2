extends StaticBody2D

var time_to_dispense = 1

var SawbladeScene = preload("res://sawblade.tscn")

var data = {}

func _ready():
	pass #animation stuff
	
	if get_tree().root.get_node("Main").my_ID != 1:
		$CollisionShape2D.disabled = true

func _process(delta):
	if get_tree().root.get_node("Main").my_ID == 1:
		time_to_dispense -= delta
		
		if time_to_dispense < 0:
			#dispense (spawn sawblade)
			var sawblade = SawbladeScene.instantiate()
			#randomize direction/position
			sawblade.global_position = global_position + Vector2(randf()-0.5, randf()-0.5).normalized() * 80
			sawblade.set_direction(Vector2(randf()-0.5, randf()-0.5))
			get_tree().root.get_node("Main").main_add_child("Sawblade", sawblade)
			
			#reset time_to_dispense
			time_to_dispense = 5
	
func get_data():
	return data
	
func update_game_state(dataa):
	pass
