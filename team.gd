extends Resource
class_name Team

const GENERAL_NON_REFLECTIVE_MATERIAL = preload("uid://cq6eyojy1lnw8")

var team_id : int
var team_name : String
var team_color : Color
var team_mat : Material

var start_system : SolarSystem
var controlled_systems = [SolarSystem]
var algorithm : StarAStar3D

func _init(_team_id, _team_name: String, _team_color : Color) -> void:
	team_id = _team_id
	team_name = _team_name
	team_color = _team_color
	team_mat = GENERAL_NON_REFLECTIVE_MATERIAL.duplicate()
	team_mat.albedo_color = team_color
