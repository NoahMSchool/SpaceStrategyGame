class_name StarAStar3D
extends AStar3D

@export var max_distance = 25
@export var team = 1

func is_filtered(from_id: int, neighbor_id: int):
	if is_point_disabled(from_id) or is_point_disabled(neighbor_id):
		return true
	var from_star = instance_from_id(from_id)
	var to_star = instance_from_id(neighbor_id)
	if from_star.team != team and to_star.team != team:
		return true
	
	var distance = from_star.global_position.distance_to(to_star.global_position)
	#if greatern than max distance filter 
	return distance > max_distance
	
func _filter_neighbor(from_id: int, neighbor_id: int) -> bool:
	return is_filtered(from_id, neighbor_id)

	
