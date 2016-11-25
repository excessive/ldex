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
		{ label = "Options" },
		{ label = "Exit", action = function()
			love.event.quit()
		end }
	}
	local transform = function(self, offset, count, index)
		local spacing = love.window.toPixels(50)
		self.x = 0
		self.y = math.floor(offset * spacing)
	end

	self.scroller = scroller(items, {
		fixed = true,
		transform_fn = transform
	})

	self.logo = love.graphics.newImage("assets/splash/logo-exmoe.png")
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
		local item = self.scroller:get()
		if item.action then
			item.action()
			return
		end
		error "No action for the current item"
	end
end

function menu:leave()
end

function menu:update(dt)
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
	love.graphics.push()
	love.graphics.translate(x, y + topx(100))
	love.graphics.setColor(50, 50, 50)

	love.graphics.rectangle("fill",
		self.scroller.cursor_data.x - topx(6),
		self.scroller.cursor_data.y - topx(6),
		topx(180),
		topx(30)
	)

	love.graphics.setColor(255, 255, 255)
	for _, item in ipairs(self.scroller.data) do
		love.graphics.print(item.label, item.x, item.y)
	end
	love.graphics.pop()
end

return menu
