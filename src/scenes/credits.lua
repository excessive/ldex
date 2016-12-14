local anchor = require "anchor"
local timer  = require "timer"
local gs     = {}

function gs:enter(from)
	love.audio.setDistanceModel("none")

	self.bgm = love.audio.newSource("assets/credits/credits.ogg")
	self.bgm:setVolume(_G.PREFERENCES.bgm_volume)
	self.bgm:play()

	self.timer = timer.new()
	self.time  = 0
	self.crash = love.filesystem.read("assets/crash.log") or "add crash.log"
	self.lines = love.filesystem.read("assets/credits.txt") or "add credits.txt"
	self.state = { opacity = 1, thanks_opacity = 0, volume = 0 }

	self.timer:script(function(wait)
		self.timer:tween(2.0, self.state, { opacity = 0 }, 'out-quad')
		self.timer:tween(5.0, self.state, { volume = 0.25 }, 'out-quad')
		wait(15)
		self:transition_out()
	end)

	self.text         = ""
	self.scroll_speed = 500
	self.font         = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 10)

	local width, height = self.font:getWrap(self.lines, anchor:width())
	self.text_width     = width
	self.text_height    = #height * self.font:getHeight()

	love.graphics.setBackgroundColor(0, 0, 0)
end

function gs:transition_out()
	self.timer:script(function(wait)
		self.timer:tween(1, self.state, { opacity = 1, volume = 0 }, 'in-out-quad')
		wait(1)
		_G.SCENE.switch(require("scenes.main-menu"))
	end)
end

function gs:mousepressed(_, _, button)
	if self.input_locked then
		return
	end
	if button == 1 then
		self:transition_out()
	end
end

function gs:update(dt)
	self.timer:update(dt)
	self.time = self.time + dt
	self.text = self.crash:sub(self.time*self.scroll_speed,self.time*self.scroll_speed+1700)
end

function gs:draw()
	love.graphics.setColor(255, 255, 255, 255 * (1-self.state.opacity))
	love.graphics.setFont(self.font)

	love.graphics.printf(
		self.text,
		anchor:center_x(),
		anchor:top(),
		anchor:width() / 2,
		"left"
	)

	love.graphics.printf(
		self.lines,
		anchor:left(),
		anchor:center_y() - self.text_height / 2,
		anchor:width() / 2,
		"center"
	)

	love.graphics.setColor(0, 0, 0, 255 * self.state.opacity)
	love.graphics.rectangle(
		"fill", 0, 0,
		love.graphics.getWidth(),
		love.graphics.getHeight()
	)
end

function gs:keypressed(k)
	if k == "escape" or k == "return" then
		self:transition_out()
	end
end

function gs:leave()
	self.bgm:stop()
end

return gs
