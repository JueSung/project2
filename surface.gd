extends StaticBody2D
class_name Surface
#meant for walls/ground, etc. handled by Map

func setUp(size, pos, rot):
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate() #separates resource so same scene shapes are independent
	$CollisionShape2D.shape.size = size
	
	position = pos
	rotation = rot
	print($CollisionShape2D.shape.size)
