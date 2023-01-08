extends YSort

onready var interior = $house/interior
onready var exterior = $house/exterior

onready var area_detection = $house/area_detection

onready var tween = get_node("Tween")

func _ready(): 
	interior.show()
	exterior.show()
	
	
	

func _on_area_detection_body_entered(body):
	if body.is_in_group("survivor") :
		tween.interpolate_property(exterior, "modulate", exterior.modulate, Color(1,1,1,0), .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		


func _on_area_detection_body_exited(body):
	if body.is_in_group("survivor"):

		tween.interpolate_property(exterior, "modulate", exterior.modulate, Color(1,1,1,1), .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()

