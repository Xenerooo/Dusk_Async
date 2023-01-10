extends Node2D

#I want each chunk to have a parent node which is going to be the chunknode.
#It's going to be instanced in everychunk that hasn't been loaded.

#References to the player so I can track the location.
export (NodePath) var player_path
var player

#The render distance in the max length and bredth of chunks that can be loaded.
#the chunk size is the size of the chunk obviously.
#current chunk stores the current chunk the player is in.
export (int) var render_distance = 3
export (float) var chunk_size = 80
var current_chunk = Vector2()
var previous_chunk = Vector2()
var chunk_loaded = false

#revolution distance is the distance at which the player must move on the axis in chunk coords
#in order for one revolution to be achived.
export (bool) var circumnavigation = false
export (float) var revolution_distance = 8

onready var active_coord = []
onready var active_chunks = []
onready var loading_chunk = []

var chunk_data = {}


#In the ready func the world script checks if the chunks within the render distance have been loaded
#and if not then they are loaded

func _ready():
	player = get_node(player_path)
	player.chunk_loader = self
	current_chunk = _get_player_chunk(player.global_position)
	var d = Global_DataParser.load_data("user://player_data.bin")
	start_up(d)
	load_chunk()
	
	

#Checks if the player is in a new chunk every frame
func _process(_delta):
	current_chunk = _get_player_chunk(player.global_position)
	if previous_chunk != current_chunk:
		if !chunk_loaded:
			load_chunk()
	else:
		chunk_loaded = false
	previous_chunk = current_chunk
	
	

#This converts the players position to it's chunk coordinates
#subtracting one from the range lerp just makes sure that the chunk is actually changed when it's on
# the negative side.

func start_up(data):
	var world_Data = data["chunk_coords"]
	chunk_data = world_Data

func _get_player_chunk(pos):
	var chunk_pos = Vector2()
	chunk_pos.y = int(pos.y/chunk_size)
	chunk_pos.x = int(pos.x/chunk_size)
	if pos.x < 0:
		chunk_pos.x -= 1
	if pos.y < 0:
		chunk_pos.y -= 1
	return chunk_pos

#The render bound in the rect width of the render distance. ie render distance of 2
#will be multiplied by 2 to make it 4 the +1 which makes it 5, 5 chunks on the x and y axis with 
#a render distance of 2
func load_chunk():
	var render_bounds = (float(render_distance)*2.0)+1.0
	var loading_coord = []
	#if x = 0, then x+1 = 1
	#if render_bounds = 5 (render distance = 2) then 5/2 = 2.5, (round(2.5)) = 3
	#then 1 - 3 = -2 which is the x coord in the chunk space, this same principle is used
	#for the y axis as well.
	for x in range(render_bounds):
		for y in range(render_bounds):
			var _x  = (x+1) - (round(render_bounds/2.0)) + current_chunk.x
			var _y  = (y+1) - (round(render_bounds/2.0)) + current_chunk.y
			
			var chunk_coords = Vector2(_x, _y)
			#the chunk key is the key the chunk will use to retreive data from the world save
			#it depends on the no of revolutions and the chunk coords
			var chunk_key = _get_chunk_key(chunk_coords)
			loading_coord.append(chunk_coords)
			#loading chunks stores the coords that are in the new render chunk
			#this if statement makes sure that only the coords that are not already active are loaded\:
			if active_coord.find(chunk_coords) == -1 and chunk_data.has(var2str(chunk_coords)) and !loading_chunk.has(chunk_coords):

				var chunki 
				instance_location(chunk_coords, chunki, chunk_key, chunk_data[var2str(chunk_coords)])

#				chunki.start(chunk_key, chunk_data[var2str(chunk_coords)])
#				add_child(chunk)
	#deleting the chunks just makes an array of chunks that are in active chunks and not in the
	#chunks that are being loaded (loading coords), deleting chunks then deletes them from 
	#both the active chunk and coords array
	
	var deleting_chunks = []
	for x in active_coord:
		if loading_coord.find(x) == -1:
			deleting_chunks.append(x)
			

	for x in deleting_chunks:
		var index = active_coord.find(x)
		active_chunks[index].unload(self, index)

		
	chunk_loaded = true

#this converts the chunks coords to it's key....
#this is for the circumanigation thing
func _get_chunk_key(coords : Vector2):
	var key = coords
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance+1)
	return key
 
func instance_location(chunk_coord, _chunk, chunk_key, data) :
	var chunk_start_pos = chunk_coord * chunk_size
	var chunk_end_pos = Vector2(chunk_start_pos.x + (chunk_size / 2) , chunk_start_pos.y + (chunk_size / 2)  )
	
	var chunksrc = "res://Assets/scenes/locations/chunk.tscn"
	SceneLoader.load_scene_async_with_cb(self, chunksrc, chunk_end_pos, true, funcref(self, "load_c"), {"chunk_coord" : chunk_coord, "chunk_key" : chunk_key, "data" : data})
	loading_chunk.append(chunk_coord)


func load_c( path : String, instance : Node, pos : Vector2, is_pos_global : bool, data : Dictionary):
	instance.position = pos
	instance.start(data["chunk_key"], data["data"], self,data)
	add_child(instance)

