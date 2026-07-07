class_name SolarSystemData
extends Resource

@export var star_type : StarType
var supplies : Array[Supply]

func _init(_startype : StarType) -> void:
	self.star_type = _startype
	
	self.supplies = []
	var start_supply = Supply.new("dog", null)
