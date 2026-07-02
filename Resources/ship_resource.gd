extends Node3D
class_name ShipResource

#system tramsmission
var final_destination_system : SolarSystem
var destination_system : SolarSystem
var ship_speed = 2
var destination_relative : Vector3 = Vector3(0,0,0)

var pos_last_frame:= Vector3(0,0,0)

#General transmission
var target_position : Vector3
var in_transmission:= false
signal target_reached

func send_to_destination_system(sys):
	#if destination_system:
		send_to_position(sys.global_position+destination_relative)
		#target_position = destination_system.global_position#+destination_relative
		#begin_transmission()
		
func send_to_position(pos):
	target_position = pos
	print("sending to ", target_position)
	begin_transmission()

func begin_transmission():
	in_transmission = true
	look_at(target_position)

func end_transmission():
	in_transmission = false
	target_reached.emit()
	print("finished sending")
	#if destination_system:
	#	destination_system.process_resource(self)
		
func _process(delta: float) -> void:
	if in_transmission:
		pos_last_frame = global_position
		global_position = global_position.move_toward(target_position, delta*ship_speed)
		if global_position == target_position and pos_last_frame != target_position:
			end_transmission()
