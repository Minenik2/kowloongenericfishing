shader_type canvas_item;

uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float flicker_speed : hint_range(0.1, 20.0) = 6.0;
uniform float outline_threshold : hint_range(0.0, 0.5) = 0.05;
uniform bool monochrome_flicker = true;

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 original_color = tex.rgb;

	// Compute luminance to check if it's a black outline
	float luminance = length(original_color);

	// Default: no flicker on outline
	vec3 flickered_color = original_color;

	if (luminance >= outline_threshold) {
		float noise = rand(vec2(UV.x + TIME * flicker_speed, UV.y));
		float flicker = 1.0 - (noise * flicker_intensity);

		if (monochrome_flicker) {
			flickered_color *= flicker;
		} else {
			flickered_color.r *= rand(UV + vec2(TIME, 0.0)) * flicker;
			flickered_color.g *= rand(UV + vec2(TIME + 12.3, 0.0)) * flicker;
			flickered_color.b *= rand(UV + vec2(TIME + 24.7, 0.0)) * flicker;
		}
	}

	COLOR = vec4(flickered_color, tex.a);
}