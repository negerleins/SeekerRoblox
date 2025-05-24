-- Dependencies
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Variables
local Terrain = workspace.Terrain
local PlayersFolder = workspace:FindFirstChild("Players")
local Presets = Lighting:WaitForChild("LightingPresets")
local Imports = ReplicatedStorage:WaitForChild("Imports")
local SHared = ReplicatedStorage:WaitForChild("Shared")

-- Modules
local Seeker = require(Presets:WaitForChild("Seeker"))
local Replicator = require(SHared:WaitForChild("Replicator"))
local ShapecastHitbox = require(Imports:WaitForChild("Raycast"))

-- Types
type HitboxConnection = typeof(ShapecastHitbox.new())

type RaycastClass = typeof(setmetatable) & {
	Connections: { [string]: HitboxConnection },
} & {
	Fetch: (
		self: RaycastClass,
		method: (Model: Model, Hitbox: HitboxConnection) -> nil,
		model: Model,
		name: string,
		raycastParams: RaycastParams?
	) -> nil,
	CreateHitbox: (
		self: RaycastClass,
		name: string,
		handle: BasePart,
		raycastParams: RaycastParams?
	) -> HitboxConnection,
	End: (self: RaycastClass) -> nil,
	Cleanup: (self: RaycastClass) -> nil,
}

type RaycastNew = {
	new: () -> RaycastClass,
}

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
	Raycast: RaycastClass,
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
					for _, connection in self.Connections do
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

-- Raycast Manager
local RaycastManager = {
	new = function()
		return setmetatable({
			Connections = {},
		}, {
			__index = {
				Fetch = function(
					self: RaycastClass,
					method: (Model: Model, Hitbox: HitboxConnection) -> nil,
					model: Model,
					name: string,
					raycastParams: RaycastParams?
				)
					local Model, Handle = model:FindFirstChild(name), nil

					if typeof(Model) ~= "Instance" then
						Model = nil
					end

					Handle = Model:FindFirstChild("Handle")

					if Model and not Handle then
						Model = nil
					end

					if not Model then
						model.ChildAdded:Connect(function()
							Handle = Model:FindFirstChild("Handle")

							if Handle and Model:FindFirstChild("DmgPoint", true) then
								method(Model, self:CreateHitbox(name, Handle, raycastParams))
							end
						end)
					else
						Handle = Model:FindFirstChild("Handle")

						if Handle and Model:FindFirstChild("DmgPoint", true) then
							method(Model, self:CreateHitbox(name, Handle, raycastParams))
						end
					end
				end,
				CreateHitbox = function(
					self: RaycastClass,
					name: string,
					handle: BasePart,
					raycastParams: RaycastParams?
				)
					local HitBox = ShapecastHitbox.new(handle, raycastParams)
					rawset(self.Connections, name, HitBox)
					return HitBox
				end,
				End = function(self: RaycastClass)
					for _, connection in self.Connections do
						connection:Destroy()
					end
				end,
				Cleanup = function(self: RaycastClass)
					self.Connections = {}
				end,
			},
		})
	end,
} :: RaycastNew

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

-- Metadata
return setmetatable({
	Instances = {},
	Connection = Connector.new(),
	Raycast = RaycastManager.new(),
	Variables = {},
}, {
	__index = {
		cleanup = function(self: MainClass)
			self.Connection:Cleanup()
			self.Raycast:Cleanup()
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
						innerObject.CollisionGroup = "TouchablePlayer"
					end
				end
			end

			for _, method in Seeker do
				method()
			end

			local RaycastParam = RaycastParams.new()
			RaycastParam.FilterType = Enum.RaycastFilterType.Include
			RaycastParam.FilterDescendantsInstances = { PlayersFolder }
			RaycastParam.CollisionGroup = "TouchablePlayer"

			self.Raycast:Fetch(function(Model, Hitbox)
				Hitbox:HitStart(3):OnHit(function(raycastResult, segmentHit)
					local Model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
					
					if Model and Model:FindFirstChildOfClass("Humanoid") then
						Replicator:SendToServer("PlayerHit", Model.Name)
					end
				end)
			end, Players.LocalPlayer.Character, "Bat", RaycastParam)

			local pointLight = Instance.new("PointLight", Players.LocalPlayer.Character.PrimaryPart)
			pointLight.Name = "PointLight"
			pointLight.Range = 9

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
			self.Raycast:End()

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
