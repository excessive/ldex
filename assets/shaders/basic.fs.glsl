vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	return Texel(tex, uv) * color;
}
