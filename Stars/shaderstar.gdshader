shader_type spatial;

//render_mode ;

uniform vec3 star_color : source_color = vec3(0.6,0.4,0.4);
uniform float emmision_strength = 1.0;

uniform vec3 starspot_color : source_color = vec3(1,0.9,0.9);

// 1 every two pi seconds
uniform float spot_speed = 1;//0.15;
uniform float spot_scale = 20;


void vertex() {
	// Called for every vertex the material is visible on.
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	
	vec2 cell = round(UV*spot_scale);
	float random = hash21(cell);
	float start_phase = 2.0*PI*random;

	//rename currentphase
	float current_phase = 0.6+0.4*sin(start_phase+TIME*spot_speed);
	current_phase = smoothstep(0.4, 1.0, current_phase);
	ALBEDO = vec3(0,0,0);
	EMISSION = mix(star_color, starspot_color , current_phase)*emmision_strength;
	


	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
