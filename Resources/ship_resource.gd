extends Node3D
class_name ShipResource

var destination : SolarSystem

func _process(delta: float) -> void:
	if destination:
		global_position = global_position.move_toward(destination.global_position, delta)
