-- Dependencies
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

-- Variables
local Shared = ReplicatedStorage:FindFirstChild("Shared")
local PlayersFolder = workspace:FindFirstChild("Players")
local Maps = ServerStorage:FindFirstChild("Maps")
local MapSpawn = workspace:FindFirstChild("MapSpawn")
local SpawnLocation = workspace:FindFirstChild("SpawnLocation")

-- Shared
local __replicator = Shared:FindFirstChild("Replicator")
local __connector = Shared:FindFirstChild("Connector")
local __profilestore = Shared:FindFirstChild("ProfileStore")

-- Replicator
local ProfileStore = require(__profilestore)
local Replicator = require(__replicator)
local Connector = require(__connector)

-- Manager
local Manager = setmetatable({
	PlayerConnections = {},
	DefaultMap = "Canyon",
	DefaultGame = "Normal",
	Maps = {
		["Park"] = {
			ImageId = 9519522597,
			Method = function(self)
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
			Method = function(self)
				local MapModel = Maps:FindFirstChild("Canyon")
				local Clone = MapModel:Clone()
				Clone.Parent = workspace
				Clone:PivotTo(MapSpawn.CFrame)

				warn("Canyon initiated")

				self.LoadedMap = Clone
			end,
		},
	},
	GameModes = {
		["Infector"] = {
			ImageId = 1178386199,
			Method = function(self)
				self:startGame()

				warn("Infector initiated")
			end,
		},
		["Normal"] = {
			ImageId = 12102714092,
			Method = function(self)
				self:startGame()

				warn("Normal initiated")
			end,
		},
	},
	LoadedMap = nil,
	MinimumPlayerAmount = 1,
	Countdown = {
		Initial = 10, -- When server is launched and player has been initialized.
		Map = 5,
		MapSelection = 10,
		GameSelection = 10,
		HideTime = 10,
		GameTime = 30,
	},
	SelectionData = {
		Valid = {},
		Players = {
			["GameMode"] = {},
			["Map"] = {},
		},
	},
	Players = {},
	ProfileStore = nil,
	BaseTemplate = {
		Money = 0,
		Diamonds = 0,
		Chance = 0,
		Wins = 0,
		Rewards = {
			Claimed = 0,
			Current = 0,
			Timestamp = {
				Current = 0,
				Last = 0
			},
		},
	},
	Profiles = {},
	Rewards = {
		[1] = {
			List = {
				[1] = {
					Properties = {
						Title = "Day 1",
						Context = "200$",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 1
						profile.Data.Money += 200
						self:UpdatePlayer(player)
					end,
				},
				[2] = {
					Properties = {
						Title = "Day 2",
						Context = "5$D",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 2
						profile.Data.Diamonds += 5
						self:UpdatePlayer(player)
					end,
				},
				[3] = {
					Properties = {
						Title = "Day 3",
						Context = "500$",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 3
						profile.Data.Money += 500
						self:UpdatePlayer(player)
					end,
				},
				[4] = {
					Properties = {
						Title = "Day 4",
						Context = "1000$",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 4
						profile.Data.Money += 1000
						self:UpdatePlayer(player)
					end,
				},
				[5] = {
					Properties = {
						Title = "Day 5",
						Context = "10$D",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 5
						profile.Data.Diamonds += 15
						self:UpdatePlayer(player)
					end,
				},
				[6] = {
					Properties = {
						Title = "Day 6",
						Context = "100%",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 6
						profile.Data.Chance = 100
						self:UpdatePlayer(player)
					end,
				},
				[7] = {
					Properties = {
						Title = "Day 7",
						Context = "50$D",
						IamgeId = 12102714092,
					},
					Method = function(self, player: Player, profile: ProfileStore.Profile<any>)
						profile.Data.Claimed = 7
						profile.Data.Diamonds += 50
						self:UpdatePlayer(player)
					end,
				},
			},
		},
	},
}, {
	__index = {
		init = function(self)
			self.ProfileStore = ProfileStore.New(RunService:IsStudio() and "Development" or "Game", self.BaseTemplate)

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

				self:Profile(player)
			end)

			Players.PlayerRemoving:Connect(function(player)
				self:playerLeft(player)
			end)

			self:initiate()
		end,
		Profile = function(self, player: Player)
			local ProfileStore = self.ProfileStore :: ProfileStore.ProfileStore<any>

			local Profile = ProfileStore:StartSessionAsync(`User_{player.UserId}`, {
				Cancel = function()
					return player.Parent ~= Players
				end,
			})

			if not Profile then
				player:Kick("Invalid profile, please reconnect.")
			else
				Profile:AddUserId(player.UserId)
				Profile:Reconcile()

				Profile.OnSessionEnd:Connect(function()
					warn("Session ended:", player)
					self.Profiles[player.UserId] = nil
					player:Kick("Profile session ended, please reconnect.")
				end) -- Session Lock

				if player.Parent == Players then
					self.Profiles[player.UserId] = Profile
					self:PlayerInitialized(player, Profile)
				else
					Profile:EndSession()
				end
			end
		end,
		PlayerInitialized = function(self, player: Player, profile: ProfileStore.Profile<any>)
			local Leaderstats = Instance.new("Folder", player)
			Leaderstats.Name = "leaderstats"

			local Wins = Instance.new("NumberValue", Leaderstats)
			Wins.Name = "Wins"

			self:UpdatePlayer(player)
		end,
		UpdatePlayer = function(self, player: Player)
			local profile = self.Profiles[player.UserId]
			local Leaderstats = player:FindFirstChild("leaderstats")

			for name, value in profile.Data do
				local Instance = Leaderstats:FindFirstChild(name)
				if Instance then
					Instance.Value = value
				end
			end

			player:SetAttribute("Money", profile.Data["Money"])
			player:SetAttribute("Diamonds", profile.Data["Diamonds"])
			player:SetAttribute("Chance", profile.Data["Chance"])
			player:SetAttribute("Wins", profile.Data["Wins"])
		end,
		characterAdded = function(self, character)
			local Humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if Humanoid then
				Humanoid:GetAttributeChangedSignal("Died"):Connect(function()
					if not Humanoid:GetAttribute("Died") then
						return
					end

					Humanoid:SetAttribute("Died", false)
					self:playerDied(character)
				end)
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

			warn("Initiate called. Running Countdown.")

			self:countdown(self.Countdown.Initial, function()
				local Current = #Players:GetPlayers()

				if Current >= self.MinimumPlayerAmount then
					self:selection()
				else
					self.Initiated = false
					self:initiate()
				end
			end)
		end,
		countdown = function(self, count, method)
			if self.CurrentCountdown then
				self.CurrentCountdown = nil
				task.wait()
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

				if self.CurrentCountdown == UUID then
					self.CurrentCountdown = nil
					task.spawn(method, self)
				end
			end)
		end,
		startGame = function(self)
			local SeekerModel = nil
			local HighestChance = 0

			for userId, profile: ProfileStore.Profile<any> in self.Profiles do
				local index = table.find(self.Players, userId)
				local Player = Players:GetPlayerByUserId(userId)

				if index and Player and not Player:GetAttribute("IsAFK") then
					local Chance = tonumber(profile.Data.Chance)

					if Chance >= HighestChance then
						warn(Chance, HighestChance, Player)
						HighestChance = Chance
						SeekerModel = Player.Character
					end
				else
					if Player then
						Player.Character.Parent = workspace
					end

					table.remove(self.Players, index)
				end
			end

			for index, userId in self.Players do -- Assign players
				local Player = Players:GetPlayerByUserId(userId)

				if Player.Character == SeekerModel then
					continue
				end

				if Player and not Player:GetAttribute("IsAFK") then
					local Profile = self.Profiles[Player.UserId] :: ProfileStore.Profile<any>
					Profile.Data.Chance = math.min(Profile.Data.Chance + math.random(5, 10), 100)

					self:UpdatePlayer(Player)

					Player.Team = Teams.Player
					self:teleport(Player.Character, self.LoadedMap.Spawner.Position + Vector3.new(0, 5, 0))
				else
					if Player then
						Player.Character.Parent = workspace
					end

					table.remove(self.Players, index)
				end
			end

			if SeekerModel then -- Assign Seeker
				local Player = Players:GetPlayerFromCharacter(SeekerModel)

				if Player then
					local Profile = self.Profiles[Player.UserId] :: ProfileStore.Profile<any>
					Profile.Data.Chance = 0

					self:UpdatePlayer(Player)

					self:teamModel(SeekerModel, Teams.Seeker)
				end
			end

			self:countdown(self.Countdown.HideTime, function()
				if SeekerModel then
					self:teleport(SeekerModel, self.LoadedMap.Spawner.Position + Vector3.new(0, 5, 0))
				end

				self:countdown(self.Countdown.GameTime, function()
					self:endGame()
				end)
			end)
		end,
		endGame = function(self)
			-- Should cleanup for initate.
			if self.LoadedMap then
				self.LoadedMap:Destroy()
				self.LoadedMap = nil

				for _, userid in self.Players do
					local Player = Players:GetPlayerByUserId(userid)

					if Player then
						Player.Team = Teams.Lobby
						self:teleport(Player.Character, SpawnLocation.Position)
						Player.Character.Parent = workspace
					end
				end
			end

			self.Players = {}

			self.Initiated = false
			self:initiate()
		end,
		teamModel = function(self, playerModel: Model, team: Team)
			local IsPlayer = Players:GetPlayerFromCharacter(playerModel)

			if IsPlayer then
				IsPlayer.Team = team
			end
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

			local GameModeContent = {}
			local MapContent = {}

			for name, data in self.GameModes do
				self.SelectionData.Valid[name] = true

				table.insert(GameModeContent, {
					ImageId = data.ImageId,
					Selection = name,
				})
			end

			for name, data in self.Maps do
				self.SelectionData.Valid[name] = true

				table.insert(MapContent, {
					ImageId = data.ImageId,
					Selection = name,
				})
			end

			Replicator:SendToAllClients("ServerGui", {
				Type = "GameMode",
				Enabled = true,
				Contents = GameModeContent,
			})

			self:countdown(self.Countdown.GameSelection, function()
				Replicator:SendToAllClients("ServerGui", {
					Type = "Map",
					Enabled = true,
					Contents = MapContent,
				})

				self:countdown(self.Countdown.MapSelection, function()
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

			local success, err = pcall(function()
				model.PrimaryPart:SetNetworkOwner(nil)
			end)

			if not success then
				warn("Failed to set network owner:", err)
				return
			end

			task.spawn(function()
				local attempts = 0
				local maxAttempts = 50

				repeat
					attempts += 1

					if not model.Parent or not model.PrimaryPart then
						warn("Model destroyed during teleport")
						return
					end

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
				warn("selection failed, please reconnect.", player, data)
				return
			end

			if not self.SelectionData.Valid[data.Selected] then
				warn("selection failed, please reconnect.", player, data)
				return
			end

			self.SelectionData.Players[data.Type][player.UserId] = data
		end,
		playerLeft = function(self, player: Player)
			local Profile = self.Profiles[player.UserId] :: ProfileStore.Profile<any>

			if Profile then
				Profile:EndSession()
				self.Profiles[player.UserId] = nil
			end

			local tableId = table.find(self.Players, player.UserId)
			if tableId then
				table.remove(self.Players, tableId)

				if #self.Players <= 1 then
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
				local tableId = table.find(self.Players, IsPlayer.UserId)
				table.remove(self.Players, tableId)

				if #self.Players <= 1 then
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
			end

			for userId, data: {
				Type: string,
				Selected: string,
			} in self.SelectionData.Players["Map"] do
				mapCounts[data.Selected] = (mapCounts[data.Selected] or 0) + 1
			end

			for mode, count in pairs(gameModeCounts) do
				if count > _gCount then
					GameMode = mode
					_gCount = count
				end
			end

			for map, count in pairs(mapCounts) do
				if count > _mCount then
					Map = map
					_mCount = count
				end
			end

			for _, player in Players:GetPlayers() do
				if not player:GetAttribute("IsAFK") then
					table.insert(self.Players, player.UserId)
					player.Character.Parent = PlayersFolder
				end
			end

			if #self.Players < self.MinimumPlayerAmount then
				warn("no players attending resetting")

				gameModeCounts = {}
				mapCounts = {}

				self:endGame()
				return
			end

			for name, data in self.Maps do
				if name == Map then
					data.Method(self)
				end
			end

			self:countdown(self.Countdown.Map, function()
				for name, data in self.GameModes do
					if name == GameMode then
						data.Method(self)
					end
				end
			end)
		end,
	},
})

Manager:init()

Replicator:Connect(function(player: Player)
	local IsAFK = player:GetAttribute("IsAFK") or false
	player:SetAttribute("IsAFK", not IsAFK)
end, "SetAFK")

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

	warn(player, PlayerName)

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
