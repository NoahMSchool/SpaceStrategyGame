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
		
var hovering = false

const BLUE_MATERIAL = preload("res://OtherMaterials/blue_material.tres")
const GREEN_MATERIAL = preload("uid://8vw1icb52lme")
const RED_MATERIAL = preload("uid://btb30xedw88sj")


@onready var visual_indicator: MeshInstance3D = $VisualIndicator

const BREAD_CRUMB = preload("res://3DDraw/bread_crumb.tscn")
const SHIP_RESOURCE = preload("res://Resources/ship_resource.tscn")

var system_data : SolarSystemData
var planet_orbit_direction = 1

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
			
	if Input.is_action_just_pressed("x"):
		print("Toggle time to ", !$ResourceTimer.paused)
		$ResourceTimer.paused = !$ResourceTimer.paused
	if Input.is_action_just_pressed("z") and system_active:
		team_ownership = (team_ownership+1)%2 #hardcoded possibilities
		galaxy.set_system_disabled(self, team_ownership != TEAM.NEUTRAL)
		
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
	planet_orbit_direction = [-1,1].pick_random()
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
		var orbit_period = 40*pow(orbit_radius, 1.5)+ randf()*10 #keplers 3rd law
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



#use ecentricity to make eliptical orbits
func orbit_planets(delta):
	for p in self.planets:
		p.planet_data.orbit_angle = p.planet_data.orbit_angle + p.planet_data.angular_velocity*delta*planet_orbit_direction
		var current_orbit = p.planet_data.orbit_angle
	
		p.position = p.planet_data.orbit_basis*Vector3(p.planet_data.major_orbit_radius*cos(current_orbit), 0, p.planet_data.minor_orbit_radius*sin(current_orbit))

func orbit_resources():
	pass

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



func generate_resource():
	var per_row = 10
	var new_resource = SHIP_RESOURCE.instantiate()
	$ShipResourceContainer.add_child(new_resource)
	var x_off = ($ShipResourceContainer.get_child_count() - 1) / per_row
	var y_off = ($ShipResourceContainer.get_child_count() - 1) % per_row
	new_resource.position = new_resource.position + Vector3(0.125,0,0)* x_off + Vector3(0, 0, 0.3) * y_off
	new_resource.final_destination = galaxy.get_target_system()
	eject_resource(new_resource)
	return 

func eject_resource(res):
	#if (res.final_destination and res.final_destination != self):
	var next_destination : SolarSystem = galaxy.get_next_step(self, res.final_destination)
	if next_destination:
		res.destination = next_destination
		res.begin_transmission()
		var global_pos = res.global_position
		$ShipResourceContainer.remove_child(res)
		galaxy.add_free_resource(res, global_pos)
		
		var ejection_direction = (next_destination.global_position-self.global_position).normalized()
		var ejection_point = global_position+ejection_direction*system_action_region_radius
		res.global_position = ejection_point
		
		var recieve_point = next_destination.get_resourse_recieve_point(ejection_direction)
		#var ray_length = self.global_position.distance_to(next_destination)
		#var from = ejection_point
		#var to = ejection_point+ejection_direction*ray_length
		#var space = get_world_3d().direct_space_state
		#var ray_query = PhysicsRayQueryParameters3D.new()
		#ray_query.collide_with_areas = true
		#ray_query.from = from
		#ray_query.to = to
		#var raycast_result = space.intersect_ray(ray_query)
	else:
		res.final_destination = self
		receive_resource(res)
		# print("Ejecting!", res.name)
	
#func decide_resource_next_step(res):

func get_resourse_recieve_point(direction : Vector3):
	if not direction.is_normalized():
		direction = direction.normalized()
	var recieve_point = global_position + -direction*system_action_region_radius
	return recieve_point
	

func receive_resource(res):
	if self == res.destination:
		if self != res.final_destination:
			eject_resource(res)
		else:
			galaxy.detach_free_resource(res)
			res.queue_free()
			generate_resource()
		# $ShipResourceContainer.add_child(res)
	# res.destination = null
	#if self == res.destination:
	# res.end_transmission()
	# res.position = res.position + Vector3(0,0.125,0)* $ShipResourceContainer.get_child_count()
	
	
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
