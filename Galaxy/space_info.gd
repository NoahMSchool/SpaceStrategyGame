class_name SpaceInfo
extends Resource

#_starname : string, _star_size: float, observer_star_size,_star_mat, StandardMaterial3D, _planet_range : Vector2i, _star_luminosity : float, _prob_weight : float
static var startypes: Array[StarType] = [
	StarType.new("MainSequence", 0.5, 0.25, preload("res://Stars/mainsequencemat.tres"), Vector2i(3,9), 1, 5),
	StarType.new("WhiteBlue", 0.4, 0.2, preload("res://Stars/bluewhitestar.tres"), Vector2i(1,4), 1, 1),
	StarType.new("RedDwarf", 0.2, 0.1, preload("res://Stars/redstar.tres"), Vector2i(1,2), 1, 2),
	StarType.new("RedGiant", 0.9, 0.4, preload("res://Stars/redstar.tres"), Vector2i(1,3), 6, 10)
]

const PLANET_SEPARATION_RANGE = [0.1, 0.75]
const PLANET_SIZE_RANGE = [0.05,0.25]

const PLANET_COLORS: Array[Color] = [
	Color("#ff0033"), # 0: Plasma Red (Volcanic/Aggressive)
	Color("#ff5e00"), # 1: Solar Orange (Lava/Star Surface)
	Color("#ffd000"), # 2: Star Yellow (High Energy/Core)
	Color("#2bff00"), # 3: Nuclear Green (Toxic/Radioactive)
	Color("#00ff95"), # 4: Alien Teal (Exotic Atmosphere)
	Color("#00f2ff"), # 5: Cryo Cyan (Ice/Electric)
	Color("#0066ff"), # 6: Deep Blue (Oceanic/Cobalt)
	Color("#7a00ff"), # 7: Void Purple (Nebula/Mystic)
	Color("#ff00ff"), # 8: Cyber Magenta (Synthetic/Psionic)
	Color("#ff0066"), # 9: Nebula Pink (Gaseous/Hot)
	Color("#e0faff"), # 10: Supernova White (Pulsar/Cold Star)
	Color("#ffaa00"),  # 11: Amber Gold (Ancient/Desert)
	
	
]
