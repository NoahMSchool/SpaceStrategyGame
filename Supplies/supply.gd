extends Resource
class_name Supply

@export var supply_name : String
@export var supply_mesh : Mesh

func _init(_supply_name : String, _supply_mesh: Mesh):
	self.supply_name = _supply_name
	self.supply_mesh = _supply_mesh
	
