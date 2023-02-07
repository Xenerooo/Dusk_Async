extends YSort



var chunk_key
var chunk_loaded : bool = false

var chunk_handler
var chunk_data

func _ready():
	AThreadPool.connect("task_finished", self, "thread_pool_finished")
	AThreadPool.submit_task_unparameterized(self, "ready_chunk", self)
#	SceneLoader.load_scene_async_with_cb(self, chunk_floor, global_position, true, funcref(self, "load_chunk"), {})
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
	

func start(_chunk_key, datas, _chunk_handler, data):
#	print(data)
	chunk_key = _chunk_key
	_chunk_handler.active_chunks.append(self)
	_chunk_handler.active_coord.append(data["chunk_coord"])
#	_chunk_handler.loading_chunk.erase(data["chunk_key"] as Vector2)
	chunk_handler = _chunk_handler
	$Label.text = str("%s / %s" % [_chunk_key, datas])

func load_chunk( path : String, instance : Node, pos : Vector2, is_pos_global : bool, data : Dictionary):
	pass

func ready_chunk(): 
	var instance = preload("res://Assets/scenes/floor.tscn").instance()
	add_child(instance)
	
	

func thread_pool_finished(task):
	if task == self :
		chunk_loaded = true
		chunk_handler.loading_chunk.erase(chunk_key as Vector2)
