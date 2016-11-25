local gs   = require "gamestate"
local fire = require "fire"
local anchor = require "anchor"

_G.EVENT = require "signal".new()

function love.load(args)
	for k, v in pairs(args) do
		if v == "--debug" then
			_G.DEBUG = true
		end
	end
	anchor:set_overscan(0.1)

	gs.registerEvents {
		"update", "keypressed"
	}
	gs.switch(require "scenes.main-menu")
end

function love.update(dt)
	anchor:update()
end

local function draw_overscan()
	love.graphics.setColor(180, 180, 180, 200)
	love.graphics.setLineStyle("rough")
	love.graphics.line(anchor:left(), anchor:center_y(), anchor:right(), anchor:center_y())
	love.graphics.line(anchor:center_x(), anchor:top(), anchor:center_x(), anchor:bottom())
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", anchor:bounds())
end

function love.draw()
	local top = gs.current()
	if not top.draw then
		fire.print("no draw function on the top screen.", 0, 0, "red")
	else
		top:draw()
	end

	if _G.DEBUG then
		draw_overscan()
	end
end
