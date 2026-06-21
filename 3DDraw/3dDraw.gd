extends Node
#class_name Draw3D

const CONTAINER_PATH = ""

func draw_point(position : Vector3, size : float, resolution):
	var new_mesh = MeshInstance3D.new()
	

func draw_line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
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
	
	#get_tree().get_root().
	add_child(mesh_instance)
"""
func draw_elipse(center : Vector3, major_axis : float, minor_axis: float, rotation : float, resolution : float)
	for i in resolution:
		var.position = rotation*Vector3(major_axis*cos(current_orbit), 0, p.planet_data.minor_orbit_radius*sin(current_orbit))
"""
