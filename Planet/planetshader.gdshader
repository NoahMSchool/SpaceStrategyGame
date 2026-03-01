shader_type spatial;

//uniform base_color : source_color;// = vec3(0,0,0);
uniform vec3 primary : source_color;
uniform vec3 seconary : source_color;
uniform vec3 tertiary : source_color;

uniform sampler2D color : source_color;
uniform sampler2D roughness : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
