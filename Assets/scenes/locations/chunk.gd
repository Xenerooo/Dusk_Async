extends YSort



var chunk_key
var chunk_loaded : bool = false



func _ready():
	var chunk_floor = "res://Assets/scenes/floor.tscn"
	SceneLoader.load_scene_async_with_cb(self, chunk_floor, global_position, true, funcref(self, "load_chunk"), {})
#	SceneLoader.load_scene_sync(self, chunk_floor)
#	SceneLoader.load_scene_async(self, chunk_floor, global_position, true)

#	var chunk_floor = preload("res://Assets/scenes/floor.tscn").instance()
#	add_child(chunk_floor)
#
#	chunk_loaded = true

func _draw():
	draw_rect(Rect2(Vector2(-1500, -1500), Vector2(3000, 3000)), Color(rand_range(.5, 1.0), rand_range(.5, 1.0), rand_range(.5, 1.0)), false)

func unload(chunk_handler, index):
	if chunk_loaded :
		chunk_handler.active_chunks.remove(index)
		chunk_handler.active_coord.remove(index)
		queue_free()
	

func start(_chunk_key, datas, chunk_handler, data):
	chunk_key = _chunk_key
	chunk_handler.active_chunks.append(self)
	chunk_handler.active_coord.append(data["chunk_coord"])
	chunk_handler.loading_chunk.erase(data["chunk_key"] as Vector2)
	$Label.text = str("%s / %s" % [_chunk_key, datas])

func load_chunk( path : String, instance : Node, pos : Vector2, is_pos_global : bool, data : Dictionary):
	add_child(instance)
	
	chunk_loaded = true


