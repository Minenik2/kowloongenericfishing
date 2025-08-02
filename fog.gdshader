shader_type canvas_item;

uniform float time_scale = 0.1;
uniform float noise_scale = 2.0;
uniform float speed = 0.02;
uniform float intensity = 0.4;
uniform vec4 fog_color : source_color = vec4(0.941, 0.965, 0.941, 0.5);

void fragment() {
	vec2 uv = UV * noise_scale;

	// Animate the fog to drift to the right and slightly up
	uv.x += TIME * speed;
	uv.y += sin(TIME * time_scale) * 0.05;

	// Fake cloud clumps using fractal noise (layered sin functions)
	float n = sin(uv.x * 3.0 + sin(uv.y * 2.0 + TIME * 0.3) * 1.5);
	n += sin((uv.y + n) * 2.0 + TIME * 0.5);
	n = (n + 2.0) / 4.0; // Normalize to 0.0 - 1.0

	// Pulsing opacity
	float pulse = 0.5 + 0.5 * sin(TIME * 0.7 + uv.x * 0.5);
	float alpha = clamp(n * intensity * pulse, 0.0, 1.0);

	COLOR = fog_color;
	COLOR.a *= alpha;
}