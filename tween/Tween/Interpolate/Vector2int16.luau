local numberlerp = require(script.Parent.number)
local round = math.round

return function(alpha: number, initial: Vector2int16, final: Vector2int16)
	local x0 = initial.X
	local y0 = initial.Y
	local x1 = final.X
	local y1 = final.Y

	local x = numberlerp(alpha, x0, x1)
	local y = numberlerp(alpha, y0, y1)

	return Vector2int16.new(round(x), round(y))
end
