shader_type spatial;

//uniform base_color : source_color;// = vec3(0,0,0);
uniform vec3 primary : source_color;
uniform vec3 seconary : source_color;
uniform vec3 tertiary : source_color;

uniform sampler2D color_texture;
uniform sampler2D roughness_texture;



void fragment() {
	vec3 color_mask = texture(color_texture, UV).rgb;
	vec3 pixel_color = color_mask.r * primary + color_mask.g*seconary + color_mask.b*tertiary;
	ALBEDO = pixel_color;

	float pixel_roughness = texture(roughness_texture,UV).r;
	ROUGHNESS = pixel_roughness;
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
