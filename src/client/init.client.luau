-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Terrain = workspace.Terrain
local ServerGui = Players.LocalPlayer.PlayerGui:WaitForChild("ServerGui")

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

-- Values
local Connection = Connector.new()

Replicator:Connect(function(PageData: {
	Type: string,
	Enabled: boolean,
	Contents: {
		[number]: { ImageId: number, Selection: string },
	},
})
	local Canvas = ServerGui.MainContainer.Canvas
	local ContentFrame = Canvas.ContentsFrame
	Canvas.Visible = PageData.Enabled

	if Connection then
		Connection:End()
		Connection:Cleanup()
	end

	for _, object in ContentFrame:GetChildren() do
		if object:IsA("ImageButton") then
			object:Destroy()
		end
	end

	if PageData.Enabled then
		for _, data in PageData.Contents do
			local template = Instance.new("ImageButton", ContentFrame)
			template.Name = HttpService:GenerateGUID(false)
			template.Active = false
			template.BackgroundTransparency = 1
			template.Selectable = false
			template.Size = UDim2.fromOffset(150, 150)
			template.Image = `http://www.roblox.com/asset/?id={data.ImageId}`

			Connection:Attach(ContentFrame:GetAttributeChangedSignal("Selected"), function()
				local Value = ContentFrame:GetAttribute("Selected")

				if template.Name == Value then
					template.ImageColor3 = Color3.fromRGB(138, 138, 138)
				else
					template.ImageColor3 =Color3.fromRGB(255, 255, 255)
				end
			end)

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.Parent = template

			template.MouseButton1Click:Connect(function()
				Replicator:SendToServer("Selection", {
					Type = PageData.Type,
					Selected = data.Selection
				})
				ContentFrame:SetAttribute("Selected", template.Name)
			end)
		end
	end
end, "ServerGui")

Replicator:init()
