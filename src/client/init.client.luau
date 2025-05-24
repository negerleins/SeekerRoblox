-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Shared = ReplicatedStorage:WaitForChild("Shared")

-- Shared
local __replicator = Shared:WaitForChild("Replicator")

-- Replicator
local Replicator = require(__replicator)

Replicator:Connect(function(data)
	warn(data)
end, "Replicate")

Replicator:init()