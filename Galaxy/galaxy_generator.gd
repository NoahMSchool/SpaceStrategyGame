extends Node3D

const SYSTEM = preload("res://SolarSystem/solar_system.tscn")


#in lightyears, typical solar systems are 5-10 apart
@export var min_system_separation = 7.5
@export var max_system_count = 15
@export var max_connection_distance = 15 : 
	set (val):
		print("Changing Max Connection to", val)
		max_connection_distance = val
		algo = set_up_astar(max_connection_distance)

		
	

#const galaxy_radius = 100
@export var disc_height = 10

var systems : Array[SolarSystem] = []
var root_system : SolarSystem
var algo := StarAStar3D.new()

func _ready() -> void:
	#get positions
	var system_positions = []
	#Type One
	"""
	for i in range(max_system_count):
		var attempts = 0
		var found = false
		while not found and attempts<10:
			var pos : Vector3
			var dis = randf()*galaxy_radius
			var dir = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
			).normalized()
			pos = dis*dir
			
			found = true
			for sp in system_positions:
				if pos.distance_to(sp) < min_system_separation:
					found = false
			if found:
				system_positions.append(pos)
		"""
	#Generation Two, 
	for i in range(max_system_count):
		var height = randf_range(-disc_height/2, disc_height/2)
		var angle = randf_range(0, 2*PI)
		var dir = Vector3(cos(angle), 0, sin(angle))
		var distance = 0
		var found := false
		var pos : Vector3
		var attempt = 0
		while not found:
			attempt +=1
			distance +=randf_range(0,min_system_separation)#*attempt
			pos = dir*distance
			pos += Vector3(0,height,0)#put this later to not factor height into distance checks
			found = true
			for sp in system_positions:
				if pos.distance_to(sp) < min_system_separation:
					found = false
					break
				
		system_positions.append(pos)
	
	print(system_positions.size())
	for sp in system_positions:
		var new_system = SYSTEM.instantiate()
		$SystemContainer.add_child(new_system)
		new_system.position = sp
		new_system.rotation = Vector3.ZERO
		systems.append(new_system)
		
	algo = set_up_astar(max_connection_distance)
	
		
func set_up_astar(max_distance):
	var new_algo := StarAStar3D.new()
	print("Generating with max ", max_distance, " and systems ", systems.size())

	if (!systems.size()):
		return new_algo
		

	new_algo.set_neighbor_filter_enabled(true)
	new_algo.max_distance = max_distance
	for sys in systems:
		var id = sys.get_instance_id()
		new_algo.add_point(id, sys.position)
	
	Draw3D.delete_planet_lines()
	for sys1 in systems:
		for sys2 in systems:
			if sys1 != sys2:
				new_algo.connect_points(sys1.get_instance_id(), sys2.get_instance_id())
				if sys1.position.distance_to(sys2.position)<max_distance:
					Draw3D.draw_line(sys1.position,sys2.position)
	print("We have systems ", systems.size())
	var path = new_algo.get_id_path(systems[0].get_instance_id(), systems[2].get_instance_id())
	
	print(path)
	return new_algo

	
func _process(delta: float) -> void:
	pass
