extends Node3D
class_name Planet

#var building : Building
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var planetMatTemplate : StandardMaterial3D = preload("res://Planet/planetmattemp.tres")
@onready var planetShaderMatTemplate : ShaderMaterial = preload("res://Planet/planetshadermaterial.tres")
var planet_primary : Color
var planet_secondary : Color
var planet_tertiary : Color
var planet_color_texture : Texture2D
var planet_roughness_texture : Texture2D
@export var planet_data : PlanetData
var trail : Node3D

func _ready() -> void:
	pass


func update_planet():
	self.mesh.scale = Vector3.ONE * planet_data.planet_radius

	#var new_material = planetMatTemplate.duplicate()    
	#var chosen_color = planet_data.planet_color
#
	#new_material.albedo_color = chosen_color
	#new_material.emission = chosen_color
#
	#mesh.material_override = new_material
	#
	var new_shader_material = planetShaderMatTemplate.duplicate()
	planet_primary = SpaceInfo.PLANET_PRIMARIES.pick_random()
	planet_secondary = SpaceInfo.PLANET_SECONDARIES.pick_random()
	planet_tertiary = SpaceInfo.PLANET_TERTIARIES.pick_random()
	var planet_texture_index = randi_range(0, SpaceInfo.PLANET_TEXTURES.size()-1)
	planet_color_texture = SpaceInfo.PLANET_TEXTURES[planet_texture_index][0]
	planet_roughness_texture = SpaceInfo.PLANET_TEXTURES[planet_texture_index][1]
	if planet_color_texture:
		new_shader_material.set_shader_parameter("primary", planet_primary)
		new_shader_material.set_shader_parameter("secondary", planet_secondary)
		new_shader_material.set_shader_parameter("tertiary", planet_tertiary)
		new_shader_material.set_shader_parameter("color_texture", planet_color_texture)
	if planet_roughness_texture:
		new_shader_material.set_shader_parameter("roughness_textures", planet_roughness_texture)
	
	mesh.material_override = new_shader_material
	
