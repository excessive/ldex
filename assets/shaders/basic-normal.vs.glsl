uniform mat4 u_model, u_view, u_projection;

vec4 position(mat4 _, vec4 vertex) {
	return u_projection * u_view * u_model * vertex;
}
