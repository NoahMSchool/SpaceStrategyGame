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

const PLANET_PRIMARIES = [#Vibrant Mix : Coolors
	Color("#5fad56"),
	Color("#f2c14e"),
	Color("#f78154"),
	Color("#4d9078"),
	Color("#b4436c")
]
const PLANET_SECONDARIES = [
	#candy pop
	Color("#9b5de5"),
	Color("#f15bb5"),
	Color("#fee440"),
	Color("#00bbf9"),
	Color("#00f5d4"),

	#Mystic FireFly Glow
	Color("#58355e"),
	Color("#e03616"),
	Color("#fff689"),
	Color("#cfffb0"),
	Color("#5998c5"),
]

const PLANET_TERTIARIES = [
	#Sunset Ocean Orchid
	Color("#ff595e"),
	Color("#ff924c"),
	Color("#ffca3a"),
	Color("#8ac926"),
	Color("#1982c4"),
	Color("#6a4c93")
]

const PLANET_TEXTURES = [# color then roughness
	[preload("res://Planet/planet_textures/craterhexcolor.png"),preload("res://Planet/planet_textures/craaterhexroughness.png"),],
	[preload("res://Planet/planet_textures/dometechcolor.png"), preload("res://Planet/planet_textures/dometechroughness.png")],
	[preload("res://Planet/planet_textures/icebubblescolor.png"), preload("res://Planet/planet_textures/icebubblesroughness.png")],
	[preload("res://Planet/planet_textures/muddybeachcolor.png"), preload("res://Planet/planet_textures/muddybeachoughness.png")],
	[preload("res://Planet/planet_textures/Ringstreak-Colour.png"), null],
	[preload("res://Planet/planet_textures/roundrowscolor.png"), preload("res://Planet/planet_textures/roundrowsroughness.png")],
]
const PLANET_ROUGHNESS_TEXTURES = [
	preload("res://Planet/planet_textures/craaterhexroughness.png"),
	null,
	null,
	preload("res://Planet/planet_textures/muddybeachoughness.png"),
	null,
	null,
]


static var teams = [
	Team.new(0, "PurplePinkPeople", Color(0.666, 0.515, 0.743, 1.0)),
	Team.new(1, "YellowEnergyAliens", Color(1.274, 1.274, 0.518, 1.0)),
	Team.new(2, "SpaceYetis", Color(0.549, 0.673, 0.846, 1.0)),
	#Team.new(3, "BugBugs", Color(0.387, 0.0, 0.659, 1.0)),
	
]

#transport ship at time of writing around 0.25 radius
const ship_transmission_zone_radius = 0.3
