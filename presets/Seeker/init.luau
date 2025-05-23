local ReplicatedStorage = game:GetService("ReplicatedStorage")

local __lighting = ReplicatedStorage:WaitForChild("Lighting")
local Lighting = require(ReplicatedStorage:WaitForChild("Lighting"))
local TweenService = require(__lighting:WaitForChild("PureTween"))

return {
	Lighting.Object.Sky(true, {
		[Lighting.Enums.Sky.MoonAngularSize] = 0,
		[Lighting.Enums.Sky.SunAngularSize] = 0,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.Atmosphere(true, {
		[Lighting.Enums.Atmosphere.Density] = 0.901,
		[Lighting.Enums.Atmosphere.Offset] = 0.272,
		[Lighting.Enums.Atmosphere.Color] = Color3.fromRGB(0, 0, 0),
		[Lighting.Enums.Atmosphere.Decay] = Color3.fromRGB(0, 0, 0),
		[Lighting.Enums.Atmosphere.Glare] = 0,
		[Lighting.Enums.Atmosphere.Haze] = 1.73,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(3)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.Bloom(true, {
		[Lighting.Enums.Bloom.Enabled] = true,
		[Lighting.Enums.Bloom.Intensity] = 1.73,
		[Lighting.Enums.Bloom.Size] = 52,
		[Lighting.Enums.Bloom.Threshold] = 2.41,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.ColorCorrection(true, {
		[Lighting.Enums.ColorCorrection.Enabled] = true,
		[Lighting.Enums.ColorCorrection.Brightness] = 0.325,
		[Lighting.Enums.ColorCorrection.Contrast] = 1,
		[Lighting.Enums.ColorCorrection.Saturation] = -0.5,
		[Lighting.Enums.ColorCorrection.TintColor] = Color3.fromRGB(255, 190, 190),
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.DepthOfField(true, {
		[Lighting.Enums.DepthOfField.Enabled] = true,
		[Lighting.Enums.DepthOfField.FarIntensity] = 1,
		[Lighting.Enums.DepthOfField.FocusDistance] = 102.02,
		[Lighting.Enums.DepthOfField.InFocusRadius] = 30.535,
		[Lighting.Enums.DepthOfField.NearIntensity] = 0.195,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.Parent(true, {
		[Lighting.Enums.Lighting.ClockTime] = 0,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),
} :: {
	[any]: Lighting.ObjectType,
}
