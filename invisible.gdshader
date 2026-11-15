shader_type spatial;
render_mode blend_mix, depth_prepass_alpha;

uniform vec4 albedo_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform float reveal_radius = 3.0;
uniform float edge_softness = 1.0;
global uniform vec3 player_pos; // Set in Project Settings -> Globals

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float dist = distance(player_pos, world_pos);
	// Fade alpha based on distance to player
	float alpha = 1.0 - smoothstep(reveal_radius - edge_softness, reveal_radius, dist);
	
	ALBEDO = albedo_color.rgb;
	ALPHA = alpha * albedo_color.a;
}
