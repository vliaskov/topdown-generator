extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var size

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	$CollisionShape2D.shape = s
	