attribute vec4 VertexWeight;
attribute vec4 VertexBone; // used as ints!
attribute vec3 VertexNormal;

varying vec3 f_normal;
varying vec3 f_position;
varying vec4 f_shadow_coords;

uniform mat4 u_model, u_view, u_projection;
uniform mat4 u_pose[180];
uniform mat4 u_shadow_vp;
uniform vec3 u_camera_position;

mat4 getDeformMatrix() {
	// *255 because byte data is normalized against our will.
	return
			u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
			u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
			u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
			u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
}

vec4 position(mat4 _, vec4 vertex) {
	mat4 transform = u_model * getDeformMatrix();

	f_normal = mat3(transform) * VertexNormal;
	f_shadow_coords = u_shadow_vp * transform * vertex;

	vec4 pos = u_view * transform * vertex;
	f_position = -pos.xyz;

	return u_projection * pos;
}
