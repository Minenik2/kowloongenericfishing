shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.941, 0.965, 0.941, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.133, 0.137, 0.137, 1.0);

uniform float noise_scale = 10.0;
uniform float noise_speed = 1.5;
uniform float noise_intensity = 0.15;
uniform float wobble_amplitude = 0.03;
uniform float wobble_speed = 3.0;
uniform float rgb_split_amount = 0.01;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 pos) {
    vec2 i = floor(pos);
    vec2 f = fract(pos);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + 
           (c - a)* u.y * (1.0 - u.x) + 
           (d - b) * u.x * u.y;
}

vec4 sample_color(vec2 uv) {
    // Vertical gradient base
    float t = uv.y;
    vec4 base = mix(bottom_color, top_color, t);

    // Add subtle noise brightness variation
    float n = noise(uv * noise_scale + vec2(TIME * noise_speed, 0.0));
    float brightness = 1.0 + (n - 0.5) * noise_intensity;

    return base * brightness;
}

void fragment() {
    vec2 uv = UV;

    // Horizontal wobble distortion
    uv.x += sin(uv.y * 30.0 + TIME * wobble_speed) * wobble_amplitude;

    // RGB split effect — sample slightly shifted uv for each channel
    float r = sample_color(uv + vec2(rgb_split_amount, 0.0)).r;
    float g = sample_color(uv).g;
    float b = sample_color(uv - vec2(rgb_split_amount, 0.0)).b;

    COLOR = vec4(r, g, b, 1.0);
	
	// Gamma correction (darken)
    float gamma = 0.9;
    COLOR.rgb = pow(COLOR.rgb, vec3(1.0 / gamma));
}