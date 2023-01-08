extends KinematicBody2D



export (NodePath) var joystickLeftPath
onready var joystickLeft : VirtualJoystick = get_node(joystickLeftPath)

export var speed : float = 100

#export (NodePath) var joystickRightPath
#onready var joystickRight : VirtualJoystick = get_node(joystickRightPath)

#func _process(delta: float) -> void:
#	# Movement using the joystick output:
#	if joystickLeft and joystickLeft.is_pressed():
#		position += joystickLeft.get_output() * speed * delta
	
#	# Movement using Input functions:
#	var move := Vector2.ZERO
#	move.x = Input.get_axis("ui_left", "ui_right")
#	move.y = Input.get_axis("ui_up", "ui_down")
#	position += move * speed * delta


func _physics_process(delta):
	if joystickLeft and joystickLeft.is_pressed():
		move_and_slide(joystickLeft.get_output() * speed  )
	$UI/Label.text = str(Engine.get_frames_per_second())
