extends Node
#class_name Draw3D

const CONTAINER_PATH = "/root/Galaxy/3DDraw"
const BREAD_CRUMB = preload("res://3DDraw/bread_crumb.tscn")

func draw_point_mesh(pos : Vector3, ttl : float): #, size : float, resolution, 
	var new_mesh = MeshInstance3D.new()
	var new_bread_crumb = BREAD_CRUMB.instantiate()
	new_bread_crumb.ttl = ttl
	new_bread_crumb.position = pos
	#print(new_bread_crumb.position)
	#get_tree().get_root().
	get_node(CONTAINER_PATH).add_child(new_bread_crumb)
	

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
"""
func draw_elipse(center : Vector3, major_axis : float, minor_axis: float, rotation : float, resolution : float)
	for i in resolution:
		var.position = rotation*Vector3(major_axis*cos(current_orbit), 0, p.planet_data.minor_orbit_radius*sin(current_orbit))
"""
