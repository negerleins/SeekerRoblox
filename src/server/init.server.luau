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

-- Shared
local __replicator = Shared:FindFirstChild("Replicator")

-- Replicator
local Replicator = require(__replicator)

-- Manager
local Manager = setmetatable({
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

	HideTime = 10,
	CountAmount = 15,

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
				player:GetPropertyChangedSignal("Team"):Connect(function()
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

				player.CharacterAdded:Connect(function(character)
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
			else
				self.Initiated = true
			end

			local Current = #Players:GetPlayers()

			if Current >= self.MinimumAmount then
				self:countdown(self.CountAmount, self.selection)
			else
				task.wait(1)
				self:initiate()
			end
		end,
		countdown = function(self, count, method)
			warn("Starting countdown")
			task.spawn(function()
				local UUID = HttpService:GenerateGUID(false)
				self.CurrentCountdown = UUID

				local Count = count

				repeat
					if self.CurrentCountdown ~= UUID then
						break
					end
					task.wait(1)
					Count -= 1
					workspace:SetAttribute("Time", Count)
				until Count <= 0

				if self.CurrentCountdown ~= UUID then
					return
				end

				task.spawn(method, self)
			end)
		end,
		initiateGame = function(self)
			if not self.LoadedMap then
				return
			end

			local Spawner = self.LoadedMap:FindFirstChild("Spawner")
			if not Spawner and self.LoadedMap then
				self.LoadedMap:Destroy()
				return
			end

			local amountOfPlayers = #self.InGamePlayers
			local chosen = math.random(1, amountOfPlayers)

			local seeker = nil
			for _, _player in Players:GetPlayers() do
				local userid = self.InGamePlayers[chosen]
				local IsPlayer = Players:GetPlayerByUserId(userid)
				if IsPlayer ~= _player then
					continue
				end

				if _player then
					seeker = _player
					local Character = _player.Character

					task.delay(self.HideTime, function()
						if not Character then
							self:endGame()
						end
						Character:PivotTo(Spawner.CFrame)
						_player.Team = Teams.Seeker
					end)
				end
			end

			for _, playerModel: Model in PlayersFolder:GetChildren() do
				if seeker and playerModel == seeker.Character then
					return
				end

				local IsPlayer = Players:GetPlayerFromCharacter(playerModel)
				if IsPlayer then
					IsPlayer.Team = Teams.Player
				end

				playerModel:PivotTo(Spawner.CFrame)
			end

			self:countdown(self.HideTime, function()
				self:countdown(self.GameTime, function()
					self:endGame()
				end)
			end)
		end,
		selection = function(self)
			warn("starting selection")

			self.SelectionData.Valid = {}
			self.SelectionData.Players = {
				["GameMode"] = {},
				["Map"] = {},
			}

			self.SelectionData.Valid["GameMode"] = true
			self.SelectionData.Valid["Map"] = true

			task.spawn(function()
				-- GameMode Selection
				local GameModeContent = {}

				for name, data in self.GameModes do
					self.SelectionData.Valid[name] = true

					table.insert(GameModeContent, {
						ImageId = data.ImageId,
						Selection = name,
					})
				end

				Replicator:SendToAllClients("ServerGui", {
					Type = "GameMode",
					Enabled = true,
					Contents = GameModeContent,
				})

				-- Map Selection
				local MapContent = {}
				for name, data in self.Maps do
					self.SelectionData.Valid[name] = true

					table.insert(MapContent, {
						ImageId = data.ImageId,
						Selection = name,
					})
				end

				self:countdown(self.GameCount, function()
					Replicator:SendToAllClients("ServerGui", {
						Type = "Map",
						Enabled = true,
						Contents = MapContent,
					})

					self:countdown(self.MapCount, function()
						Replicator:SendToAllClients("ServerGui", {
							Enabled = false,
						})

						self:countdown(self.StartCount, self.start)
					end)
				end)
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
			self:countdown(5, function()
				for _, playerModel: Model in PlayersFolder:GetChildren() do
					playerModel:PivotTo(SpawnLocation.CFrame)
					playerModel.Parent = workspace

					local IsPlayer = Players:GetPlayerFromCharacter(playerModel)
					if IsPlayer then
						IsPlayer.Team = Teams.Lobby
					end
				end

				if self.LoadedMap then
					self.LoadedMap:Destroy()
				end

				self.Initiated = false
				self:initiate()
			end)
		end,
		playerLeft = function(self, player: Player)
			local wasPlaying = table.find(self.InGamePlayers, player.UserId)

			if wasPlaying then
				if #self.InGamePlayers <= 1 then
					self:endGame()
				end
			end
		end,
		playerDied = function(self, playerModel: Model)
			local IsPlayer = Players:GetPlayerFromCharacter(playerModel)
			if IsPlayer then
				IsPlayer.Team = Teams.Lobby
			end
			
			playerModel.Parent = workspace
			playerModel:PivotTo(SpawnLocation.CFrame)
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

			for name, data in self.GameModes do
				if name == GameMode then
					data.method(self)
				end
			end
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
	if player.Team ~= game.Teams["Seeker"] then
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
				if (Humanoid.RootPart.Position - InvokerHUmanoid.RootPart.Position).Magnitude < 12 then
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
