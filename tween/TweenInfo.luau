local TweenService = script.Parent
local EasingStyle = require(TweenService.EasingStyle)
local EasingDirection = require(TweenService.EasingDirection)

local TweenInfo = {}

function TweenInfo.new(
	time: number,
	easingStyle: (alpha: number) -> number,
	easingDirection: (alpha: number, easingStyle: (alpha: number) -> number) -> number,
	repeatCount: number,
	reverses: boolean,
	delayTime: number
)
	return {
		EasingDirection = easingDirection or EasingDirection.Out,
		Time = time or 1,
		DelayTime = delayTime or 0,
		RepeatCount = repeatCount or 0,
		EasingStyle = easingStyle or EasingStyle.Quad,
		Reverses = not not reverses,
	}
end

return TweenInfo
