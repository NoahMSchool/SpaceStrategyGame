class_name SolarSystemData
extends Resource

@export var star_type : StarType
var resources : Array[ShipResource]

func _init(_startype : StarType) -> void:
	self.star_type = _startype
	
	self.resources = []
	var start_resource = ShipResource.new()
