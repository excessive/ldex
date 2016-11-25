local lvfx = require "lvfx"
local tiny = require "tiny"
local cpml = require "cpml"
local fire = require "fire"

local render = tiny.system {
	filter = tiny.requireAny(
		"visible"
		tiny.requireAll("mesh"),
		tiny.requireAll("camera")
	)
}

function render:onAddToWorld()
	self.views = {
		background = lvfx.newView(),
		foreground = lvfx.newView(),
		hud        = lvfx.newView()
	}
	self.views.background:setClear(0, 0, 0, 1)
end

function render:onRemoveFromWorld()
	self.views = nil
end

function render:onAdd(e)
	if e.camera and e.active then
		self.camera = e
	end
end

function render:onRemove(e)
	if self.camera == e then
		self.camera = nil
	end
end

function render:update(dt)
end

function render:draw()
	lvfx.frame {
		self.views.background,
		self.views.foreground,
		self.views.hud
	}
end

return render

-- world:addSystem(tiny.processingSystem {
-- 	filter = tiny.requireAll("player", "position"),
-- 	process = function(_, entity, dt)
-- 		local dir = cpml.vec2()
-- 		dir.y = dir.y - (love.keyboard.isDown("w") and 1 or 0)
-- 		dir.y = dir.y + (love.keyboard.isDown("s") and 1 or 0)
-- 		dir.x = dir.x - (love.keyboard.isDown("a") and 1 or 0)
-- 		dir.x = dir.x + (love.keyboard.isDown("d") and 1 or 0)
-- 		if dir:len() > 0 then
-- 			dir:normalize(dir)
-- 		end
-- 		dir:scale(dir, entity.speed * dt)
-- 		entity.position = entity.position + dir
-- 	end
-- })

-- world:addSystem(tiny.system {
-- 	filter = tiny.requireAll("position", "radius"),
-- 	update = function(self, _)
-- 		local fg = self.world.views.foreground
-- 		for _, entity in ipairs(self.entities) do
-- 			lvfx.setDraw(love.graphics.circle, { "fill", entity.position.x, entity.position.y, entity.radius })
-- 			lvfx.submit(fg)
-- 		end
-- 	end
-- })

-- world:addEntity {
-- 	player = true,
-- 	position = cpml.vec2(),
-- 	speed    = 20,
-- 	radius   = 10
-- }

-- function love.update(dt)
-- 	world:update(dt)
-- end

-- function love.draw()
-- 	lvfx.frame {
-- 		world.views.background,
-- 		world.views.foreground,
-- 		world.views.hud
-- 	}
-- end
