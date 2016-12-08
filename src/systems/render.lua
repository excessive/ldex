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
	self.views.background:setClear(0, 0, 0, 1, true)
	self.views.background:setDepthTest("less", false)
	self.views.foreground:setDepthTest("less", true)
	self.views.transparent:setDepthTest("less", false)

	self.uniforms = {
		proj  = lvfx.newUniform("u_projection"),
		view  = lvfx.newUniform("u_view"),
		model = lvfx.newUniform("u_model")
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
	if e.camera and e.active then
		self.camera = e
	end
	if e.mesh then
		table.insert(self.objects, e)
	end
end

function render:onRemove(e)
	if self.camera == e then
		self.camera = nil
	end
end

function render:update()
	assert(self.camera, "A camera entity is required to draw the scene.")
	self.camera:update(self.views.foreground:getDimensions())

	for _, entity in ipairs(self.objects) do
		local model = cpml.mat4()
		self.uniforms.proj:set(self.camera.projection:to_vec4s())
		self.uniforms.view:set(self.camera.view:to_vec4s())
		self.uniforms.model:set(model:to_vec4s())
		lvfx.setShader(self.shaders.normal)
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
