extends Node3D

var orbit_sens = 0.0025
var last_mouse_pos := Vector2.ZERO

var current_system = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	for s in get_tree().get_nodes_in_group("Selectable"):
		s.connect("selected", select_system)

func _process(delta: float) -> void:
	#Orbiting
	var mouse_pos = get_viewport().get_mouse_position()
	var delta_mouse = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
		
	if Input.is_action_pressed("RightMouse"):
		rotation.y -= delta_mouse.x*orbit_sens
		rotation.x -= delta_mouse.y*orbit_sens
		rotation.x = clamp(rotation.x, -3*PI/4, 3*PI/8)

func move_system(system_node : Node3D):
	print("from : ", current_system)
	print("to : ", system_node)
	
	if current_system:
		current_system.system_active = false
	current_system = system_node
	var system_viewpoint = system_node.get_node_or_null("ViewPoint")
	system_node.system_active = true
	if system_viewpoint:
		global_position = system_viewpoint.global_position
	

func select_system(system : Node3D):
	move_system(system)
