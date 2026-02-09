shader_type spatial;

//render_mode ;

uniform vec3 star_color : source_color = vec3(1,0.5,0.5);
uniform float emmision_strength = 1.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	ALBEDO = vec3(0,0,0);
	EMISSION = star_color*emmision_strength;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
