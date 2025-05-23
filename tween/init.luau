local TweenService = {}

TweenService.EasingStyle = require(script.EasingStyle)
TweenService.EasingDirection = require(script.EasingDirection)
TweenService.TweenInfo = require(script.TweenInfo)

local Tween = require(script.Tween)

function TweenService:GetValue(
	alpha: number,
	easingStyle: (alpha: number) -> number,
	easingDirection: (alpha: number, easingStyle: (alpha: number) -> number) -> number
)
	return easingDirection(alpha, easingStyle)
end

function TweenService:Create(instance: Instance, tweenInfo: TweenInfo, propertyTable: { any })
	return Tween.new(instance, tweenInfo, propertyTable)
end

return TweenService
