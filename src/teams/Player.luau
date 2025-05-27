-- Dependencies
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Types
type ConnectorClass = typeof(setmetatable) & {
	Connections: { RBXScriptConnection },
} & {
	Attach: (
		self: ConnectorClass,
		connection: typeof(RunService.Heartbeat.Connect),
		method: (connection: RBXScriptConnection, ...any) -> ()
	) -> nil,
	End: (self: ConnectorClass) -> nil,
	Cleanup: (self: ConnectorClass) -> nil,
}

type ConenctorNew = {
	new: () -> ConnectorClass,
}

type MainArray = {
	Instances: { Instance },
	Connection: ConnectorClass,
}

type MainClass = typeof(setmetatable) & MainArray & {
	cleanup: (self: MainClass) -> nil,
	start: (self: MainClass) -> nil,
	stop: (self: MainClass) -> nil,
}

-- Task
local Connector = {
	new = function()
		return setmetatable({
			Connections = {},
		}, {
			__index = {
				Attach = function(self: ConnectorClass, connection: typeof(RunService.Heartbeat), method)
					local success, response

					success, response = pcall(connection.Connect, connection, function(...)
						if response then
							coroutine.wrap(method)(response, ...)
						end
					end)

					if not success then
						warn(response)
					end

					table.insert(self.Connections, response)
				end,
				End = function(self: ConnectorClass)
					for _, connection: RBXScriptConnection in self.Connections do
						connection:Disconnect()
					end
				end,
				Cleanup = function(self: ConnectorClass)
					self.Connections = {}
				end,
			},
		})
	end,
} :: ConenctorNew

-- Functions
local function EmitEffect(object, emitCount: number?)
	for _, effect: ParticleEmitter in object:GetChildren() do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
			effect:Emit(emitCount)
		end
	end
end

-- Variables
local Presets = Lighting:WaitForChild("LightingPresets")

-- Modules
local Normal = require(Presets:WaitForChild("Normal"))

-- Metadata
return setmetatable({
	Instances = {},
	Connection = Connector.new(),
}, {
	__index = {
		cleanup = function(self: MainClass)
			self.Connection:Cleanup()
			self.Instances = {}
		end,
		start = function(self: MainClass)
			for _, method in Normal do
				method()
			end
		end,
		stop = function(self)
			self.Connection:End()

			for _, object: Instance in self.Instances do
				object:Destroy()
			end
		end,
	},
}) :: MainClass
