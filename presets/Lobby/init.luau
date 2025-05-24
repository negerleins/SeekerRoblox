local ReplicatedStorage = game:GetService("ReplicatedStorage")

local __lighting = ReplicatedStorage:WaitForChild("Lighting")
local Lighting = require(ReplicatedStorage:WaitForChild("Lighting"))
local TweenService = require(__lighting:WaitForChild("PureTween"))

return {
	Lighting.Object.Sky(true, {
		[Lighting.Enums.Sky.MoonAngularSize] = 11,
		[Lighting.Enums.Sky.SunAngularSize] = 11,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.Atmosphere(true, {
		[Lighting.Enums.Atmosphere.Density] = 0.369,
		[Lighting.Enums.Atmosphere.Offset] = 0.134,
		[Lighting.Enums.Atmosphere.Color] = Color3.fromRGB(199, 199, 199),
		[Lighting.Enums.Atmosphere.Decay] = Color3.fromRGB(106, 112, 125),
		[Lighting.Enums.Atmosphere.Glare] = 1.21,
		[Lighting.Enums.Atmosphere.Haze] = 0,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.Bloom(true, {
		[Lighting.Enums.Bloom.Enabled] = true,
		[Lighting.Enums.Bloom.Intensity] = 0.4,
		[Lighting.Enums.Bloom.Size] = 5,
		[Lighting.Enums.Bloom.Threshold] = 0.886,
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.ColorCorrection(true, {
		[Lighting.Enums.ColorCorrection.Enabled] = true,
		[Lighting.Enums.ColorCorrection.Brightness] = 0,
		[Lighting.Enums.ColorCorrection.Contrast] = 0.1,
		[Lighting.Enums.ColorCorrection.Saturation] = -0.2,
		[Lighting.Enums.ColorCorrection.TintColor] = Color3.fromRGB(255, 255, 255),
	}, function(object, config)
		local tweenInfo = TweenService.TweenInfo.new(1)
		Lighting.TweenArray(object, config, tweenInfo)
	end),

	Lighting.Object.DepthOfField(true, {
		[Lighting.Enums.DepthOfField.Enabled] = true,
		[Lighting.Enums.DepthOfField.FarIntensity] = 0.154,
		[Lighting.Enums.DepthOfField.FocusDistance] = 38.92,
		[Lighting.Enums.DepthOfField.InFocusRadius] = 35.235,
		[Lighting.Enums.DepthOfField.NearIntensity] = 0.282,
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
