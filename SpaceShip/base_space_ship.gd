extends Node3D

class_name BaseSpaceShip

var final_destination_system : SolarSystem

var last_system : SolarSystem = null
var next_system : SolarSystem = null #last and next system only used in reversing difrection (also origin position)


var ship_transmission_speed = 2 #used in transmissions
var ship_max_speed = 3.5 #only used for short bursts when ship moves off path and must catch up
var lock_ship_pos_to_target = false

var pos_last_frame:= Vector3(0,0,0)

#General transmission
var target_position : Vector3 #decide whether target position can replace in transmission
var origin_poisition : Vector3 #just used for reversing direction
var in_transmission:= false
var call_on_finished : Callable
signal target_reached

var follow_position : Vector3

var team : Team

func send_to_position(pos):
	origin_poisition = global_position
	target_position = pos
	#print("sending to ", target_position)
	begin_transmission()

func begin_transmission():
	in_transmission = true
	look_at(target_position)
	print("begining_transmisison")

func end_transmission():
	print("ending_transmission")
	in_transmission = false
	#print("emmiting")
	#print("finished sending")
	target_reached.emit(self)

func revert_transmission():
	var temp = target_position
	target_position = origin_poisition
	origin_poisition = temp

func set_lock_to_target(value : bool):
	lock_ship_pos_to_target = value

func _process(delta: float) -> void: 
	#if target_position:
		#$DebugSphereRed.visible = true
		#$DebugSphereRed.global_position = target_position
	#else:
		#$DebugSphereRed.visible = false
	#$DebugSphereBlue.global_position = follow_position
	#print(global_position.round(), follow_position.round(), target_position.round())
	$DebugSphereBlue.global_position = follow_position
	if in_transmission:
		pos_last_frame = follow_position
		follow_position = follow_position.move_toward(target_position, delta*ship_transmission_speed)
		if follow_position == target_position and pos_last_frame != target_position: #follow position is being used to determine when transmission finished (also affects 2 lines prior)
			end_transmission()
			
	look_at(follow_position)
	if lock_ship_pos_to_target:
		global_position = follow_position
	else:
		global_position = global_position.move_toward(follow_position, ship_max_speed*delta)
