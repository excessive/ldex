local cpml = require "cpml"
local iqm  = require "iqm"
local tiny = require "tiny"
local camera = require "camera"
local mv = {}

function mv:enter()
	self.world = tiny.world()
	self.renderer = require "systems.render"
	self.renderer.camera = camera {
		fov = 45,
		position = cpml.vec3(0, -5, 0)
	}
	self.world:add(self.renderer)

	self.world:addEntity {
		visible  = true,
		mesh     = iqm.load("assets/models/debug/color-cube.iqm"),
		position = cpml.vec3()
	}
end

function mv:leave()
	self.world:remove(self.renderer)
	self.renderer = nil

	self.world:refresh()
	self.world = nil
end

function mv:keypressed(k)
	if k == "escape" then
		_G.SCENE.switch(require "scenes.main-menu")
	end
end

function mv:update(dt)
	self.world:update(dt)
end

function mv:draw()
	self.renderer:draw()
end

return mv
