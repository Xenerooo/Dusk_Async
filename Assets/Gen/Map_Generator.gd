extends Node2D

var URL_TestData = "user://player_data.bin"

export var _seed : String

export var map_size_x : int = 10
export var map_size_y : int = 10
export var max_village : int = 8
export var max_city : int = 8

export var show_lines :bool = false
onready var map = $"%map"

var path : AStar2D
var map_data_s : Dictionary = {}

const GROUPS := [
	"terrain",
	"floors"
]
var road_modifiers = {
	Vector2(1, 0) : "horizontal",
	Vector2(2, 2) : "diagonal",
	
	Vector2(0, 1) : "down_right",
	Vector2(1, 1) : "down_left", 
	Vector2(0, 2) : "up_right", 
	Vector2(1, 2) : "up_left",
	Vector2(0, 7) : "down_right",
	Vector2(1, 7) : "down_left", 
	Vector2(0, 8) : "up_right", 
	Vector2(0, 8) : "up_left",
	
	Vector2(0, 0) : "crossroad", 
	Vector2(0, 3) : "crossroad", 
	
	Vector2(3, 1) : "middle_up", 
	Vector2(3, 0) : "middle_down", 
	Vector2(2, 0) : "middle_right", 
	Vector2(2, 1) : "middle_left", 
	Vector2(3, 4) : "middle_up", 
	Vector2(3, 3) : "middle_down", 
	Vector2(2, 4) : "middle_right", 
	Vector2(2, 3) : "middle_left", 

	Vector2(3, 7) : "middle_up", 
	Vector2(3, 6) : "middle_down", 
	Vector2(2, 6) : "middle_right", 
	Vector2(2, 7) : "middle_left", 
	Vector2(3, 9) : "middle_up", 
	Vector2(3, 8) : "middle_down", 
	Vector2(2, 8) : "middle_right", 
	Vector2(2, 9) : "middle_left", 

	

	
}
#func _ready():
##	generate_map()
##	print(map.get_used_cells_by_id(0))
#	for i in map.get_used_cells_by_id(0) :
#		print(map.get_cell_autotile_coord(i.x,i.y))
func _init(): 
	SceneAdder._sleep_msec = 40
	SceneAdder.set_groups(GROUPS)

func _input(event):
	if event.is_action_pressed("ui_accept") :
		map_data_s.clear()
		generate_map()
	elif event.is_action_pressed("key_start") :
		get_tree().change_scene("res://Assets/scenes/locations/test_world.tscn")

func _physics_process(delta):
	update()

func _draw():
	if show_lines :
		for p in path.get_points() :
			for c in path.get_point_connections(p) :
				var pp  = path.get_point_position(p)
				var cp  = path.get_point_position(c)
				
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color.black, 1.5)

func generate_map():
	var _rng = RandomNumberGenerator.new()
	
	if _seed :
		_rng.seed = hash(str(_seed))
	else :
		_rng.seed = randi()
		

	map.clear()
	for x in map_size_x :
		for y in map_size_y :
			map.set_cellv(Vector2(x, y), 1)
	
	var plains = map.get_used_cells_by_id(1)
	var structures = []
	var stru = []
	
	for village in max_village :
		var v_coords = plains[_rng.randi() % plains.size()]
		map.set_cellv(v_coords, _rng.randi_range(3, 4))
		structures.append(map.map_to_world(v_coords) + Vector2(map.cell_size.x, map.cell_size.y) / 2)
		stru.append(map.map_to_world(v_coords) + Vector2(map.cell_size.x, map.cell_size.y) / 2)
	for city in max_city :
		
		var v_coords = plains[_rng.randi() % plains.size()]
		map.set_cellv(v_coords, 2)
		structures.append(map.map_to_world(v_coords)  + Vector2(map.cell_size.x, map.cell_size.y)/ 2)
		stru.append(map.map_to_world(v_coords)  + Vector2(map.cell_size.x, map.cell_size.y)/ 2)
	
	
	path = find_mst(structures)

	var roads =  []
	for villages in stru :
		var p = path.get_closest_point(Vector2(villages.x, villages.y))
		for conn in path.get_point_connections(p) :
			if not conn in roads :
				var start = map.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				
				carve_path(start, end, _rng)

	save_chunks(_rng.seed)
	

func find_mst(structures) :
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), structures.pop_front() )



	while structures :
		var min_dist = INF
		var min_p = null
		var p = null
		
		for p1 in path.get_points() :
			p1 = path.get_point_position(p1)
			
			for p2 in structures :
				if p1.distance_to(p2) < min_dist :
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n, false)
		structures.erase(min_p)
	return path

func carve_path(pos1, pos2, rng :RandomNumberGenerator) :
	var tilem : TileSet = map.tile_set
	var neighbor = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	
	if x_diff == 0 : x_diff = pow(-1.0, rng.randi() % 2)
	if y_diff == 0 : y_diff = pow(-1.0, rng.randi() % 2)

	var x_y = pos1
	var y_x = pos2

	if (rng.randi() % 2) > 0 :
		x_y = pos2
		y_x = pos1
#
	for x in range(pos1.x, pos2.x, x_diff) :
		if map.get_cell(x, x_y.y) == 1 :
			map.set_cell(x, x_y.y, 0)
			for n in neighbor :
				tilem._is_tile_bound(0, map.world_to_map(Vector2(x, x_y.y)) + n)
	for y in range(pos1.y, pos2.y, y_diff) :
		if map.get_cell(y_x.x, y) == 1 :
			map.set_cell(y_x.x, y, 0)
			for n in neighbor :
				tilem._is_tile_bound(0, map.world_to_map(Vector2(y_x.x, y)) + n)

	map.update_bitmask_region(Vector2.ZERO, Vector2(map_size_x, map_size_y))


func _on_Button_pressed():
	generate_map()


func save_chunks(_seed) :
	var map_data : Dictionary
	
	if map_data.empty() :
		map_data["chunk_coords"] = {}
		map_data["seed"] = _seed
		for chunk_x in map_size_x :
			for chunk_y in map_size_y :
				var chunk_coord = Vector2(chunk_x, chunk_y)
				map_data["chunk_coords"][var2str(chunk_coord)] = {"chunk_type" : map.get_cellv(chunk_coord)}
				
				if map.get_cellv(chunk_coord) == 0 and map.get_cell_autotile_coord(chunk_x, chunk_y) in road_modifiers :
					var orientation = map.get_cell_autotile_coord(chunk_x, chunk_y)
					map_data["chunk_coords"][var2str(chunk_coord)] = {"chunk_type" : map.get_cellv(chunk_coord), "modifier" : road_modifiers[orientation]}
					
	
	Global_DataParser.write_data(URL_TestData, map_data)
	map_data_s = map_data


func _on_Button2_pressed():
	get_tree().change_scene("res://Assets/scenes/locations/test_world.tscn")
