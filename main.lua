local gs   = require "gamestate"
local fire = require "fire"

gs.registerEvents {
	"update", "keypressed"
}

gs.switch(require "scenes.main-menu")

function love.draw()
	local top = gs.current()
	if top.draw then
		top:draw()
		return
	end
	fire.print("no draw function on the top screen.", 0, 0, "red")
end
