local lvfx = require "lvfx"
local tiny = require "tiny"
local cpml = require "cpml"

local render = tiny.system {
	filter = tiny.requireAny(
		tiny.requireAll("visible", "mesh"),
		tiny.requireAll("camera")
	)
}

function render:onAddToWorld()
	-- use weak references so we don't screw with the gc
	self.objects = {}
	setmetatable(self.objects, { __mode = 'v'})

	self.views = {
		background  = lvfx.newView(),
		foreground  = lvfx.newView(),
		transparent = lvfx.newView()
	}
	self.views.background:setClear(0, 0, 0, 1)
	self.views.background:setDepthClear(true)
	self.views.background:setDepthTest("less", false)
	self.views.foreground:setDepthTest("less", true)
	self.views.transparent:setDepthTest("less", false)

	self.uniforms = {
		proj  = lvfx.newUniform("u_projection"),
		view  = lvfx.newUniform("u_view"),
		model = lvfx.newUniform("u_model"),

		pose  = lvfx.newUniform("u_pose"),

		clips = lvfx.newUniform("u_clips"),
		fog_color = lvfx.newUniform("u_fog_color")
	}

	self.shaders = {
		normal = lvfx.newShader [[
			#ifdef VERTEX
				uniform mat4 u_model, u_view, u_projection;
				vec4 position(mat4 _, vec4 vertex) {
					return u_projection * u_view * u_model * vertex;
				}
			#endif
			#ifdef PIXEL
				vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
					return Texel(tex, uv) * color;
				}
			#endif
		]],
		skinned = lvfx.newShader [[
			#ifdef VERTEX
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
			#endif
			#ifdef PIXEL
				vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
					return Texel(tex, uv) * color;
				}
			#endif
		]]
	}
end

function render:onRemoveFromWorld()
	self.objects   = nil
	self.views     = nil
	self.uniforms  = nil
	self.world     = nil
end

function render:onAdd(e)
	if e.mesh then
		table.insert(self.objects, e)
		self.objects[e] = #self.objects
	end
end

function render:onRemove(e)
	if e.mesh then
		-- all entities are guaranteed unique by tiny
		for i, entity in ipairs(self.objects) do
			if entity == e then
				table.remove(self.objects, i)
				break
			end
		end
	end
end

function render:update()
	assert(self.camera, "A camera is required to draw the scene.")
	self.camera:update(self.views.foreground:getDimensions())

	self.uniforms.proj:set(self.camera.projection:to_vec4s())
	self.uniforms.view:set(self.camera.view:to_vec4s())
	self.uniforms.clips:set({self.camera.near, self.camera.far})
	self.uniforms.fog_color:set(self.views.background._clear)

	local default_rot = cpml.quat(0, 0, 0, 1)
	local default_scale = cpml.vec3(1, 1, 1)
	for _, entity in ipairs(self.objects) do
		local model = cpml.mat4()
		model:translate(model, entity.position)
		model:rotate(model, entity.orientation or default_rot)
		model:scale(model, entity.scale or default_scale)

		self.uniforms.model:set(model:to_vec4s())

		local anim = entity.animation
		if anim and anim.current_pose then
			self.uniforms.pose:set(unpack(anim.current_pose))
			lvfx.setShader(self.shaders.skinned)
		else
			lvfx.setShader(self.shaders.normal)
		end

		lvfx.draw(entity.mesh.mesh)
		lvfx.submit(self.views.foreground)
	end
end

function render:draw()
	lvfx.frame {
		self.views.background,
		self.views.foreground,
		self.views.transparent
	}
end

return render
