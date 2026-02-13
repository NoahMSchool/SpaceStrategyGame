extends Resource
class_name StarType

@export var star_name : String
@export var star_size : float
@export var observer_star_size : float
@export var star_mat : Material
@export var planet_range : Vector2i
@export var star_luminosity : float
@export var prob_weight : float

func _init(_starname : String, _star_size: float, _observer_star_size : float, _star_mat : Material, _planet_range : Vector2i, _star_luminosity : float, _prob_weight : float):
	self.star_name = _starname
	self.star_size = _star_size
	self.observer_star_size = _observer_star_size
	self.star_mat = _star_mat
	self.planet_range = _planet_range
	self.star_luminosity = _star_luminosity
	self.prob_weight = _prob_weight
