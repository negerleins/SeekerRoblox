local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local Interpolate = require(script.Interpolate)

local Tween = {}

function Tween.new(instance: Instance, tweenInfo, propertyTable: { any })
	local tween = setmetatable({}, { __index = Tween })

	tween.Instance = instance
	tween.TweenInfo = tweenInfo
	tween.PlaybackState = "Begin"

	tween._propertyTable = propertyTable
	tween._i = 1
	tween._elapsed = 0

	local bindable = Instance.new("BindableEvent")

	tween._bindable = bindable
	tween.Completed = bindable.Event

	return tween
end

function Tween:Play()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	local initialValuesTable = self._initialValues
	if not initialValuesTable then
		initialValuesTable = {}
		for i, v in self._propertyTable do
			if Interpolate[typeof(v)] then
				initialValuesTable[i] = self.Instance[i]
			end
		end
		self._initialValues = initialValuesTable
	end

	local tweenInfo = self.TweenInfo
	local duration = tweenInfo.Time
	local easingDirection = tweenInfo.EasingDirection
	local easingStyle = tweenInfo.EasingStyle
	local repeatCount = tweenInfo.RepeatCount or 0
	local delayTime = tweenInfo.DelayTime
	local reverses = tweenInfo.Reverses

	task.spawn(function()
		self._thread = coroutine.running()
		for i = self._i, (repeatCount + 1) * (reverses and 2 or 1) do
			self._i = i
			local isReversing = reverses and i % 2 == 0

			if delayTime ~= 0 and self.PlaybackState ~= "Paused" and not isReversing then
				self.PlaybackState = "Delayed"
				task.wait(delayTime)
			end

			self.PlaybackState = "Playing"

			self._connection = Heartbeat:Connect(function(delta)
				self._elapsed += delta

				local completion = self._elapsed / duration

				if completion >= 1 then
					self._connection:Disconnect()
					self._connection = nil

					for i, v in initialValuesTable do
						self.Instance[i] = if isReversing then v else self._propertyTable[i]
					end

					assert(coroutine.resume(self._thread))
				else
					local alpha = easingDirection(isReversing and 1 - completion or completion, easingStyle)
					for i, v in initialValuesTable do
						local finalValue = self._propertyTable[i]
						self.Instance[i] = Interpolate[typeof(v)](alpha, v, finalValue)
					end
				end
			end)

			coroutine.yield()
			self._elapsed = 0
		end
		self.PlaybackState = "Completed"
		self._bindable:Fire("Completed")
	end)
end

function Tween:Pause()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	if self._thread then
		pcall(task.cancel, self._thread)
		self._thread = nil
	end

	self.PlaybackState = "Paused"
end

function Tween:Cancel()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	if self._thread then
		pcall(task.cancel, self._thread)
		self._thread = nil
	end

	self._elapsed = 0
	self._i = 1
	self._initialValues = nil

	self.PlaybackState = "Cancelled"
	self._bindable:Fire("Cancelled")
end

return Tween
