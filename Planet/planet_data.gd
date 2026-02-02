extends  Resource
class_name PlanetData

@export var major_orbit_radius : float
var minor_orbit_radius : float
var orbit_basis : Basis
@export var orbit_period : float
@export var orbit_eccentricity := 0.0
var angular_velocity : float
var orbit_angle : float = 0#randf_range(0, 2*PI)

@export var planet_radius : float
@export var planet_color : Color

var planet_building

func _init(_planet_radius : float, _planet_color : Color, _major_orbit_radius : float, _orbit_basis : Basis, _orbit_period : float, _orbit_eccentricity : float) -> void:
	self.planet_radius = _planet_radius
	self.planet_color = _planet_color

	self.orbit_eccentricity = _orbit_eccentricity
	self.major_orbit_radius = _major_orbit_radius
	self.minor_orbit_radius = _major_orbit_radius*sqrt(1-_orbit_eccentricity**2)
	self.orbit_basis = _orbit_basis
	
	self.orbit_period = _orbit_period
	self.angular_velocity = 2*PI/_orbit_period
