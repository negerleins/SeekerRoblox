local numberlerp = require(script.Parent.number)

return function(alpha: number, initial: UDim, final: UDim)
	local scale0 = initial.Scale
	local offset0 = initial.Offset
	local scale1 = final.Scale
	local offset1 = final.Offset

	local scale = numberlerp(alpha, scale0, scale1)
	local offset = numberlerp(alpha, offset0, offset1)

	return UDim.new(scale, offset)
end
