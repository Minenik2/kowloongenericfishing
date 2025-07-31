shader_type canvas_item;

uniform float wave_strength = 5.0;
uniform float wave_speed = 1.0;
uniform float wave_frequency = 20.0;

void fragment() {
    vec2 uv = UV;
    
    // Vertical wave distortion
    uv.y += sin(uv.x * wave_frequency + TIME * wave_speed) * (wave_strength / 100.0);
    
    COLOR = texture(TEXTURE, uv);
}