extends Node3D
class_name SolarSystem

enum TEAM {NEUTRAL, RED, BLUE, GREEN}

var team_ownership = TEAM.NEUTRAL:
	set(value):
		team_ownership = value
		match value:
			TEAM.NEUTRAL:
				visual_indicator.visible = false
			TEAM.BLUE:
				visual_indicator.visible = true
				visual_indicator.set_surface_override_material(0,BLUE_MATERIAL)
			TEAM.RED:
				visual_indicator.visible = true
				visual_indicator.set_surface_override_material(0,RED_MATERIAL)
			TEAM.GREEN:
				visual_indicator.visible = true
				visual_indicator.set_surface_override_material(0,GREEN_MATERIAL)
		

const BLUE_MATERIAL = preload("res://OtherMaterials/blue_material.tres")
const GREEN_MATERIAL = preload("res://OtherMaterials/green_material.tres")
const RED_MATERIAL = preload("res://OtherMaterials/red_material.tres")

var hovering = false

var path_globally_blocked = false: #Remove lateer for testing
	set(value):
		path_globally_blocked = value
		$DisabledIndicator.visible = path_globally_blocked
		galaxy.set_system_disabled(self, path_globally_blocked)

@onready var visual_indicator: MeshInstance3D = $VisualIndicator

const BREAD_CRUMB = preload("res://3DDraw/bread_crumb.tscn")
const RESOURCE_SHIP = preload("res://SpaceShip/resource_ship.tscn")

var system_data : SolarSystemData
var orbit_direction = 1
var unit_orbit_time = 40 #time a body 1 unit away will orbit in

var system_action_region_radius : float

var system_active = false: 
	set(value):
		system_active = value
		update_system_activation()

var planets : Array[Planet] = []
signal selected(node_selected : Node3D)

const PLANET = preload("res://Planet/planet.tscn")

@onready var galaxy = get_tree().current_scene
func _ready() -> void:
	generate_system()
	$ViewPoint.position = Vector3(0,0.5+system_data.star_type.star_size,0)
	#$ViewPoint.position = Vector3.ZERO

	system_active = false

func _process(delta: float) -> void:
	if system_active:
		orbit_planets(delta)
	orbit_resources(delta)
	
	if hovering:
		#$SelectionMesh.visible = true
		hovering = false
	else:
		pass
		#$SelectionMesh.visible = false
				
func get_viewpoint():
	return get_node_or_null("ViewPoint")

func update_system_activation():
	#print("setting system activation to ", system_active)
	if system_active:
		$PlanetContainer.visible = true
		$TrailContainer.visible = true
		$SelectionArea/SelectionSphere.disabled = true
		$SunMesh.scale = Vector3.ONE * system_data.star_type.star_size
	else: 
		$PlanetContainer.visible = false
		$TrailContainer.visible = false
		$SelectionArea/SelectionSphere.disabled = false
		$SunMesh.scale = Vector3.ONE * system_data.star_type.observer_star_size
		
func _mouse_selected(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#hovering = true
	#if Input.is_action_just_pressed("LeftMouse"):
		selected.emit(self)
		print("selected")


func _input(event: InputEvent) -> void:
	if system_active && Input.is_action_just_pressed("r"):
		print("Generating Resource")
		generate_resource()
		
	if Input.is_action_just_pressed("m"):
		for r in $ShipResourceContainer.get_children():
			eject_resource(r)
			
	if Input.is_action_just_pressed("a"):
		print("Toggle auto time to ", !$ResourceTimer.paused)
		$ResourceTimer.paused = !$ResourceTimer.paused
		
	if Input.is_action_just_pressed("z") and system_active:
		team_ownership = (team_ownership+1)%4 #hardcoded possibilities
		
	if Input.is_action_just_pressed("x") and system_active:
		path_globally_blocked = not path_globally_blocked
		
	if Input.is_action_just_pressed("t") and system_active:
		galaxy.target_system = self
			
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
	$StarLight.light_color = system_data.star_type.star_mat.get_shader_parameter("star_color")
	$SunMesh.scale = Vector3.ONE*system_data.star_type.star_size
	orbit_direction = [-1,1].pick_random()
	var planet_count = randi_range(system_data.star_type.planet_range[0],system_data.star_type.planet_range[1])
	#print(planet_count)
	var orbit_radius : float = system_data.star_type.star_size
	for i in planet_count:
		
		var planet_radius = randf_range(SpaceInfo.PLANET_SIZE_RANGE[0], SpaceInfo.PLANET_SIZE_RANGE[1])*0.5 #planet mesh import has radius 2
		var new_planet = PLANET.instantiate()
		new_planet.name = "Planet" + str(i)
		var planet_color = SpaceInfo.PLANET_COLORS.pick_random()
		var orbit_eccentricity = randf()*0.5
		
		orbit_radius += randf_range(SpaceInfo.PLANET_SIZE_RANGE[0], SpaceInfo.PLANET_SIZE_RANGE[1])+planet_radius*2 #this is the major axis
		orbit_radius += orbit_radius*(1-sqrt(1-orbit_eccentricity**2)) #If neccesary add difference between new major axis and minor axis
		orbit_radius = orbit_radius #ceilf
		var orbit_period = unit_orbit_time*pow(orbit_radius, 1.5)#+ randf()*10 #random deviation #keplers 3rd law
		#print(orbit_period)
		var new_orbit_basis = Basis(Vector3.UP, randf_range(0,TAU))
		#_planet_radius : float, _planet_color : Color, _major_orbit_radius : float, _orbit_basis : float, _orbit_period : float, _orbit_eccentricity : float
		var new_planet_data = PlanetData.new(planet_radius, planet_color, orbit_radius, new_orbit_basis, orbit_period, orbit_eccentricity)
		new_planet.planet_data = new_planet_data
		
		#new_planet.position.x = new_planet.planet_data.orbit_radius
		planets.append(new_planet)
		#var planet_ellipse = Draw3D.draw_elipse(position, orbit_radius, orbit_radius, new_orbit_basis, 12)
		#$PlanetContainer.add_child(planet_ellipse)
		$PlanetContainer.add_child(new_planet)
		new_planet.update_planet()
	system_action_region_radius = orbit_radius
	resource_orbit_radius = system_action_region_radius#/2
	resource_orbit_period = unit_orbit_time*pow(resource_orbit_radius, 1.5)#+ randf()*10 #random deviation #keplers 3rd law
	resource_orbit_angular_velocity = 2*PI/resource_orbit_period

#use ecentricity to make eliptical orbits
func orbit_planets(delta):
	for p in self.planets:
		p.planet_data.orbit_angle += p.planet_data.angular_velocity*delta*orbit_direction
		var current_orbit = p.planet_data.orbit_angle
	
		p.position = p.planet_data.orbit_basis*Vector3(p.planet_data.major_orbit_radius*cos(current_orbit), 0.25, p.planet_data.minor_orbit_radius*sin(current_orbit))#placed slightly above planets on y axis

var resource_orbit_rotation = 0
var resource_orbit_radius = 1 #overriden to be relative to system radius in generate_system, may vary if orbit levels are added
var resource_orbit_period = unit_orbit_time #also overridden
var resource_orbit_angular_velocity = 1 #also overridden
var resource_orbit_positions : Array[Vector3] = []
var resource_orbit_items : Array[ShipResource] = []
var orbit_angular_separation = 0
var orbit_count = 0
var orbit_anglular_separation = 0

func add_resource_to_system_orbit(res):
	#removing from galaxy and adding to system
	var global_pos = res.global_position
	galaxy.detach_free_resource(res)
	$ShipResourceContainer.add_child(res)
	res.global_position = global_pos
	recalculate_orbits()
	
func detatch_resourse_from_system_orbit(res):
	var global_pos = res.global_position
	$ShipResourceContainer.remove_child(res)
	galaxy.add_free_resource(res, global_pos)
	recalculate_orbits()

func recalculate_orbits():
	orbit_count = $ShipResourceContainer.get_child_count()
	orbit_anglular_separation = 2*PI/orbit_count
	
func orbit_resources(delta):
	resource_orbit_rotation+= delta*orbit_direction*resource_orbit_angular_velocity
	for i in range(orbit_count):
		var orbit_angle = i*orbit_anglular_separation + resource_orbit_rotation
		$ShipResourceContainer.get_child(i).follow_position = global_position + Vector3(resource_orbit_radius*cos(orbit_angle),0.25,resource_orbit_radius*sin(orbit_angle))#y increased so orbit above ships

func generate_resource():
	var new_resource_ship = RESOURCE_SHIP.instantiate()
	add_resource_to_system_orbit(new_resource_ship)
	new_resource_ship.set_global_position(global_position)
	new_resource_ship.final_destination_system = galaxy.target_system
	
func process_resource(res):
	#print("recieving and processing at ", self, global_position)

	if self != res.final_destination_system:
		var next_destination : SolarSystem = galaxy.get_next_step(self, res.final_destination_system)
		if next_destination:
			#print("start processing")
			var ejection_direction = (next_destination.global_position-self.global_position).normalized()
			var ejection_point = global_position+ejection_direction*system_action_region_radius
			#print("sending to ejection point")
			res.send_to_position(ejection_point)
			await res.target_reached
			#print(res.destination_system)
			#res.destination_system = next_destination
			var destination_relative = next_destination.get_resourse_recieve_point(ejection_direction)
			
			res.send_to_position(next_destination.global_position+destination_relative)
			await res.target_reached
			next_destination.process_resource(res)
			#print(next_destination.global_position)
		else:
			pass
			#print("resourse reached dead end")
	else:
		add_resource_to_system_orbit(res)
		#print("at final")

func send_resource(res, next_system):
	#print("sending resourse to ", next_system)
	res.send_to_destination_system(next_system)
	#print("sending to ", next_system)
	
		#var ray_length = self.global_position.distance_to(next_destination)
		#var from = ejection_point
		#var to = ejection_point+ejection_direction*ray_length
		#var space = get_world_3d().direct_space_state
		#var ray_query = PhysicsRayQueryParameters3D.new()
		#ray_query.collide_with_areas = true
		#ray_query.from = from
		#ray_query.to = to
		#var raycast_result = space.intersect_ray(ray_query)

func eject_resource(res):
	detatch_resourse_from_system_orbit(res)
	process_resource(res)
	

func get_resourse_recieve_point(direction : Vector3):#gives relative position
	if not direction.is_normalized():
		direction = direction.normalized()
	var recieve_point = -direction*system_action_region_radius
	return recieve_point
	

func _on_trail_timer_timeout() -> void:
	if not system_active:
		return
	for p in planets:
		var new_bread_crumb = BREAD_CRUMB.instantiate()
		new_bread_crumb.ttl = p.planet_data.orbit_period
		new_bread_crumb.position = p.position
		$TrailContainer.add_child(new_bread_crumb)
		#Draw3D.draw_point_mesh(p.global_position, p.planet_data.orbit_period)
	
func _on_resource_timer_timeout() -> void:
	generate_resource()
	
func toggle_active(val : bool):
	$VisualIndicator.visible = not $VisualIndicator.visible
