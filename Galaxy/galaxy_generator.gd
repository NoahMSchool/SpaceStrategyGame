extends Node3D

const SYSTEM = preload("res://SolarSystem/solar_system.tscn")


#in lightyears, typical solar systems are 5-10 apart
@export var min_system_separation = 7.5
@export var max_system_count = 10
@export var max_connection_distance = 15 : 
	set (val):
		print("Changing Max Connection to", val)
		max_connection_distance = val
		algo = make_astar_algorithm(max_connection_distance)
		draw_algorithm_lines(algo)

#const galaxy_radius = 100
@export var disc_height = 10

var target_system : SolarSystem = null:
	set(value):
		target_system = value
		if target_system:
			$TargetIndicator.position = target_system.position
			$TargetIndicator.visible = true

#var current_team : Team = null
var systems : Array[SolarSystem] = []
var root_system : SolarSystem
var algo : StarAStar3D

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
	
	#print(system_positions.size())
	for i in range(system_positions.size()-1):
		var sp = system_positions[i]
		var new_system = SYSTEM.instantiate()
		$SystemContainer.add_child(new_system)
		new_system.position = sp
		new_system.rotation = Vector3.ZERO
		new_system.name = "System" + str(i)
		systems.append(new_system)
		
	if systems.size()>0:
		target_system = systems[0]
	
	algo = make_astar_algorithm(max_connection_distance)
	draw_algorithm_lines(algo)

func draw_algorithm_lines(algo: StarAStar3D):
	Draw3D.delete_planet_lines()
	var algo_points = algo.get_point_ids()
	for p1 in algo_points:
		var p1_pos = algo.get_point_position(p1)
		var p1_connections = algo.get_point_connections(p1)
		for p2 in p1_connections:
			var p2_pos = algo.get_point_position(p2)
			if not algo.is_filtered(p1, p2):
				Draw3D.draw_line(p1_pos, p2_pos)
	
func make_astar_algorithm(max_distance):
	var new_algo := StarAStar3D.new()
	#print("Generating with max ", max_distance, " and systems ", systems.size())
	if !systems.size():
		return new_algo
		
	new_algo.set_neighbor_filter_enabled(true)
	new_algo.team_id = 2
	new_algo.max_distance = max_distance
	for sys in systems:
		var id = sys.get_instance_id()
		new_algo.add_point(id, sys.position)	
	for sys1 in systems:
		for sys2 in systems:
			if sys1 != sys2:
				new_algo.connect_points(sys1.get_instance_id(), sys2.get_instance_id())
	return new_algo

func set_system_disabled(sys: SolarSystem, disabled: bool = true):
	algo.set_point_disabled(sys.get_instance_id(), disabled)
	print("Setting disabled ", disabled, " on system ", sys)
	draw_algorithm_lines(algo)
func get_next_step(from, to):
	var next = null
	if from and to and from != to:
		var path = algo.get_id_path(from.get_instance_id(), to.get_instance_id())
		if path and path.size() > 1:
			next = instance_from_id(path[1])
	return next


func add_free_ship(ship_node, global_pos = null):
	$FreeShipContiner.add_child(ship_node)
	if global_pos:
		ship_node.global_position = global_pos
	
func detach_free_ship(ship_node):
	$FreeShipContiner.remove_child(ship_node)
	
	
func _process(delta: float) -> void:
	pass
