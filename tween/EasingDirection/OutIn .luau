local EasingDirection = require(script.Parent)

local easeIn = EasingDirection.In
local easeOut = EasingDirection.Out

local easeOutIn = function(alpha, fun)
	if alpha < 0.5 then
		return easeOut(alpha * 2, fun) * 0.5
	else
		return 0.5 + easeIn(alpha * 2 - 1, fun) * 0.5
	end
end

return easeOutIn
