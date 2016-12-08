local camera = require "camera"
local cpml   = require "cpml"
local iqm    = require "iqm"
local tiny   = require "tiny"
local scene  = {}

function scene:enter()
	self.world           = tiny.world()
	self.renderer        = require "systems.render"
	self.renderer.camera = camera {
		fov      = 45,
		position = cpml.vec3(0, -5, 0)
	}
	self.world:add(self.renderer)

	self.cube = self.world:addEntity {
		visible     = true,
		mesh        = iqm.load("assets/models/debug/color-cube.iqm"),
		position    = cpml.vec3(),
		orientation = cpml.quat(0, 0, 0, 1)
	}
end

function scene:leave()
	self.world:remove(self.renderer)
	self.renderer = nil

	self.world:refresh()
	self.world = nil
end

function scene:keypressed(k)
	if k == "escape" then
		_G.SCENE.switch(require "scenes.main-menu")
	end
end

function scene:update(dt)
	self.world:update(dt)
	self.cube.orientation = cpml.quat.rotate(dt,     cpml.vec3.unit_z) * self.cube.orientation
	self.cube.orientation = cpml.quat.rotate(dt*0.5, cpml.vec3.unit_x) * self.cube.orientation
end

function scene:draw()
	self.renderer:draw()
end

return scene
