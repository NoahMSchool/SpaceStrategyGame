class_name SolarSystemData
extends Resource

@export var star_type : StarType

func _init(_startype : StarType) -> void:
	self.star_type = _startype
