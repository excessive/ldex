local cpml = require "cpml"
local timer = require "timer"
local ringbuffer = require "utils.ringbuffer"

local scroller = {}
local scroller_mt = {}

local function default_transform(self, offset, count, index)
	local spacing = love.window.toPixels(50)
	self.x = math.floor(math.cos(offset / (count / 2)) * love.window.toPixels(50))
	self.y = math.floor(offset * spacing)
end

local function new(items, transform_fn)
	local t = {
		switch_time = 0.2,
		timer     = timer.new(),
		data      = {},
		transform = transform_fn or default_transform,
		_rb  = ringbuffer(items),
		_pos = 1,
		_tween = false,
	}
	t = setmetatable(t, scroller_mt)
	t:update(0)
	return t
end

scroller_mt.__index = scroller
scroller_mt.__call  = function(_, ...)
	return new(...)
end
local function tween(self)
	if self._tween then
		self.timer:cancel(self._tween)
	end
	self._tween = self.timer:tween(self.switch_time, self, { _pos = self._rb.current }, "out-back")
end

function scroller:prev(n)
	for i = 1, (n or 1) do self._rb:prev() end
	tween(self)
end

function scroller:next(n)
	for i = 1, (n or 1) do self._rb:next() end
	tween(self)
end

function scroller:update(dt)
	self.timer:update(dt)
	for i, v in ipairs(self._rb.items) do
		self.data[i] = setmetatable({ x = 0, y = 0 }, { __index = v })
		self.transform(self.data[i], i - self._pos, #self._rb.items, i)
	end
	while #self.data > #self._rb.items do
		table.remove(self.data)
	end
end

return setmetatable({ new = new }, scroller_mt)
