-- Dependencies
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local function WaitForChild(parent, name)
	repeat
		task.wait()
	until parent:FindFirstChild(name)
	return parent:FindFirstChild(name)
end

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Terrain = workspace.Terrain
local Purchasables = WaitForChild(workspace, "Purchasables")
local VoteSection = workspace:WaitForChild("VoteSection")
local Blocks = VoteSection:WaitForChild("Blocks")
local Board = WaitForChild(VoteSection, "Board")
local SurfaceGui = Board:WaitForChild("SurfaceGui")
local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local MainContainer = MainGui:WaitForChild("MainContainer")
local Left = MainContainer:WaitForChild("Left")
local Middle = MainContainer:WaitForChild("Middle")
local Right = MainContainer:WaitForChild("Right")
local RightTop = Right:WaitForChild("Top")
local MiddleFrame = Middle:WaitForChild("Middle")
local AFKBtn = Left:WaitForChild("AFKBtn") :: ImageButton
local Reveal = MiddleFrame:WaitForChild("Reveal") :: GuiObject
local EndGameBtn = RightTop:WaitForChild("EndGameBtn") :: ImageButton

local Buttons = {
	ShopBtn = {
		Page = nil,
		Button = Left:WaitForChild("ShopBtn"),
	},
	InventoryBtn = {
		Page = nil,
		Button = Left:WaitForChild("InventoryBtn"),
	},
	RewardsBtn = {
		Page = MiddleFrame:WaitForChild("Rewards"),
		Button = Left:WaitForChild("RewardsBtn"),
	},
	SettingsBtn = {
		Page = nil,
		Button = Left:WaitForChild("SettingsBtn"),
	},
} :: {
	[string]: {
		Page: GuiObject,
		Button: GuiButton,
	},
}

-- Shared
local __replicator = Shared:WaitForChild("Replicator")
local __connector = Shared:WaitForChild("Connector")

-- Locals
local CaughtEffect = ReplicatedFirst:FindFirstChild("CaughtEffect")
local PlayersFolder = workspace:FindFirstChild("Players")

-- Replicator
local Replicator = require(__replicator)
local Connector = require(__connector)

-- PageManger
local PageManger = setmetatable({
	CurrentPage = nil,
}, {
	__index = {
		init = function(self)
			for _, data in Buttons do
				if data.Button then
					data.Button.MouseButton1Click:Connect(function()
						self:select(data.Page)
					end)
				end
			end
		end,
		select = function(self, page: GuiObject)
			if self.CurrentPage and self.CurrentPage == page then
				self.CurrentPage.Visible = false
				self.CurrentPage = nil

				return
			else
				if self.CurrentPage then
					self.CurrentPage.Visible = false
				end

				if page then
					self.CurrentPage = page
					self.CurrentPage.Visible = true
				end
			end
		end,
	},
})

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

local function SpawnEffect(object: Attachment, position: Vector3, emitCount: number?)
	local clone = object:Clone() :: Attachment
	clone.Parent = Terrain
	clone.WorldPosition = position

	local destroyTime = EmitEffect(clone, emitCount)
	delay(destroyTime, function()
		clone:Destroy()
	end)
end

Replicator:Connect(function(PlayerName)
	if PlayerName then
		local Player = PlayersFolder:FindFirstChild(PlayerName)

		if Player then
			local Humanoid = Player:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				SpawnEffect(CaughtEffect.Effect, Humanoid.RootPart.Position, 15)
			end
		end
	end
end, "CaughtEffect")

-- Dev Product

task.delay(10, function()
	for _, object in Purchasables:GetChildren() do
		local Prompt = Instance.new("ProximityPrompt", object)
		Prompt.ActionText = "Purchase"
		Prompt.RequiresLineOfSight = false
		warn("Created Purchasable.", object.Name)

		local Module = require(object.Settings)

		Prompt.Triggered:Connect(function()
			local productId = Module.ID

			local success, _ = pcall(function()
				MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
			end)

			if success then
				print("Purchase prompt shown successfully")
			end
		end)
	end
end)

-- Values
local Connection = Connector.new()

Replicator:Connect(function(PageData: {
	Type: string,
	Enabled: boolean,
	Contents: {
		[number]: { ImageId: number, Selection: string },
	},
})
	local MainContainer = SurfaceGui.MainContainer
	local ContentFrame = MainContainer.ContentsFrame
	MainContainer.Visible = PageData.Enabled

	if Connection then
		Connection:End()
		Connection:Cleanup()
	end

	for _, object in ContentFrame:GetChildren() do
		if object:IsA("ImageLabel") then
			object:Destroy()
		end
	end

	if PageData.Enabled then
		for id, data in PageData.Contents do
			local template = Instance.new("ImageLabel", ContentFrame)
			template.Name = HttpService:GenerateGUID(false)
			template.Active = false
			template.BackgroundTransparency = 1
			template.Selectable = false
			template.Size = UDim2.fromOffset(350, 350)
			template.Image = `http://www.roblox.com/asset/?id={data.ImageId}`

			Connection:Attach(ContentFrame:GetAttributeChangedSignal("Selected"), function()
				local Value = ContentFrame:GetAttribute("Selected")

				if template.Name == Value then
					template.ImageColor3 = Color3.fromRGB(129, 129, 129)
				else
					template.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end)

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.Parent = template

			for _, block in Blocks:GetChildren() do
				local result = string.gsub(block.Name, "[^%d]", "")

				if tonumber(result) == id then
					local Button = block:FindFirstChild("Button") :: Part

					Connection:Attach(Button.Touched, function(_, part: Part)
						local Model = part:FindFirstAncestorOfClass("Model")
						local Player = Players:GetPlayerFromCharacter(Model)

						if Player == Players.LocalPlayer and ContentFrame:GetAttribute("Selected") ~= template.Name then
							Replicator:SendToServer("Selection", {
								Type = PageData.Type,
								Selected = data.Selection,
							})
							ContentFrame:SetAttribute("Selected", template.Name)
						end
					end)
				end
			end
		end
	end
end, "ServerGui")

Replicator:Connect(function(gameData: {
	Seekers: { number },
	Players: { number },
})
	local ContinueBtn = Reveal:FindFirstChild("ContinueBtn", true) :: GuiButton
	local SeekersList = Reveal:FindFirstChild("Seekers", true)
	local PlayersList = Reveal:FindFirstChild("Players", true)
	local Template = Reveal:FindFirstChild("Template", true) :: GuiButton

	local function CreateButton(color, parent, userid)
		local Player = Players:GetPlayerByUserId(userid)

		if Player then
			local nTemplate = Template:Clone()
			nTemplate.Visible = true
			nTemplate.Parent = parent
			nTemplate.BackgroundColor3 = color

			local PlayerName = nTemplate:FindFirstChild("PlayerName")

			if PlayerName then
				PlayerName.Text = Player.Name
			end
		end
	end

	for _, object in SeekersList:GetChildren() do
		if object:IsA("CanvasGroup") then
			object:Destroy()
		end
	end

	for _, object in PlayersList:GetChildren() do
		if object:IsA("CanvasGroup") then
			object:Destroy()
		end
	end

	warn(gameData)

	if gameData.Seekers then
		for _, userId in gameData.Seekers do
			CreateButton(Color3.fromRGB(255, 184, 185), SeekersList, userId)
		end
	end

	if gameData.Players then
		for _, userId in gameData.Players do
			CreateButton(Color3.fromRGB(188, 224, 255), PlayersList, userId)
		end
	end

	ContinueBtn.MouseButton1Click:Once(function()
		Reveal.Visible = false
	end)

	Reveal.Visible = true
end, "RevealFrame")

Replicator:Connect(function(name: string)
	local Sound = SoundService:FindFirstChild(name)

	if Sound then
		local Clone = Sound:Clone() :: Sound
		Clone.Parent = SoundService

		Clone:Play()

		task.delay(Clone.TimeLength, function()
			Clone:Destroy()
		end)
	end
end, "InSound")

Replicator:Connect(function(settings: {
	name: string,
	position: { [number]: number }
})
	local Sound = SoundService:FindFirstChild(settings.name)
	warn(Sound, settings)
	local Position = Vector3.new(unpack(settings.position)) 

	if Sound then
		local soundClone = Sound:Clone() :: Sound
		local attachment = Instance.new("Attachment", Terrain)
		attachment.WorldPosition = Position
		soundClone.Parent = attachment

		task.delay(soundClone.TimeLength, function()
			attachment:Destroy()
		end)

		soundClone:Play()
	end
end, "OutSound")

EndGameBtn.MouseButton1Click:Connect(function()
	Replicator:SendToServer("EndGame")
end)

Players.LocalPlayer:GetAttributeChangedSignal("IsAFK"):Connect(function()
	AFKBtn.TextLabel.Text = ({ [false] = "AFK [OFF]", [true] = "AFK [ON]" })[Players.LocalPlayer:GetAttribute("IsAFK")]
end)

AFKBtn.TextLabel.Text = ({ [false] = "AFK [OFF]", [true] = "AFK [ON]" })[Players.LocalPlayer:GetAttribute("IsAFK") or false]

AFKBtn.MouseButton1Click:Connect(function()
	Replicator:SendToServer("SetAFK")
end)

Replicator:init()
PageManger:init()
