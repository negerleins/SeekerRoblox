-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInput = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Tween = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Variables
local Terrain = workspace.Terrain
local PlayersFolder = workspace:FindFirstChild("Players")
local Presets = Lighting:WaitForChild("LightingPresets")
local Imports = ReplicatedStorage:WaitForChild("Imports")
local SHared = ReplicatedStorage:WaitForChild("Shared")
local AmbienceMusic = SoundService:WaitForChild("Ambience")

-- Modules
local Seeker = require(Presets:WaitForChild("Seeker"))
local Replicator = require(SHared:WaitForChild("Replicator"))
local ShapecastHitbox = require(Imports:WaitForChild("Raycast"))

-- Types
type AnimatorClass = typeof(setmetatable) & {
	Animations: { [number]: AnimationTrack },
	Instances: { [number]: Animation },
} & {
	Load: (self: AnimatorClass, assetid: number) -> AnimationTrack,
	End: (self: AnimatorClass) -> nil,
	Cleanup: (self: AnimatorClass) -> nil,
}

type AnimatorNew = {
	new: () -> AnimatorClass,
}

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
	Animation: AnimatorClass,
	EffectedPlayers: { Model },
	WeaponCooldown: number,
	InSight: {},
	Settings: {
		QuestionMarkIndication: number,
	},
}

type MainClass = typeof(setmetatable) & MainArray & {
	cleanup: (self: MainClass) -> nil,
	start: (self: MainClass) -> nil,
	stop: (self: MainClass) -> nil,
	isObstructed: (self: MainClass, originPart: BasePart, targetPart: BasePart) -> RaycastResult,
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
					local Model, Handle = model:WaitForChild(name), nil

					if typeof(Model) ~= "Instance" then
						Model = nil
					end

					Handle = Model:WaitForChild("Handle")

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

-- Animator
local Animator = {
	new = function()
		return setmetatable({
			Animations = {},
			Instances = {},
		}, {
			__index = {
				Load = function(self, assetid: number)
					local Animation = Instance.new("Animation")
					Animation.AnimationId = `rbxassetid://{assetid}`
					table.insert(self.Instances, Animation)

					local Character = game.Players.LocalPlayer.Character
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					local Animator = Humanoid:FindFirstChildOfClass("Animator")

					if Animator then
						local AnimationTrack = Animator:LoadAnimation(Animation)
						table.insert(self.Animations, AnimationTrack)
						return AnimationTrack
					else
						return nil
					end
				end,
				End = function(self)
					for _, animation: AnimationTrack in self.Animations do
						animation:Stop()
						animation:Destroy()
					end

					for _, instance: Animation in self.Instances do
						instance:Destroy()
					end
				end,
				Cleanup = function(self)
					self.Animations = {}
				end,
			},
		})
	end,
} :: AnimatorNew

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

local function SetTransparency(number, data, ignore, callback, multiple: boolean?)
	if multiple then
		for _, object: Model in data do
			if object == ignore then
				continue
			end

			if callback then
				callback(object)
			end

			for _, innerObject in object:GetDescendants() do
				if
					(innerObject:IsA("Part") or innerObject:IsA("MeshPart"))
					and innerObject.Name ~= "HumanoidRootPart"
				then
					innerObject.Transparency = number
				end

				if innerObject:IsA("Decal") then
					innerObject.Transparency = number
				end
			end
		end
	elseif typeof(data) == "Instance" then
		for _, innerObject in data:GetDescendants() do
			if (innerObject:IsA("Part") or innerObject:IsA("MeshPart")) and innerObject.Name ~= "HumanoidRootPart" then
				innerObject.Transparency = number
			end

			if innerObject:IsA("Decal") then
				innerObject.Transparency = number
			end
		end
	end
end

local Meshes = {} :: { [Model]: { { Previous: any, Mesh: SpecialMesh } } }
local function ToggleMesh(character, toggle)
	if Meshes[character] and toggle == false then
		for _, data in Meshes[character] do
			for _, object: { Previous: any, Mesh: SpecialMesh } in data do
				object.Mesh.Parent = object.Previous
			end
		end

		Meshes[character] = nil
	elseif not Meshes[character] then -- if toggle
		for _, object in character:GetChildren() do
			if object:IsA("SpecialMesh") then
				table.insert(Meshes[character], {
					Previous = object.Parent,
					Mesh = object,
				})

				object.Parent = ReplicatedStorage
			end
		end
	end
end

-- Metadata
return setmetatable({
	Instances = {},
	Connection = Connector.new(),
	Raycast = RaycastManager.new(),
	Animation = Animator.new(),
	Variables = {},
	EffectedPlayers = {},
	WeaponCooldown = 2.5,
	InSight = {},
	Settings = {
		QuestionMarkIndication = 5,
	},
}, {
	__index = {
		cleanup = function(self: MainClass)
			self.Connection:Cleanup()
			self.Raycast:Cleanup()
			self.Animation:Cleanup()
			self.Instances = {}
			self.Variables = {}
			self.EffectedPlayers = {}
			self.InSight = {}
		end,
		start = function(self: MainClass)
			local AppearEffect = ReplicatedFirst:WaitForChild("AppearEffect")
			local HeartbeatEffect = ReplicatedFirst:WaitForChild("HeartbeatEffect")
			local Notify = ReplicatedFirst:WaitForChild("Notify")
			local Spotted = ReplicatedFirst:WaitForChild("Spotted")

			SetTransparency(1, PlayersFolder:GetChildren(), Players.LocalPlayer.Character, function(object)
				table.insert(self.EffectedPlayers, object)
				ToggleMesh(object, true)
			end, true)

			for _, method in Seeker do
				method()
			end

			local IdleAnimation = self.Animation:Load(72288275773457)
			IdleAnimation.Priority = Enum.AnimationPriority.Idle

			local SwingAnimation = self.Animation:Load(74189481580294)
			SwingAnimation.Priority = Enum.AnimationPriority.Action2

			local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
			local AttackBtn = MainGui:FindFirstChild("AttackBtn", true) :: ImageButton
			SwingAnimation.Priority = Enum.AnimationPriority.Action2

			local AttackClone = AttackBtn:Clone()
			AttackClone.Visible = true
			AttackClone.Parent = AttackBtn.Parent
			self.Instances["AttackClone"] = AttackClone

			local RaycastParam = RaycastParams.new()
			RaycastParam.FilterType = Enum.RaycastFilterType.Include
			RaycastParam.FilterDescendantsInstances = { PlayersFolder }
			RaycastParam.CollisionGroup = "TouchablePlayer"

			self.Raycast:Fetch(function(Model, Hitbox)
				local hasHit = false
				local cooldown = false

				local function Attack()
					if cooldown then
						return
					else
						cooldown = true

						task.delay(self.WeaponCooldown, function()
							cooldown = false
						end)
					end

					if SwingAnimation.IsPlaying then
						return
					end

					IdleAnimation:Stop(0.1)
					SwingAnimation:Play(0.15)

					SwingAnimation.Ended:Once(function()
						IdleAnimation:Play(0.25)
					end)

					hasHit = false

					Hitbox:HitStart(1):OnHit(function(raycastResult, segmentHit)
						if hasHit then
							return
						end

						local Model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
						if Model == Players.LocalPlayer.Character then
							return
						end

						if Model and Model:FindFirstChildOfClass("Humanoid") then
							hasHit = true
							Replicator:SendToServer("PlayerHit", Model.Name)
						end
					end)
				end

				self.Connection:Attach(UserInput.InputBegan, function(connect, InputObject: InputObject, boolean)
					if boolean then
						return
					end

					if InputObject.KeyCode == Enum.KeyCode.E then
						Attack()
					end
				end)

				self.Connection:Attach(AttackClone.MouseButton1Click, Attack)

				IdleAnimation:Play(0.5)
			end, Players.LocalPlayer.Character, "Bat", RaycastParam)

			local pointLight = Instance.new("PointLight", Players.LocalPlayer.Character.PrimaryPart)
			pointLight.Name = "PointLight"
			pointLight.Range = 9

			self.Instances[pointLight.Name] = pointLight

			self.Connection:Attach(RunService.Heartbeat, function(connection)
				for _, object: Model in self.EffectedPlayers do
					if object == Players.LocalPlayer.Character then
						continue
					end

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

								ToggleMesh(object, false)
								SetTransparency(0, object)
							end
						else
							-- AppearEffect
							if self.Variables["Appear" .. object.Name] then
								self.Variables["Appear" .. object.Name] = nil

								SpawnEffect(AppearEffect.Effect, object.PrimaryPart, 1)

								ToggleMesh(object, true)
								SetTransparency(1, object)
							end
						end

						-- Question Mark

						if not self:isObstructed(Players.LocalPlayer.Character.PrimaryPart, object.PrimaryPart) then
							if not self.InSight[object] then
								self.InSight[object] = task.delay(self.Settings.QuestionMarkIndication, function()
									self.InSight[object] = true

									local Clone = Notify:Clone()
									local Attachment = Instance.new("Attachment", Terrain)
									Attachment.Position = object.PrimaryPart.Position

									self.Instances[Notify.Name .. object.Name] = Attachment

									Clone.Size = UDim2.fromScale(0, 0)
									Clone.Adornee = Attachment
									Clone.Parent = Attachment

									Tween:Create(Clone, TweenInfo.new(1, Enum.EasingStyle.Bounce), {
										Size = UDim2.fromScale(3, 3),
									}):Play()

									task.delay(1.75, function()
										local __Tween = Tween:Create(Clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
											Size = UDim2.fromScale(0, 0),
										})

										__Tween.Completed:Connect(function()
											if self.Instances[Notify.Name .. object.Name] then
												self.Instances[Notify.Name .. object.Name]:Destroy()
												self.Instances[Notify.Name .. object.Name] = nil
												self.InSight[object] = false
											end
										end)

										__Tween:Play()
									end)
								end)
							end
						else
							if typeof(self.InSight[object]) == "thread" or self.InSight[object] == false then
								if typeof(self.InSight[object]) == "thread" then
									task.cancel(self.InSight[object])
								end

								self.InSight[object] = nil
							end
						end
						--
					end
				end
			end)

			AmbienceMusic.Looped = true
			AmbienceMusic:Play()
		end,
		stop = function(self)
			self.Connection:End()
			self.Raycast:End()
			self.Animation:End()

			for _, object: Instance in self.Instances do
				object:Destroy()
			end

			SetTransparency(0, self.EffectedPlayers, Players.LocalPlayer.Character, function(object)
				ToggleMesh(object, false)
			end, true)

			AmbienceMusic:Stop()
		end,
		isObstructed = function(self, originPart, targetPart)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { originPart.Parent }

			local result = workspace:Raycast(originPart.Position, targetPart.Position - originPart.Position, params)
			return result and not result.Instance:IsDescendantOf(targetPart.Parent)
		end,
	},
}) :: MainClass
