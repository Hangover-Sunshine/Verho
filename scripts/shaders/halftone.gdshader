// Original : Shader By Zacksly - https://zacksly.itch.io/
shader_type canvas_item;
uniform float AspectRatio = 1.5;
uniform float Dots = 10.0;
uniform float _min;
uniform float _max = 1.0;
uniform vec3 Color : source_color = vec3(1.0, 0.0, 0.0);

uniform float height = 0.0;

void fragment() {
	vec3 uv_grid = fract(vec3(UV, 0.0) * vec3(AspectRatio * Dots, Dots, 0.0)); // replaced SCREEN_UV with UV
	
	float grid = distance(uv_grid, vec3(0.5, 0.5, 0.5));
	
	vec3 raw_cam_image = vec3(1, 1, 1) * (UV.y + height);
	vec3 grayscale;
	{
		float max1 = max(raw_cam_image.r, raw_cam_image.g);
		float max2 = max(max1, raw_cam_image.b);
		float max3 = max(max1, max2);
		grayscale = vec3(max3, max3, max3);
	}
	
	vec3 clamped = clamp(grayscale, vec3(_min), vec3(_max));
	
	bool white_dot_grid = grid < dot(clamped, vec3(0.333333, 0.333333, 0.333333));
	
	vec4 texture_uv = texture(TEXTURE, UV);
	vec4 grid_result = white_dot_grid ? vec4(Color, 1.0) : vec4(0.0);
	
	COLOR.rgb = grid_result.rgb;
	COLOR.a = grid_result.a;
}