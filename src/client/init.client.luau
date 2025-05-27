-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Terrain = workspace.Terrain
local ServerGui = Players.LocalPlayer.PlayerGui:WaitForChild("ServerGui")

-- Shared
local __replicator = Shared:WaitForChild("Replicator")

-- Locals
local CaughtEffect = ReplicatedFirst:FindFirstChild("CaughtEffect")
local PlayersFolder = workspace:FindFirstChild("Players")

-- Replicator
local Replicator = require(__replicator)

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

	for _, object in ContentFrame:GetChildren() do
		if object:IsA("ImageButton") then
			object:Destroy()
		end
	end

	if PageData.Enabled then
		for _, data in PageData.Contents do
			local template = Instance.new("ImageButton", ContentFrame)
			template.Name = "Template"
			template.Active = false
			template.BackgroundTransparency = 1
			template.Selectable = false
			template.Size = UDim2.fromOffset(150, 150)
			template.Image = `http://www.roblox.com/asset/?id={data.ImageId}`

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.Parent = template

			template.MouseButton1Click:Connect(function()
				Replicator:SendToServer("Selection", {
					Type = PageData.Type,
					Selected = data.Selection
				})
			end)
		end
	end
end, "ServerGui")

Replicator:init()
