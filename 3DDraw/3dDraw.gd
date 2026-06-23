extends Node
#class_name Draw3D

const CONTAINER_PATH = "/root/Galaxy/3DDraw"
const BREAD_CRUMB = preload("res://3DDraw/bread_crumb.tscn")

func draw_point_mesh(pos : Vector3, ttl : float): #, size : float, resolution, 
	#var new_mesh = MeshInstance3D.new()
	var new_bread_crumb = BREAD_CRUMB.instantiate()
	new_bread_crumb.ttl = ttl
	new_bread_crumb.position = pos
	get_node(CONTAINER_PATH).add_child(new_bread_crumb)

func delete_planet_lines():
	var parent = get_node(CONTAINER_PATH)
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()

func draw_line(pos1: Vector3, pos2: Vector3, color = Color("#333333", 0.2)):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	get_node(CONTAINER_PATH).add_child(mesh_instance)

func draw_elipse(center : Vector3, major_axis : float, minor_axis: float, rotation : Basis, resolution : float, color = Color.FIREBRICK):
	var positions = []
	for i in resolution+1:
		var angle = 2*PI*i/resolution
		var position = center + Vector3(major_axis*cos(angle), 0, minor_axis*sin(angle))
		Draw3D.draw_point_mesh(position, 100)
		positions.append(position)
	
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for pos in positions:
		immediate_mesh.surface_add_vertex(pos)
		
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return mesh_instance
	#get_node(CONTAINER_PATH).add_child(mesh_instance)
	
	
