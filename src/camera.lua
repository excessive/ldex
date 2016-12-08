local tiny   = require "tiny"
local cpml   = require "cpml"

local camera = {}

local camera_mt = {
	__index = camera
}

local function new(options)
	local t = {
		fov = options.fov or 45,
		near = options.near or 0.01,   -- 1cm
		far  = options.far  or 1000.0, -- 1km
		exposure = options.exposure or 1.0,

		position = options.position or cpml.vec3(0, 0, 0),
		orientation = options.orientation or cpml.quat(0, 0, 0, 1),

		target = options.target or false,

		view = cpml.mat4(),
		projection = cpml.mat4()
	}
	t.direction = t.orientation * cpml.vec3.unit_y

	return setmetatable(t, camera_mt)
end

function camera:update(w, h)
	local aspect = math.max(w/h, h/w)
	local target = self.target and self.target or (self.position + self.direction)
	self.view:look_at(self.view, self.position, target, cpml.vec3.unit_z)
	self.projection = cpml.mat4.from_perspective(self.fov, aspect, self.near, self.far)
end

return setmetatable(
	{ new = new },
	{ __call = function(_, ...) return new(...) end }
)
