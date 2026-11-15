shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float inner_radius : hint_range(0.0, 2.0) = 0.01;
uniform float outer_radius : hint_range(0.0, 2.5) = 0.5;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    float vignette = smoothstep(inner_radius, outer_radius, dist);
    COLOR = vec4(vignette_color.rgb, vignette * vignette_color.a);
}
