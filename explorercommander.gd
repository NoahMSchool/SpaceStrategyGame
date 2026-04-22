extends Node3D

var orbit_sens = 0.0025
var pan_sens = 0.001
var last_mouse_pos := Vector2.ZERO

@onready var cam : Camera3D = $Camera3D

var last_explorer_angle := Vector3(0,0,0)
var last_birdseye_camsize := 25
#enum commander_modes{
#	EXPLORER,
#	BIRDSEYE
#}


#var commander_style := commander_modes.BIRDSEYE
var birdseyecommander := true:
	set(value):
		birdseyecommander = value
		update_commander_cam()

var current_system = null

func _ready() -> void:
	update_commander_cam()
	await get_tree().process_frame
	for s in get_tree().get_nodes_in_group("Selectable"):
		s.connect("selected", select_system)

func _process(delta: float) -> void:
	#Orbiting
	var mouse_pos = get_viewport().get_mouse_position()
	var delta_mouse = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
	if birdseyecommander:
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
	else:
		if Input.is_action_pressed("RightMouse"):
			rotation.y -= delta_mouse.x*orbit_sens
			rotation.x -= delta_mouse.y*orbit_sens
			rotation.x = clamp(rotation.x, -3*PI/4, 3*PI/8)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("s"):
		if birdseyecommander:
			birdseyecommander = false
		else:
			birdseyecommander = true

		
func move_system(system_node : Node3D):
	print("from : ", current_system)
	print("to : ", system_node)
	
	if current_system:
		current_system.system_active = false
	current_system = system_node
	system_node.system_active = true
	if birdseyecommander:
		pass
	else:
		to_current_system_viewpoint()

func to_current_system_viewpoint():
	var system_viewpoint = current_system.get_node_or_null("ViewPoint")
	if system_viewpoint:
		global_position = system_viewpoint.global_position

func select_system(system : Node3D):
	move_system(system)
	

func update_commander_cam():
	if birdseyecommander:
		last_explorer_angle = rotation
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = last_birdseye_camsize
		
		global_position.y = 15
		rotation.x = -90
		rotation = Vector3(-90,0,0)
	else:
		last_birdseye_camsize = cam.size
		cam.projection = Camera3D.PROJECTION_PERSPECTIVE
		rotation = last_explorer_angle
		to_current_system_viewpoint()
