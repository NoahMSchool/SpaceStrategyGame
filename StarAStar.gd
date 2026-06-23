class_name StarAStar3D
extends AStar3D

@export var max_distance = 25

func _filter_neighbor(from_id: int, neighbor_id: int) -> bool:
	var from_star = instance_from_id(from_id)
	var to_star = instance_from_id(neighbor_id)
	
	var distance = from_star.global_position.distance_to(to_star.global_position)
	#if greatern than max distance filter 
	return distance > max_distance
	
