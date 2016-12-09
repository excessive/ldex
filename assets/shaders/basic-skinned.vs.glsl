attribute vec4 VertexWeight;
attribute vec4 VertexBone; // used as ints!

uniform mat4 u_model, u_view, u_projection;
uniform mat4 u_pose[100];

mat4 getDeformMatrix() {
	// *255 because byte data is normalized against our will.
	return
			u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
			u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
			u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
			u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
}

vec4 position(mat4 _, vec4 vertex) {
	return u_projection * u_view * u_model * getDeformMatrix() * vertex;
}
