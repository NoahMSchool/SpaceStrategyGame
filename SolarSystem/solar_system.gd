extends Node3D
class_name SolarSystem

var hovering = false


var system_data : SolarSystemData

var system_active = false: 
	set(value):
		system_active = value
		update_system_activation()

var planets : Array[Planet] = []
signal selected(node_selected : Node3D)

const PLANET = preload("res://Planet/planet.tscn")
const BREAD_CRUMB = preload("res://bread_crumb.tscn")

func _ready() -> void:
	generate_system()
	$ViewPoint.position = Vector3(0,0.5+system_data.star_type.star_size,0)
	#$ViewPoint.position = Vector3.ZERO

	system_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if system_active:
		orbit_planets(delta)
	
	if hovering:
		#$SelectionMesh.visible = true
		hovering = false
	else:
		pass
		#$SelectionMesh.visible = false
				

func update_system_activation():
	#print("setting system activation to ", system_active)
	if system_active:
		$PlanetContainer.visible = true
		$TrailContainer.visible = true
		$SelectionSphere.disabled = true
		$SunMesh.scale = Vector3.ONE * system_data.star_type.star_size
	else: 
		$PlanetContainer.visible = false
		$TrailContainer.visible = false
		$SelectionSphere.disabled = false
		$SunMesh.scale = Vector3.ONE * system_data.star_type.observer_star_size
		
func _mouse_selected(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	hovering = true
	if Input.is_action_just_pressed("LeftMouse"):
		selected.emit(self)

func pick_weighted_startype() -> StarType:
	var total_weight_sum : float = 0.0
	for st in SpaceInfo.startypes:
		total_weight_sum += st.prob_weight
	var random_num = randf_range(0,total_weight_sum)
	for st in SpaceInfo.startypes:
		random_num -= st.prob_weight
		if random_num<=0:
			return st
	return SpaceInfo.startypes[0]

func generate_system():
	system_data = SolarSystemData.new(pick_weighted_startype())
	system_data.star_type = pick_weighted_startype()
	$SunMesh.material_override = system_data.star_type.star_mat
	$SunMesh.scale = Vector3.ONE*system_data.star_type.star_size
	
	var planet_count = randi_range(system_data.star_type.planet_range[0],system_data.star_type.planet_range[1])
	#print(planet_count)
	var orbit_radius : float = system_data.star_type.star_size
	for i in planet_count:
		
		var planet_radius = randf_range(SpaceInfo.PLANET_SIZE_RANGE[0], SpaceInfo.PLANET_SIZE_RANGE[1])
		var new_planet = PLANET.instantiate()
		
		var planet_color = SpaceInfo.PLANET_COLORS.pick_random()
		var orbit_period = randf_range(10, 50)
		var orbit_eccentricity = randf()*0.3
		
		orbit_radius += randf_range(SpaceInfo.PLANET_SIZE_RANGE[0], SpaceInfo.PLANET_SIZE_RANGE[1])+planet_radius*2
		orbit_radius += orbit_radius*(1-sqrt(1-orbit_eccentricity**2)) #If neccesary add difference between new major axis and minor axis
		orbit_radius = orbit_radius #ceilf
		print("o", orbit_radius)
		var new_orbit_basis = Basis(Vector3.UP, randf_range(0,TAU))
		#_planet_radius : float, _planet_color : Color, _major_orbit_radius : float, _orbit_basis : float, _orbit_period : float, _orbit_eccentricity : float
		var new_planet_data = PlanetData.new(planet_radius, planet_color, orbit_radius, new_orbit_basis, orbit_period, orbit_eccentricity)
		new_planet.planet_data = new_planet_data
		
		#new_planet.position.x = new_planet.planet_data.orbit_radius
		planets.append(new_planet)
		
		$PlanetContainer.add_child(new_planet)
		new_planet.update_planet()

#use ecentricity to make eliptical orbits
func orbit_planets(delta):
	for p in self.planets:
		p.planet_data.orbit_angle = p.planet_data.orbit_angle + p.planet_data.angular_velocity*delta
		var current_orbit = p.planet_data.orbit_angle
	
		p.position = p.planet_data.orbit_basis*Vector3(p.planet_data.major_orbit_radius*cos(current_orbit), 0, p.planet_data.minor_orbit_radius*sin(current_orbit))


"""
For Star

make more of these ranges
add brightness
not using planet range currently



print("before")
		var new_planet_trail_mesh = TubeTrailMesh.new()
		var new_planet_trail_mesh_curve = Curve3D.new()
		new_planet_trail_mesh.curve = new_planet_trail_mesh_curve
		assert(new_planet_trail_mesh_curve == new_planet_trail_mesh.curve)
		print(new_planet_trail_mesh.curve)
		new_planet_trail_mesh.radius = 0.05
		new_planet_trail_mesh.material = load("res://Stars/bluewhitestar.tres")
		
		var new_planet_trail : Node3D = MeshInstance3D.new()
		new_planet_trail.mesh = new_planet_trail_mesh
		new_planet.trail = new_planet_trail
		$TrailContainer.add_child(new_planet_trail)

p.trail.mesh.curve.add_point(p.position)
		
"""


func _on_trail_timer_timeout() -> void:
	if not system_active:
		return
	for p in planets:
		var new_bread_crumb = BREAD_CRUMB.instantiate()
		new_bread_crumb.ttl = p.planet_data.orbit_period
		new_bread_crumb.position = p.position
		#print(new_bread_crumb.position)
		$TrailContainer.add_child(new_bread_crumb)
	$TrailTimer.start()
