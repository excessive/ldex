local tiny = require "tiny"
local scroller = require "utils.scroller"
local memoize  = require "memoize"
local anchor   = require "anchor"
local get_font = memoize(love.graphics.newFont)

local menu = {}

function menu:enter()
	local items = {
		{ label = "Play" },
		{ label = "Online" },
		{ label = "Debug" },
		{ label = "Extras" },
		{ label = "Options" },
		{ label = "Exit", action = function()
			love.event.quit()
		end }
	}
	local transform = function(self, offset, count, index)
		local spacing = love.window.toPixels(40)
		self.x = 0
		self.y = math.floor(offset * spacing)
	end

	local topx = love.window.toPixels
	self.scroller = scroller(items, {
		fixed = true,
		transform_fn = transform,
		size = { w = love.window.toPixels(200), h = love.window.toPixels(40) },
		position = { x = anchor:left() + topx(100), y = anchor:center_y() - topx(50) }
	})

	self.logo = love.graphics.newImage("assets/splash/logo-exmoe.png")
end

function menu:go()
	local item = self.scroller:get()
	if item.action then
		item.action()
		return
	end
	error "No action for the current item"
end

function menu:keypressed(k)
	if k == "up" then
		self.scroller:prev()
		return
	end
	if k == "down" then
		self.scroller:next()
		return
	end
	if k == "return" then
		self:go()
	end
end

function menu:touchpressed(id, x, y)
	self:mousepressed(x, y, 1)
end

function menu:touchreleased(id, x, y)
	self:mousereleased(x, y, 1)
end

function menu:mousepressed(x, y, b)
	if self.scroller:hit(x, y, b == 1) then
		self.ready = self.scroller:get()
	end
end

function menu:mousereleased(x, y, b)
	if not self.ready then
		return
	end

	if self.scroller:hit(x, y, b == 1) then
		if self.ready == self.scroller:get() then
			self:go()
		end
	end
end

function menu:update(dt)
	self.scroller:hit(love.mouse.getPosition())
	self.scroller:update(dt)
end

function menu:draw()
	local topx = love.window.toPixels
	local x, y = anchor:left() + topx(100), anchor:center_y() - topx(150)
	local s = love.window.getPixelScale()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.logo, x, y, 0, s, s)
	local font = get_font(topx(16))
	love.graphics.setFont(font)
	love.graphics.setColor(255, 255, 255, 50)
	love.graphics.rectangle("fill",
		self.scroller.cursor_data.x,
		self.scroller.cursor_data.y,
		self.scroller.size.w,
		self.scroller.size.h
	)

	love.graphics.setColor(255, 255, 255)
	for _, item in ipairs(self.scroller.data) do
		love.graphics.print(item.label, item.x + topx(10), item.y + topx(10))
	end
end

return menu
