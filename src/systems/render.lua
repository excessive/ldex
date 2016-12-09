local lvfx = require "lvfx"
local tiny = require "tiny"
local cpml = require "cpml"
local l3d  = require "love3d"

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
		shadow      = lvfx.newView(),
		background  = lvfx.newView(),
		foreground  = lvfx.newView(),
		transparent = lvfx.newView()
	}
	self.shadow_rt = l3d.new_shadow_map(1024, 1024)

	self.views.shadow:setCanvas(self.shadow_rt)
	self.views.shadow:setDepthClear(true)
	self.views.shadow:setDepthTest("less", true)
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
		normal  = lvfx.newShader("assets/shaders/basic-normal.vs.glsl", "assets/shaders/basic.fs.glsl"),
		skinned = lvfx.newShader("assets/shaders/basic-skinned.vs.glsl", "assets/shaders/basic.fs.glsl"),
		shadow_normal  = lvfx.newShader("assets/shaders/shadow-normal.vs.glsl", "assets/shaders/shadow.fs.glsl", true),
		shadow_skinned = lvfx.newShader("assets/shaders/shadow-skinned.vs.glsl", "assets/shaders/shadow.fs.glsl", true)
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

local default_pos   = cpml.vec3(0, 0, 0)
local default_rot   = cpml.quat(0, 0, 0, 1)
local default_scale = cpml.vec3(1, 1, 1)

local function draw_model(model, textures)
	for _, buffer in ipairs(model) do
		if textures then
			model.mesh:setTexture(load.texture(textures[buffer.material]))
		else
			model.mesh:setTexture()
		end
		model.mesh:setDrawRange(buffer.first, buffer.last)
		love.graphics.draw(model.mesh)
	end
end

function render:update()
	assert(self.camera, "A camera is required to draw the scene.")
	self.camera:update(self.views.foreground:getDimensions())

	self.uniforms.proj:set(self.camera.projection:to_vec4s())
	self.uniforms.view:set(self.camera.view:to_vec4s())
	self.uniforms.clips:set({self.camera.near, self.camera.far})
	self.uniforms.fog_color:set(self.views.background._clear)

	for _, entity in ipairs(self.objects) do
		local model = cpml.mat4()
		model:translate(model, entity.position or default_pos)
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

		lvfx.setDraw(draw_model, { entity.mesh, entity.textures })
		lvfx.submit(self.views.foreground, true)

		if entity.no_shadow then
			lvfx.submit(false)
		else
			lvfx.setShader(anim and self.shaders.shadow_skinned or self.shaders.shadow_normal)
			lvfx.submit(self.views.shadow)
		end
	end
end

function render:draw()
	lvfx.frame {
		self.views.shadow,
		self.views.background,
		self.views.foreground,
		self.views.transparent
	}
end

return render
