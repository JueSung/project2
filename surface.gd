extends StaticBody2D
class_name Surface
#meant for walls/ground, etc. handled by Map

func setUp(size, pos, rot):
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate() #separates resource so same scene shapes are independent
	$CollisionShape2D.shape.size = size
	
	$Sprite2D.region_rect = Rect2(0,0,size.x,size.y)
	
	position = pos
	rotation = rot

func _ready():
	if get_tree().root.get_node("Main").my_ID != 1:
		$CollisionShape2D.disabled = true
	
