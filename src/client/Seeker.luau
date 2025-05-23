-- Dependencies
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Types
type ConnectorClass = typeof(setmetatable) & {
	Connections: { RBXScriptConnection },
} & {
	Attach: (
		self: ConnectorClass,
		connection: typeof(RunService.Heartbeat.Connect),
		method: (connection: RBXScriptConnection, ...any) -> ()
	) -> nil,
	End: (self: ConnectorClass) -> nil,
	Cleanup: (self: ConnectorClass) -> nil,
}

type ConenctorNew = {
	new: () -> ConnectorClass,
}

type MainArray = {
	Instances: { [any]: Instance },
	Variables: { [any]: any },
	Connection: ConnectorClass,
}

type MainClass = typeof(setmetatable) & MainArray & {
	cleanup: (self: MainClass) -> nil,
	start: (self: MainClass) -> nil,
	stop: (self: MainClass) -> nil,
}

-- Task
local Connector = {
	new = function()
		return setmetatable({
			Connections = {},
		}, {
			__index = {
				Attach = function(self: ConnectorClass, connection: typeof(RunService.Heartbeat), method)
					local success, response

					success, response = pcall(connection.Connect, connection, function(...)
						if response then
							coroutine.wrap(method)(response, ...)
						end
					end)

					if not success then
						warn(response)
					end

					table.insert(self.Connections, response)
				end,
				End = function(self: ConnectorClass)
					for _, connection: RBXScriptConnection in self.Connections do
						connection:Disconnect()
					end
				end,
				Cleanup = function(self: ConnectorClass)
					self.Connections = {}
				end,
			},
		})
	end,
} :: ConenctorNew

-- Variables
local Terrain = workspace.Terrain
local PlayersFolder = workspace:FindFirstChild("Players")
local Presets = Lighting:WaitForChild("LightingPresets")

-- Functions
local function EmitEffect(object, emitCount: number?)
	local destroyTime = 0

	for _, effect: ParticleEmitter in object:GetChildren() do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
			effect:Emit(emitCount)
			destroyTime += effect.Lifetime.Max
		end
	end

	return destroyTime
end

local function SpawnEffect(object: Attachment, reference: BasePart, emitCount: number?)
	local clone = object:Clone() :: Attachment
	clone.Parent = Terrain
	clone.CFrame = reference.CFrame

	local destroyTime = EmitEffect(clone, emitCount)
	delay(destroyTime, function()
		clone:Destroy()
	end)
end

-- Modules
local Seeker = require(Presets:WaitForChild("Seeker"))

-- Metadata
return setmetatable({
	Instances = {},
	Connection = Connector.new(),
	Variables = {},
}, {
	__index = {
		cleanup = function(self: MainClass)
			self.Connection:Cleanup()
			self.Instances = {}
			self.Variables = {}
		end,
		start = function(self: MainClass)
			local AppearEffect = ReplicatedFirst:FindFirstChild("AppearEffect")
			local HeartbeatEffect = ReplicatedFirst:FindFirstChild("HeartbeatEffect")
			local CaughtEffect = ReplicatedFirst:FindFirstChild("CaughtEffect")

			for _, object: Model in PlayersFolder:GetDescendants() do
				for _, innerObject in object:GetDescendants() do
					if innerObject:IsA("Part") and innerObject.Name ~= "HumanoidRootPart" then
						innerObject.Transparency = 1
					end
				end
			end

			for _, method in Seeker do
				method()
			end

			local pointLight = Instance.new("PointLight", Players.LocalPlayer.Character.PrimaryPart)
			pointLight.Name = "PointLight"
			pointLight.Range = 9

			Lighting.ClockTime = 0

			self.Instances[pointLight.Name] = pointLight

			self.Connection:Attach(RunService.Heartbeat, function(connection)
				for _, object: Model in PlayersFolder:GetChildren() do
					if object:IsA("Model") and object.PrimaryPart then
						local Magnitude = (
							object.PrimaryPart.Position - Players.LocalPlayer.Character.PrimaryPart.Position
						).Magnitude

						if Magnitude < 15 and Magnitude > 5 then
							-- HeartbeatEffect On
							local HearbeatEffect = self.Instances[HeartbeatEffect.Name .. object.Name]

							if not HearbeatEffect then
								local Clone = HeartbeatEffect.Effect:Clone() :: ParticleEmitter
								self.Instances[HeartbeatEffect.Name .. object.Name] = Clone

								Clone.Parent = object.PrimaryPart
							else
								for _, emitter: ParticleEmitter in HearbeatEffect:GetChildren() do
									emitter.ZOffset = Magnitude
								end
							end
						else
							-- HeartbeatEffect Off
							local HearbeatEffect = self.Instances[HeartbeatEffect.Name .. object.Name]
							if HearbeatEffect then
								self.Instances[HeartbeatEffect.Name .. object.Name]:Destroy()
								self.Instances[HeartbeatEffect.Name .. object.Name] = nil
							end
						end

						if Magnitude < 5 then
							-- AppearEffect
							if not self.Variables["Appear" .. object.Name] then
								self.Variables["Appear" .. object.Name] = true

								SpawnEffect(AppearEffect.Effect, object.PrimaryPart, 1)

								for _, innerObject in object:GetDescendants() do
									if innerObject:IsA("Part") and innerObject.Name ~= "HumanoidRootPart" then
										innerObject.Transparency = 0
									end
								end
							end

							-- Proximity Prompt
							if not self.Instances["ProximityPrompt" .. object.Name] then
								local ProximityPrompt = Instance.new("ProximityPrompt")
								self.Instances["ProximityPrompt" .. object.Name] = ProximityPrompt

								ProximityPrompt.ActionText = "Catch"
								ProximityPrompt.RequiresLineOfSight = false
								ProximityPrompt.MaxActivationDistance = 5
								ProximityPrompt.Triggered:Connect(function()
									SpawnEffect(CaughtEffect.Effect, object.PrimaryPart, 30)
								end)

								ProximityPrompt.Parent = object.PrimaryPart
							end
						else
							-- AppearEffect
							if self.Variables["Appear" .. object.Name] then
								self.Variables["Appear" .. object.Name] = nil

								SpawnEffect(AppearEffect.Effect, object.PrimaryPart, 1)

								for _, innerObject in object:GetDescendants() do
									if innerObject:IsA("Part") and innerObject.Name ~= "HumanoidRootPart" then
										innerObject.Transparency = 1
									end
								end
							end

							-- Proximity Prompt
							if self.Instances["ProximityPrompt" .. object.Name] then
								self.Instances["ProximityPrompt" .. object.Name]:Destroy()
								self.Instances["ProximityPrompt" .. object.Name] = nil
							end
						end
					end
				end
			end)
		end,
		stop = function(self)
			self.Connection:End()

			for _, object: Instance in self.Instances do
				object:Destroy()
			end

			for _, object: Model in PlayersFolder:GetDescendants() do
				for _, innerObject in object:GetDescendants() do
					if innerObject:IsA("Part") and innerObject.Name ~= "HumanoidRootPart" then
						innerObject.Transparency = 0
					end
				end
			end
		end,
	},
}) :: MainClass
