extends Node3D


@onready var cam : Camera3D = $Camera3D

var pan_sens = 0.001
var last_mouse_pos := Vector2.ZERO

var current_system = null

func _ready() -> void:
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 25

	global_position = Vector3(0,15,0)
	rotation.x = -90


func _process(delta: float) -> void:
	#Orbiting
	var mouse_pos = get_viewport().get_mouse_position()
	var delta_mouse = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
	
	if Input.is_action_pressed("RightMouse"):
		global_position.z -= delta_mouse.y*pan_sens*cam.size
		global_position.x -= delta_mouse.x*pan_sens*cam.size
	
	if Input.is_action_just_pressed("ScrollUp"):
		cam.size+=1
		cam.size = clampi(cam.size, 5, 50)
	if Input.is_action_just_pressed("ScrollDown"):
		cam.size-=1
		cam.size = clampi(cam.size, 1, 50)
	if Input.is_action_just_pressed("MouseWheelClick"):
		cam.size = 25
		
		

"""
if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
"""
