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

var path_globally_blocked = false: #Remove lateer for currently used for testing
	set(value):
		path_globally_blocked = value
		$DisabledIndicator.visible = path_globally_blocked
		galaxy.set_system_disabled(self, path_globally_blocked)

@onready var visual_indicator: MeshInstance3D = $VisualIndicator

const BREAD_CRUMB = preload("res://3DDraw/bread_crumb.tscn")
const SUPPLY_SHIP = preload("res://SpaceShip/supply_ship.tscn")

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
	orbit_ships(delta)
	
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
		#print("Generating Supply")
		generate_supply()
		
	if Input.is_action_just_pressed("m"):
		for s in $ShipContainer.get_children():
			eject_ship(s)
			
	if Input.is_action_just_pressed("a"):
		print("Toggle auto time to ", !$SupplyTimer.paused)
		$SupplyTimer.paused = !$SupplyTimer.paused
		
	if Input.is_action_just_pressed("z") and system_active:
		team_ownership = (team_ownership+1)%4 #hardcoded possibilities
		
	if Input.is_action_just_pressed("x") and system_active:
		path_globally_blocked = not path_globally_blocked
		
	if Input.is_action_just_pressed("t") and system_active:
		galaxy.target_system = self

var ejection_points_2D = []
func calculate_2D_ejection_points():
	var hex_radius = SpaceInfo.ship_transmission_zone_radius
	var centre = Vector2.ZERO
	ejection_points_2D = [centre]#,centre+Vector2(hex_radius*2,0), centre-Vector2(hex_radius*2,0)]
	var i = 0
	var current_radius = hex_radius
	var current_angle = 0
	while i < 6:
		i+=1
		#current_radius = int(current_radius*i/6) +1
		current_angle = i*PI/3
		ejection_points_2D.append(centre + Vector2(2*current_radius*cos(current_angle), 2*current_radius*sin(current_angle)))
	
func get_free_ejection_point(ejection_direction):
	var centre_ejection_point = global_position+ejection_direction*system_action_region_radius
	#return centre_ejection_point
	var point_found = false
	var ejection_point : Vector3
	var x_unit = ejection_direction.cross(Vector3.UP).normalized()
	var y_unit = ejection_direction.cross(x_unit).normalized()
	
	
	var i = randi_range(0, ejection_points_2D.size()-1)
	ejection_point = centre_ejection_point + ejection_points_2D[i].x*x_unit + ejection_points_2D[i].y*y_unit
	return ejection_point
	
	#while not point_found:
		#ejection_point = centre_ejection_point + ejection_points_2D[i].x*x_unit + ejection_points_2D[i].y*y_unit
		##check if point conjsted
		#var from = ejection_point
		#var to = ejection_point+ejection_direction*10
		#var space = get_world_3d().direct_space_state
		#var ray_query = PhysicsRayQueryParameters3D.new()
		#ray_query.collide_with_areas = true
		#ray_query.from = from
		#ray_query.to = to
		#ray_query.hit_from_inside = true
		#var raycast_result = space.intersect_ray(ray_query)
		#print(raycast_result)
		#if raycast_result:
			#print(raycast_result["position"].distance_to(ejection_point))
			#if raycast_result["position"].distance_to(ejection_point)>2:
				#point_found = true
			#elif i==2:
				#return centre_ejection_point
			#else:
				#i += 1
				#print(i)
		#else:
			#point_found = true
	#print(ejection_point)
	#return ejection_point

		#var ray_length = self.global_position.distance_to(next_destination)
		#var from = ejection_point
		#var to = ejection_point+ejection_direction*ray_length
		#var space = get_world_3d().direct_space_state
		#var ray_query = PhysicsRayQueryParameters3D.new()
		#ray_query.collide_with_areas = true
		#ray_query.from = from
		#ray_query.to = to
		#var raycast_result = space.intersect_ray(ray_query)


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
	ship_orbit_radius = system_action_region_radius#/2
	ship_orbit_period = unit_orbit_time*pow(ship_orbit_radius, 1.5)#+ randf()*10 #random deviation #keplers 3rd law
	ship_orbit_angular_velocity = 2*PI/ship_orbit_period
	
	calculate_2D_ejection_points()

#use ecentricity to make eliptical orbits
func orbit_planets(delta):
	for p in self.planets:
		p.planet_data.orbit_angle += p.planet_data.angular_velocity*delta*orbit_direction
		var current_orbit = p.planet_data.orbit_angle
	
		p.position = p.planet_data.orbit_basis*Vector3(p.planet_data.major_orbit_radius*cos(current_orbit), 0.25, p.planet_data.minor_orbit_radius*sin(current_orbit))#placed slightly above planets on y axis

var ship_orbit_rotation = 0
var ship_orbit_radius = 1 #overriden to be relative to system radius in generate_system, may vary if orbit levels are added
var ship_orbit_period = unit_orbit_time #also overridden
var ship_orbit_angular_velocity = 1 #also overridden
var ship_orbit_positions : Array[Vector3] = []
var ship_orbit_items : Array[BaseSpaceShip] = []
var orbit_angular_separation = 0
var orbit_count = 0
var orbit_anglular_separation = 0

func add_ship_to_system_orbit(res):
	#removing from galaxy and adding to system
	var global_pos = res.global_position
	galaxy.detach_free_ship(res)
	$ShipContainer.add_child(res)
	res.global_position = global_pos
	recalculate_orbits()
	
func detatch_ship_from_system_orbit(ship):
	var global_pos = ship.global_position
	$ShipContainer.remove_child(ship)
	galaxy.add_free_ship(ship, global_pos)
	recalculate_orbits()

func recalculate_orbits():
	orbit_count = $ShipContainer.get_child_count()
	orbit_anglular_separation = 2*PI/orbit_count
	
func orbit_ships(delta):
	ship_orbit_rotation+= delta*orbit_direction*ship_orbit_angular_velocity
	for i in range(orbit_count):
		var orbit_angle = i*orbit_anglular_separation + ship_orbit_rotation
		$ShipContainer.get_child(i).follow_position = global_position + Vector3(ship_orbit_radius*cos(orbit_angle),0.5,ship_orbit_radius*sin(orbit_angle))#y increased so orbit above ships

func generate_supply():
	var new_supply_ship = SUPPLY_SHIP.instantiate()
	add_ship_to_system_orbit(new_supply_ship)
	new_supply_ship.set_global_position(global_position)
	connect_ship_target_reached_to_accept(new_supply_ship)
	new_supply_ship.final_destination_system = galaxy.target_system

func accept_ship(ship):
	print("Accepting at ", self, global_position)
	if ship.next_system and ship.next_system != self: #check if ship is going to this system
		return
	if self != ship.final_destination_system:
		var next_destination : SolarSystem = galaxy.get_next_step(self, ship.final_destination_system)
		if next_destination:
			#print("start processing")
			var ejection_direction = (next_destination.global_position-self.global_position).normalized()
			var ejection_point = get_free_ejection_point(ejection_direction)
			#print("sending to ejection point")
			ship.next_system = null
			ship.last_system = self
			ship.send_to_position(ejection_point)
			print("waiting")
			await ship.target_reached
			ship.next_system = next_destination
			next_destination.connect_ship_target_reached_to_accept(ship)
			print("done")
			#var destination_relative = next_destination.get_ship_recieve_point(ejection_direction)
			
			var destination_pos = ejection_point+ejection_direction*(global_position.distance_to(next_destination.global_position)-(system_action_region_radius+next_destination.get_system_active_region_radius()))
			print("destination", destination_pos)
			ship.send_to_position(destination_pos)
			
			#await ship.target_reached
			#next_destination.accept_ship(ship)
			#print(next_destination.global_position)
		else:
			add_ship_to_system_orbit(ship)
			#print("ship reached dead end")
	else:
		add_ship_to_system_orbit(ship)
		#print("at final")
func connect_ship_target_reached_to_accept(ship):
	ship.target_reached.connect(accept_ship)

#func send_ship(ship, next_system):
	##print("sending ship to ", next_system)
	#ship.next_system = next_system
	#ship.send_to_(next_system)
	##print("sending to ", next_system)
	#
		#var ray_length = self.global_position.distance_to(next_destination)
		#var from = ejection_point
		#var to = ejection_point+ejection_direction*ray_length
		#var space = get_world_3d().direct_space_state
		#var ray_query = PhysicsRayQueryParameters3D.new()
		#ray_query.collide_with_areas = true
		#ray_query.from = from
		#ray_query.to = to
		#var raycast_result = space.intersect_ray(ray_query)

func eject_ship(ship):
	#if ship.final_destination_system != self:
		detatch_ship_from_system_orbit(ship)
	#else:
		accept_ship(ship)
		

func get_ship_recieve_point(direction : Vector3):#gives relative position
	if not direction.is_normalized():
		direction = direction.normalized()
	var recieve_point = -direction*system_action_region_radius
	return recieve_point

func get_system_active_region_radius():
	return self.system_action_region_radius
	

func _on_trail_timer_timeout() -> void:
	if not system_active:
		return
	for p in planets:
		var new_bread_crumb = BREAD_CRUMB.instantiate()
		new_bread_crumb.ttl = p.planet_data.orbit_period
		new_bread_crumb.position = p.position
		$TrailContainer.add_child(new_bread_crumb)
		#Draw3D.draw_point_mesh(p.global_position, p.planet_data.orbit_period)
	
func _on_supply_timer_timeout() -> void:
	generate_supply()
	
func toggle_active(val : bool):
	$VisualIndicator.visible = not $VisualIndicator.visible
