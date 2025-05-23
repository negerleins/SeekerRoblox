-- Dependencies
local Players = game:GetService("Players")

-- Service
local ClientService = setmetatable({
	CurrentInstance = nil,
}, {
	__index = {
		init = function(self)
			local module = self:require(Players.LocalPlayer.Team.Name)

			if module then
				module:start()
			end

			Players.LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
				module = self:require(Players.LocalPlayer.Team.Name)

				if module then
					module:start()
				end
			end)
		end,
		require = function(self, name)
			local exists = script:FindFirstChild(name)

			self:destroy()

			if exists then
				local module = require(exists)
				self.CurrentInstance = module
				return module
			else
				return false
			end
		end,
		destroy = function(self)
			if self.CurrentInstance then
				self.CurrentInstance:stop()
				self.CurrentInstance:cleanup()
			end

			self.CurrentInstance = nil
		end,
	},
})

ClientService:init()
