-- Dependencies
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Teams = game:GetService("Teams")

-- Variables
local Shared = ReplicatedStorage:FindFirstChild("Shared")
local PlayersFolder = workspace:FindFirstChild("Players")
local Maps = ServerStorage:FindFirstChild("Maps")
local MapSpawn = workspace:FindFirstChild("MapSpawn")
local SpawnLocation = workspace:FindFirstChild("SpawnLocation")
local RunService = game:GetService("RunService")

-- Shared
local __replicator = Shared:FindFirstChild("Replicator")
local __connector = Shared:FindFirstChild("Connector")

-- Replicator
local Replicator = require(__replicator)
local Connector = require(__connector)

-- Manager
local Manager = setmetatable({
	PlayerConnections = {},
	GameModes = {
		["Infector"] = {
			ImageId = 1178386199,
			method = function(self)
				self:initiateGame()

				warn("Infector initiated")
			end,
		},
		["Normal"] = {
			ImageId = 12102714092,
			method = function(self)
				self:initiateGame()

				warn("Normal initiated")
			end,
		},
	},
	GameMode = nil,

	MinimumAmount = 1, -- Amount Of Players allowed to start the game

	HideTime = 5,
	CountAmount = 15,
	MapLoadingTime = 2,

	GameCount = 10, -- Selection
	MapCount = 10, -- Selection

	StartCount = 5,
	GameTime = 30,

	DefaultMap = "Canyon",
	DefaultGame = "Normal",

	Initiated = false,
	CurrentCountdown = nil,

	Maps = {
		["Park"] = {
			ImageId = 9519522597,
			method = function(self)
				local MapModel = Maps:FindFirstChild("Park")
				local Clone = MapModel:Clone()
				Clone.Parent = workspace
				Clone:PivotTo(MapSpawn.CFrame)

				warn("Park initiated")

				self.LoadedMap = Clone
			end,
		},
		["Canyon"] = {
			ImageId = 3000600181,
			method = function(self)
				local MapModel = Maps:FindFirstChild("Canyon")
				local Clone = MapModel:Clone()
				Clone.Parent = workspace
				Clone:PivotTo(MapSpawn.CFrame)

				warn("Canyon initiated")

				self.LoadedMap = Clone
			end,
		},
	},
	SelectionData = {
		Players = {
			["GameMode"] = {},
			["Map"] = {},
		},
		Valid = {},
	},
	InGamePlayers = {},
	LoadedMap = nil,
}, {
	__index = {
		init = function(self)
			Players.PlayerAdded:Connect(function(player)
				local Connection = Connector.new()
				self.PlayerConnections[player.UserId] = Connection

				player.DevTouchMovementMode = Enum.DevTouchMovementMode.Thumbstick

				Connection:Attach(player:GetPropertyChangedSignal("Team"), function()
					local Character = player.Character

					if player:GetAttribute("HasBat") then
						player:SetAttribute("HasBat", nil)
					end

					if player.Team.Name == "Seeker" and Character then
						player:SetAttribute("HasBat", true)

						local bat = Instance.new("Model")
						bat.Name = "Bat"

						local handle = Instance.new("Part")
						handle.Name = "Handle"
						handle.BottomSurface = Enum.SurfaceType.Smooth
						handle.CFrame = CFrame.new(-38.5, 2, -32, 0, 1, 0, 1, 0, 0, 0, 0, -1)
						handle.CanCollide = false
						handle.Color = Color3.fromRGB(99, 95, 98)
						handle.Locked = true
						handle.Reflectance = 0.4
						handle.Size = Vector3.new(1, 0.800000011920929, 4)
						handle.TopSurface = Enum.SurfaceType.Smooth

						local mesh = Instance.new("SpecialMesh")
						mesh.Name = "Mesh"
						mesh.MeshId = "http://www.roblox.com/asset/?id=54983181"
						mesh.MeshType = Enum.MeshType.FileMesh
						mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
						mesh.TextureId = "http://www.roblox.com/asset/?id=54983107"
						mesh.Parent = handle

						local handle1 = Instance.new("Motor6D")
						handle1.Name = "Handle"
						handle1.C0 = CFrame.new(0, -1, -0.5, 0, 1, 0, 1, 0, 0, 0, 0, -1)
						handle1.C1 = CFrame.new(0, 0, -1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						handle1.Parent = handle

						local dmgPoint = Instance.new("Attachment")
						dmgPoint.Name = "DmgPoint"
						dmgPoint.CFrame = CFrame.new(-0.5, -0.400002, -2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint.WorldCFrame = CFrame.new(-38.9, 1.5, -30, 0, 1, 0, 1, 0, 0, 0, 0, -1)
						dmgPoint.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint.Parent = handle

						local dmgPoint1 = Instance.new("Attachment")
						dmgPoint1.Name = "DmgPoint"
						dmgPoint1.CFrame = CFrame.new(-0.5, -0.400002, 2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint1.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint1.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint1.Parent = handle

						local dmgPoint2 = Instance.new("Attachment")
						dmgPoint2.Name = "DmgPoint"
						dmgPoint2.CFrame = CFrame.new(-0.5, 0.400002, -2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint2.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint2.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint2.Parent = handle

						local dmgPoint3 = Instance.new("Attachment")
						dmgPoint3.Name = "DmgPoint"
						dmgPoint3.CFrame = CFrame.new(-0.5, 0.400002, 2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint3.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint3.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint3.Parent = handle

						local dmgPoint4 = Instance.new("Attachment")
						dmgPoint4.Name = "DmgPoint"
						dmgPoint4.CFrame = CFrame.new(0.5, -0.400002, -2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint4.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint4.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint4.Parent = handle

						local dmgPoint5 = Instance.new("Attachment")
						dmgPoint5.Name = "DmgPoint"
						dmgPoint5.CFrame = CFrame.new(0.5, -0.400002, 2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint5.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint5.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint5.Parent = handle

						local dmgPoint6 = Instance.new("Attachment")
						dmgPoint6.Name = "DmgPoint"
						dmgPoint6.CFrame = CFrame.new(0.5, 0.400002, -2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint6.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint6.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint6.Parent = handle

						local dmgPoint7 = Instance.new("Attachment")
						dmgPoint7.Name = "DmgPoint"
						dmgPoint7.CFrame = CFrame.new(0.5, 0.400002, 2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						dmgPoint7.WorldAxis = Vector3.new(0, 1, 0)
						dmgPoint7.WorldSecondaryAxis = Vector3.new(1, 0, 0)
						dmgPoint7.Parent = handle

						handle1.Part0 = Character:WaitForChild("Right Arm")
						handle1.Part1 = handle

						handle.Parent = bat
						bat.Parent = Character

						player:GetAttributeChangedSignal("HasBat"):Once(function()
							bat:Destroy()
						end)
					end
				end)

				Connection:Attach(player.CharacterAdded, function(connection, character)
					self:characterAdded(character)
				end)
			end)

			Players.PlayerRemoving:Connect(function(player)
				self:playerLeft(player)
			end)
		end,
		characterAdded = function(self, character)
			local Humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if Humanoid then
				Humanoid:GetAttributeChangedSignal("Died"):Connect(function()
					Humanoid:SetAttribute("Died", false)
					self:playerDied(character)
				end)

				self:initiate()
			else
				task.wait()
				self:characterAdded(character)
			end
		end,
		initiate = function(self)
			if self.Initiated then
				return
			end

			local Current = #Players:GetPlayers()

			if Current >= self.MinimumAmount then
				self.Initiated = true

				self:countdown(self.CountAmount, self.selection)
			else
				task.wait(1)
				self:initiate()
			end
		end,
		countdown = function(self, count, method)
			-- Cancel any existing countdown first
			if self.CurrentCountdown then
				self.CurrentCountdown = nil
				task.wait(0.1) -- Brief pause for cleanup
			end

			warn("Starting countdown for", count, "seconds")
			local UUID = HttpService:GenerateGUID(false)
			self.CurrentCountdown = UUID

			task.spawn(function()
				local Count = count
				repeat
					task.wait(1)
					if self.CurrentCountdown ~= UUID then
						warn("Countdown cancelled:", UUID)
						return
					end
					Count -= 1
					workspace:SetAttribute("Time", Count)
				until Count <= 0

				-- Clear countdown before calling method
				if self.CurrentCountdown == UUID then
					self.CurrentCountdown = nil
					task.spawn(method, self)
				end
			end)
		end,
		initiateGame = function(self)
			if not self.LoadedMap then
				return
			end

			local Spawner = self.LoadedMap:FindFirstChild("Spawner")

			local PlayerModels = PlayersFolder:GetChildren()
			local Chosen = PlayerModels[math.random(1, #PlayerModels)]
			self:teamModel(Chosen, Teams.Seeker)

			for _, PlayerModel in PlayerModels do
				if PlayerModel == Chosen then
					continue
				end

				self:teleport(PlayerModel, Spawner.Position + Vector3.new(0, 4, 0))
				self:teamModel(Chosen, Teams.Player)
			end

			warn("Hide Time")
			self:countdown(self.HideTime, function()
				self:teleport(Chosen, Spawner.Position + Vector3.new(0, 4, 0))

				self:countdown(self.GameTime, function()
					warn("Game Time")
					self:endGame()
				end)
			end)
		end,
		teamModel = function(self, playerModel: Model, team: Team) 
			local IsPlayer = Players:GetPlayerFromCharacter(playerModel)

			if IsPlayer then
				IsPlayer.Team = team
			end
		end,
		selection = function(self)
			warn("starting selection")

			-- Clear previous selection data
			self.SelectionData.Valid = {}
			self.SelectionData.Players = {
				["GameMode"] = {},
				["Map"] = {},
			}

			-- Set valid flags
			self.SelectionData.Valid["GameMode"] = true
			self.SelectionData.Valid["Map"] = true

			-- Prepare content
			local GameModeContent = {}
			for name, data in self.GameModes do
				self.SelectionData.Valid[name] = true
				table.insert(GameModeContent, {
					ImageId = data.ImageId,
					Selection = name,
				})
			end

			local MapContent = {}
			for name, data in self.Maps do
				self.SelectionData.Valid[name] = true
				table.insert(MapContent, {
					ImageId = data.ImageId,
					Selection = name,
				})
			end

			-- Send GameMode selection
			Replicator:SendToAllClients("ServerGui", {
				Type = "GameMode",
				Enabled = true,
				Contents = GameModeContent,
			})

			-- Use sequential countdowns instead of nested ones
			self:countdown(self.GameCount, function()
				-- Send Map selection
				Replicator:SendToAllClients("ServerGui", {
					Type = "Map",
					Enabled = true,
					Contents = MapContent,
				})

				self:countdown(self.MapCount, function()
					Replicator:SendToAllClients("ServerGui", {
						Enabled = false,
					})
					self:start()
				end)
			end)
		end,
		teleport = function(self, model: Model, position: Vector3)
			if not model or not model.PrimaryPart or not model.Parent then
				warn("Invalid model for teleportation")
				return
			end

			-- Set network ownership before teleporting
			local success, err = pcall(function()
				model.PrimaryPart:SetNetworkOwner(nil)
			end)

			if not success then
				warn("Failed to set network owner:", err)
				return
			end

			task.spawn(function()
				local attempts = 0
				local maxAttempts = 50 -- 5 second timeout

				repeat
					attempts += 1

					if not model.Parent or not model.PrimaryPart then
						warn("Model destroyed during teleport")
						return
					end

					-- Use safer teleportation
					local success, err = pcall(function()
						model:PivotTo(CFrame.new(position))
					end)

					if not success then
						warn("Teleport failed:", err)
						break
					end

					task.wait(0.1)
				until (model:GetPivot().Position - position).Magnitude <= 3 or attempts >= maxAttempts

				if attempts >= maxAttempts then
					warn("Teleport timeout for", model.Name)
					return
				end

				-- Restore network ownership
				local IsPlayer = Players:GetPlayerFromCharacter(model)
				if IsPlayer and IsPlayer.Parent then
					pcall(function()
						model.PrimaryPart:SetNetworkOwner(IsPlayer)
					end)
				end

				print("Teleport successful for", model.Name)
			end)
		end,
		select = function(self, player: Player, data)
			if not self.SelectionData.Valid[data.Type] then
				player:Kick("selection failed, please reconnect.")
				return
			end

			if not self.SelectionData.Valid[data.Selected] then
				player:Kick("selection failed, please reconnect.")
				return
			end

			if player.Character then
				player.Character.Parent = PlayersFolder
			end

			self.SelectionData.Players[data.Type][player.UserId] = data
		end,
		endGame = function(self)
			warn("Ending game")

			self.CurrentCountdown = nil

			self.InGamePlayers = {}
			self.SelectionData.Players = {
				["GameMode"] = {},
				["Map"] = {},
			}
			self.SelectionData.Valid = {}

			for _, playerModel: Model in PlayersFolder:GetChildren() do
				self:teleport(playerModel, SpawnLocation.Position)
				playerModel.Parent = workspace

				self:teamModel(playerModel, Teams.Lobby)
			end

			if self.LoadedMap then
				self.LoadedMap:Destroy()
				self.LoadedMap = nil
			end

			task.wait(2)
			self.Initiated = false

			if #Players:GetPlayers() >= self.MinimumAmount then
				self:initiate()
			end
		end,
		playerLeft = function(self, player: Player)
			local tableId = table.find(self.InGamePlayers, player.UserId)

			if tableId then
				table.remove(self.InGamePlayers, tableId)

				if #self.InGamePlayers <= 1 then
					self:endGame()
				end
			end

			local Connection = self.PlayerConnections[player.UserId]

			if Connection then
				Connection:End()
				Connection:Cleanup()
			end
		end,
		playerDied = function(self, playerModel: Model)
			self:teamModel(playerModel, Teams.Lobby)

			local IsPlayer = Players:GetPlayerFromCharacter(playerModel)
			if IsPlayer then
				local tableId = table.find(self.InGamePlayers, IsPlayer.UserId)
				table.remove(self.InGamePlayers, tableId)

				if #self.InGamePlayers <= 1 then
					self:endGame()
				end
			end

			playerModel.Parent = workspace
			self:teleport(playerModel, SpawnLocation.Position)
		end,
		start = function(self)
			warn("starting game")
			local _gCount = 0
			local _mCount = 0

			local GameMode = self.DefaultGame
			local Map = self.DefaultMap

			local gameModeCounts = {}
			local mapCounts = {}

			for userId, data: {
				Type: string,
				Selected: string,
			} in self.SelectionData.Players["GameMode"] do
				gameModeCounts[data.Selected] = (gameModeCounts[data.Selected] or 0) + 1
				local IsPlayer = Players:GetPlayerByUserId(userId)
				if IsPlayer then
					table.insert(self.InGamePlayers, userId)
				end
			end

			for userId, data: {
				Type: string,
				Selected: string,
			} in self.SelectionData.Players["Map"] do
				mapCounts[data.Selected] = (mapCounts[data.Selected] or 0) + 1
				local IsPlayer = Players:GetPlayerByUserId(userId)
				if IsPlayer and not table.find(self.InGamePlayers, userId) then
					table.insert(self.InGamePlayers, userId)
				end
			end

			-- Find the most frequent GameMode
			for mode, count in pairs(gameModeCounts) do
				warn(mode, count)
				if count > _gCount then
					GameMode = mode
					_gCount = count
				end
			end

			-- Find the most frequent Map
			for map, count in pairs(mapCounts) do
				warn(map, count)
				if count > _mCount then
					Map = map
					_mCount = count
				end
			end

			if #self.InGamePlayers == 0 then
				warn("no players attending resetting")
				self:endGame()
				return
			end

			for name, data in self.Maps do
				if name == Map then
					data.method(self)
				end
			end

			self:countdown(self.MapLoadingTime, function()
				for name, data in self.GameModes do
					if name == GameMode then
						data.method(self)
					end
				end
			end)
		end,
	},
})

Replicator:Connect(function(
	player: Player,
	data: {
		Type: string,
		Selected: string,
	}
)
	if typeof(data) ~= "table" then
		player:Kick("invalid request")
		return
	end

	if not rawget(data, "Type") or not rawget(data, "Selected") then
		player:Kick("server was unable to parse data")
		return
	end

	Manager:select(player, data)
end, "Selection")

Replicator:Connect(function(player: Player, PlayerName)
	if player.Team ~= Teams["Seeker"] then
		return
	end

	local InvokerHUmanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not InvokerHUmanoid then
		return
	end

	if PlayerName then
		local Player = PlayersFolder:FindFirstChild(PlayerName)

		if Player then
			local Humanoid = Player:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				if (Humanoid.RootPart.Position - InvokerHUmanoid.RootPart.Position).Magnitude < 8 then
					Replicator:SendToAllClients("CaughtEffect", PlayerName)

					task.delay(0.25, function()
						Humanoid:SetAttribute("Died", true)
					end)
				end
			end
		end
	end

	warn(player.Name, "requested to kill", PlayerName)
end, "PlayerHit")

Replicator:init()
Manager:init()
