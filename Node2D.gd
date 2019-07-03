extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var num_rooms = 20
var min_size = 5
var max_size = 10
var tile_size = 16
var hspread = 70

var Room = preload("res://Room.tscn")
onready var Map = $TileMap

var path = null
var path_set = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	make_rooms()
	pass # Replace with function body.

func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	yield(get_tree().create_timer(1.1), 'timeout')
	var room_positions = []
	for r in $Rooms.get_children():
		room_positions.append(Vector3(r.position.x, r.position.y, 0))
		#room.mode = RigidBody2D.MODE_STATIC
		yield(get_tree(), 'idle_frame')
	find_mst(room_positions)

func find_mst(nodes):
	path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front());
		
	#add first node
	
	while nodes:
		var min_dist = INF;
		var nextmin_node = null
		var current_node = null
		for p1 in path.get_points():
			var p = path.get_point_position(p1)
			for q in nodes:
				if (p.distance_to(q) < min_dist):
					min_dist = p.distance_to(q)
					nextmin_node = q
					current_node = p
							
		var n = path.get_available_point_id()
		path.add_point(n, nextmin_node)
		#path.connect_points(current_node, n)
		path.connect_points(path.get_closest_point(current_node), n)
		nodes.erase(nextmin_node)				
	print ("MST complete!")
	path_set = true
	pass


func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(1, 0, 0), false)
		if (path_set == true):
			var path_id = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
			for edge in path.get_point_connections(path_id):
				draw_line(Vector2(path.get_point_position(path_id).x, path.get_point_position(path_id).y),
							Vector2(path.get_point_position(edge).x, path.get_point_position(edge).y),
							Color(0, 1, 0), 2, true)
	#if (path_set == true):
	#	for p in path.get_points():
	#		for c in path.get_point_connections(p):
	#			var pp = path.get_point_position(p)
	#			var cp = path.get_point_position(c)
	#			draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(0, 0, 1), 2, true)
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	pass

func _input(event):
	if (event.is_action_pressed('ui_select')):
		for r in $Rooms.get_children():
			r.queue_free()
		make_rooms()
	if (event.is_action_pressed('ui_focus_next')):
		print ("tab")
		make_map()
		

func make_map():
	Map.clear()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, 
					room.get_node("CollisionShape2D").shape.extents * 2)
		#room.size * 2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x, y, 1)
			
		
		
		

