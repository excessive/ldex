uniform float u_exposure   = 1.0;
uniform vec3 u_white_point = vec3(1.0, 1.0, 1.0);

vec3 Tonemap_ACES(vec3 x) {
	float a = 2.51;
	float b = 0.03;
	float c = 2.43;
	float d = 0.59;
	float e = 0.14;
	return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

vec4 effect(vec4 vcol, Image texture, vec2 texture_coords, vec2 sc) {
	vec3 texColor = Texel(texture, texture_coords).rgb;
	texColor *= u_exposure;
	texColor = vec3(1.0) - exp(-texColor / u_white_point);

	vec3 color = Tonemap_ACES(texColor);
	return vec4(linearToGamma(color), 1.0);
}
