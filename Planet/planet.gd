extends Node3D
class_name Planet

#var building : Building
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var planetMatTemplate : StandardMaterial3D = preload("res://Planet/planetmattemp.tres")
@export var planet_data : PlanetData
var trail : Node3D

func _ready() -> void:
	pass


func update_planet():
	self.mesh.scale = Vector3.ONE * planet_data.planet_radius

	var new_material = planetMatTemplate.duplicate()    
	var chosen_color = planet_data.planet_color

	new_material.albedo_color = chosen_color
	new_material.emission = chosen_color

	mesh.material_override = new_material
