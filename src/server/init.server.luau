-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")

-- Shared
local __replicator = Shared:WaitForChild("Replicator")

-- Replicator
local Replicator = require(__replicator)

Replicator:Connect(function(player, ...)
	
	local PlayerName = unpack(...)
	warn(player.Name, "requested to kill", PlayerName)  
end, "PlayerHit")

Replicator:init()

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

	player.CharacterAdded:Connect(function(character) end)
end)
