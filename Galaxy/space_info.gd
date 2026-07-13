class_name SpaceInfo
extends Resource

#_starname : string, _star_size: float, observer_star_size,_star_mat, Material, _planet_range : Vector2i, _star_luminosity : float, _prob_weight : float
static var startypes: Array[StarType] = [
	StarType.new("MainSequence", 0.5, 0.25, preload("res://Stars/yellowstarshadermat.tres"), Vector2i(3,6), 1, 5),
	StarType.new("WhiteBlue", 0.4, 0.2, preload("res://Stars/bluestarshadermat.tres"), Vector2i(1,4), 1, 1),
	StarType.new("BlueSupergiant", 0.8, 0.4, preload("res://Stars/bluestarshadermat.tres"), Vector2i(1,4), 1, 1),
	StarType.new("RedDwarf", 0.2, 0.1, preload("res://Stars/redstarshadermat.tres"), Vector2i(1,2), 1, 3),
	StarType.new("RedGiant", 0.9, 0.4, preload("res://Stars/redstarshadermat.tres"), Vector2i(1,5), 6, 2),
	#StarType.new("ShaderStar", 0.8, 0.4, preload("res://Stars/shaderstar.tres"), Vector2i(1,3), 6, 20),
]

const PLANET_SEPARATION_RANGE = [0.1, 0.75]
const PLANET_SIZE_RANGE = [0.05,0.25]


const PLANET_COLORS = [ #source : Coolors
	#candy pop
	Color("#9b5de5"),
	Color("#f15bb5"),
	#Color("#fee440"),
	Color("#00bbf9"),
	#Color("#00f5d4"),
	#Mystic FireFly Glow
	Color("#58355e"),
	#Color("#e03616"),
	#Color("#fff689"),
	Color("#cfffb0"),
	Color("#5998c5"),
	#Sunset Ocean Orchid
	#Color("#ff595e"),
	#Color("#ff924c"),
	#Color("#ffca3a"),
	Color("#8ac926"),
	Color("#1982c4"),
	Color("#6a4c93")
]

static var teams = [
	Team.new(0, "PurplePinkPeople", Color(0.666, 0.515, 0.743, 1.0)),
	Team.new(0, "PurplePinkPeople", Color(9.666, 0.115, 0.743, 1.0)),
	Team.new(0, "PurplePinkPeople", Color(0.166, 0.115, 0.943, 1.0)),
	
]

#transport ship at time of writing around 0.25 radius
const ship_transmission_zone_radius = 0.3
