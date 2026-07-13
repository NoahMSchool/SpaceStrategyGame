class_name StarAStar3D
extends AStar3D

@export var max_distance = 25
@export var team_id = 0

func is_filtered(from_id: int, neighbor_id: int):
	if is_point_disabled(from_id) or is_point_disabled(neighbor_id):
		return true
	var from_star = instance_from_id(from_id)
	var to_star = instance_from_id(neighbor_id)
	if not (from_star.team_ownership or to_star.team_ownership):
		return true
	if from_star.team_ownership.team_id != team_id and to_star.team_ownership.id != team_id:
		return true
	
	var distance = from_star.global_position.distance_to(to_star.global_position)
	#if greatern than max distance filter 
	return distance > max_distance
	
func _filter_neighbor(from_id: int, neighbor_id: int) -> bool:
	return is_filtered(from_id, neighbor_id)

	
