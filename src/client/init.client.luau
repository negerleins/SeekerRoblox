-- Dependencies
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Terrain = workspace.Terrain
local Purchasables = workspace:WaitForChild("Purchasables")
local VoteSection = workspace:WaitForChild("VoteSection")
local Blocks = VoteSection:WaitForChild("Blocks")
local Board = VoteSection:WaitForChild("Board")
local SurfaceGui = Board:WaitForChild("SurfaceGui")
local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local MainContainer = MainGui:WaitForChild("MainContainer")
local Left = MainContainer:WaitForChild("Left")
local AFKBtn = Left:WaitForChild("AFKBtn") :: ImageButton

-- Shared
local __replicator = Shared:WaitForChild("Replicator")
local __connector = Shared:WaitForChild("Connector")

-- Locals
local CaughtEffect = ReplicatedFirst:FindFirstChild("CaughtEffect")
local PlayersFolder = workspace:FindFirstChild("Players")

-- Replicator
local Replicator = require(__replicator)
local Connector = require(__connector)

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

for _, object in Purchasables:GetChildren() do
	local Prompt = Instance.new("ProximityPrompt")
	Prompt.ActionText = "Purchase"

	local Module = require(object.Settings)

	Prompt.Triggered:Connect(function()
		local productId = 000000

		local success, _ = pcall(function()
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
		end)

		if success then
			print("Purchase prompt shown successfully")
		end
	end)
end

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

Players.LocalPlayer:GetAttributeChangedSignal("IsAFK"):Connect(function()
	AFKBtn.TextLabel.Text = ({ [false] = "AFK [OFF]", [true] = "AFK [ON]" })[Players.LocalPlayer:GetAttribute("IsAFK")]
end)

AFKBtn.MouseButton1Click:Connect(function()
	Replicator:SendToServer("SetAFK")
end)

Replicator:init()
