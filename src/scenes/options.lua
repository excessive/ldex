local anchor   = require "anchor"
local memoize  = require "memoize"
local tiny     = require "tiny"
local scroller = require "utils.scroller"
local get_font = memoize(love.graphics.newFont)
local topx     = love.window.toPixels
local scene    = {}

function scene:enter()
	local transform = function(self, offset, count, index)
		self.x = 0
		self.y = math.floor(offset * topx(40))
	end

	self.menu_selected = "main"

	-- List of menus and their options
	self.menus = {
		main = {
			{ label = "Graphics", action = function()
				self.menu_selected = "graphics"
			end },
			{ label = "Audio", action = function()
				self.menu_selected = "audio"
			end },
			{ label = "Language", action = function()
				self.menu_selected = "language"
			end },
			{ label = "Reset to Default", action = function()
				-- reset all settings to default
			end },
			{ label = "", skip = true },
			{ label = "Return to Menu", action = function()
				_G.GS.switch(require "scenes.main-menu")
			end }
		},

		graphics = {
			{ label = "Toggle Full Screen", action = function()

			end },
			{ label = "", skip = true },
			{ label = "Back", action = function()
				self.scroller:reset()
				self.menu_selected = "main"
			end }
		},

		audio = {
			{ label = "Master Volume", skip = true },
			{ label = "100%", action = function()

			end },
			{ label = "Music Volume", skip = true },
			{ label = "100%", action = function()

			end },
			{ label = "Sound Effects Volume", skip = true },
			{ label = "100%", action = function()

			end },
			{ label = "", skip = true },
			{ label = "Back", action = function()
				self.scroller:reset()
				self.menu_selected = "main"
			end }
		},

		language = {
			{ label = "Toggle Language", skip = true },
			{ label = "English", action = function()

			end },
			{ label = "", skip = true },
			{ label = "Back", action = function()
				self.scroller:reset()
				self.menu_selected = "main"
			end }
		},
	}

	-- List of menu scrollers
	self.scrollers = {
		main = scroller(self.menus.main, {
			fixed        = true,
			transform_fn = transform,
			size         = { w = topx(200), h = topx(40) },
			position     = { x = anchor:left() + topx(100), y = anchor:center_y() - topx(50) }
		}),

		graphics = scroller(self.menus.graphics, {
			fixed        = true,
			transform_fn = transform,
			size         = { w = topx(200), h = topx(40) },
			position     = { x = anchor:center_x() - topx(250), y = anchor:center_y() - topx(50) }
		}),

		audio = scroller(self.menus.audio, {
			fixed        = true,
			transform_fn = transform,
			size         = { w = topx(200), h = topx(40) },
			position     = { x = anchor:center_x() - topx(250), y = anchor:center_y() - topx(50) }
		}),

		language = scroller(self.menus.language, {
			fixed        = true,
			transform_fn = transform,
			size         = { w = topx(200), h = topx(40) },
			position     = { x = anchor:center_x() - topx(250), y = anchor:center_y() - topx(50) }
		}),
	}

	self.scroller = self.scrollers[self.menu_selected]
	self.logo     = love.graphics.newImage("assets/splash/logo-exmoe.png")
end

function scene:go()
	local item = self.scroller:get()
	if item.action then
		item.action()
		return
	end
	error "No action for the current item"
end

function scene:keypressed(k)
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

function scene:touchpressed(id, x, y)
	self:mousepressed(x, y, 1)
end

function scene:touchreleased(id, x, y)
	self:mousereleased(x, y, 1)
end

function scene:mousepressed(x, y, b)
	if self.scroller:hit(x, y, b == 1) then
		self.ready = self.scroller:get()
	end
end

function scene:mousereleased(x, y, b)
	if not self.ready then
		return
	end

	if self.scroller:hit(x, y, b == 1) then
		if self.ready == self.scroller:get() then
			self:go()
		end
	end
end

function scene:update(dt)
	self.scroller = self.scrollers[self.menu_selected]
	self.scroller:hit(love.mouse.getPosition())
	self.scroller:update(dt)
end

function scene:draw()
	love.graphics.setColor(255, 255, 255, 255)

	-- Draw logo
	local x, y = anchor:left() + topx(100), anchor:center_y() - topx(150)
	local s = love.window.getPixelScale()
	love.graphics.draw(self.logo, x, y, 0, s, s)

	local font = get_font(topx(16))
	love.graphics.setFont(font)

	-- Get main menu scroller and other scroller if available
	local scrollers ={
		self.scrollers.main,
		self.scrollers[self.menu_selected] ~= self.scrollers.main and self.scrollers[self.menu_selected] or nil
	}

	-- Iterate through scrollers and draw them
	for _, scroll in ipairs(scrollers) do
		-- Draw highlight bar
		love.graphics.setColor(255, 255, 255, 50)
		love.graphics.rectangle("fill",
			scroll.cursor_data.x,
			scroll.cursor_data.y,
			scroll.size.w,
			scroll.size.h
		)

		-- Draw items
		love.graphics.setColor(255, 255, 255)
		for _, item in ipairs(scroll.data) do
			love.graphics.print(item.label, item.x + topx(10), item.y + topx(10))
		end
	end
end

return scene
