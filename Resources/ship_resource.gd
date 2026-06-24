extends Node3D
class_name ShipResource

var final_destination : SolarSystem
var destination : SolarSystem

var in_transmission:= false

func begin_transmission():
	if destination:
		in_transmission = true
		look_at(destination.position)
	
func end_transmission():
	in_transmission = false

func _process(delta: float) -> void:
	if destination and in_transmission:
		global_position = global_position.move_toward(destination.global_position, delta)
		if global_position == destination.global_position:
			destination.receive_resource(self)
