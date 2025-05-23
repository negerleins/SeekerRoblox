local vector2lerp = require(script.Parent.Vector2)

return function(alpha: number, initial: Rect, final: Rect)
	local min0 = initial.Min
	local max0 = initial.Max
	local min1 = final.Min
	local max1 = final.Max

	local min = vector2lerp(alpha, min0, min1)
	local max = vector2lerp(alpha, max0, max1)

	return Rect.new(min, max)
end
