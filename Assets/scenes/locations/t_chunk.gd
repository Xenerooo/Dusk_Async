extends YSort


export var chunk_loaded : bool = false
var chunk_key

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


#func _draw():
#	draw_rect(Rect2(Vector2(-1500, -1500), Vector2(3000, 3000)), Color(rand_range(.5, 1.0), rand_range(.5, 1.0), rand_range(.5, 1.0)), false)
	
func unload():
	queue_free()

func start(_chunk_key, data):
	chunk_key = _chunk_key
	$Label.text = str("%s / %s" % [_chunk_key, data])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
