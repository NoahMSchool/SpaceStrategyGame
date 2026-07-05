extends Node3D
class_name ShipResource

var final_destination_system : SolarSystem
var destination_relative : Vector3 = Vector3(0,0,0)
var ship_transmission_speed = 2 #used in transmissions
var ship_max_speed = 3 #only used for short bursts when ship moves off path and must catch up
var lock_ship_pos_to_target = false

var pos_last_frame:= Vector3(0,0,0)

#General transmission
var target_position : Vector3
var in_transmission:= false
signal target_reached
func _ready() -> void:
	$TransportShip.global_position = global_position


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

		
func _process(delta: float) -> void:
	if in_transmission:
		pos_last_frame = global_position
		global_position = global_position.move_toward(target_position, delta*ship_transmission_speed)
		if global_position == target_position and pos_last_frame != target_position:
			end_transmission()
	if lock_ship_pos_to_target:
		$TransportShip.global_position = global_position
	else:
		$TransportShip.look_at(global_position)
		$TransportShip.global_position = $TransportShip.global_position.move_toward(global_position, ship_max_speed*delta)
