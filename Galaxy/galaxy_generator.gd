extends Node3D

const SYSTEM = preload("res://SolarSystem/solar_system.tscn")


#in lightyears, typical solar systems are 5-10 apart
const min_system_separation = 25
const max_system_count = 25

const galaxy_radius = 100
const disc_height = 10

var systems : Array[SolarSystem] = []

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
		var height = randf_range(-disc_height, disc_height)
		var angle = randf_range(0, 2*PI)
		var dir = Vector3(cos(angle), 0, sin(angle))
		var distance = 0
		var found := false
		var pos : Vector3
		var attempt = 0
		while not found:
			attempt +=1
			distance +=randf_range(0,min_system_separation)*attempt
			pos = dir*distance
			found = true
			for sp in system_positions:
				if pos.distance_to(sp) < min_system_separation:
					found = false
					break
				
		pos += Vector3(0,height,0)
		system_positions.append(pos)
	
	
	
	for sp in system_positions:
		var new_system = SYSTEM.instantiate()
		add_child(new_system)
		new_system.position = sp
		systems.append(new_system)
	


func _process(delta: float) -> void:
	pass
