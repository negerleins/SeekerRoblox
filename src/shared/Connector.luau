type Connection = { 
    Connect: (self: Connection, func: () -> nil) -> {
        Disconnect: (self: Connection) -> nil
    } 
}

type ConnectorClass = typeof(setmetatable) & {
	Connections: { RBXScriptConnection },
} & {
	Attach: (
		self: ConnectorClass,
		connection: Connection,
		method: (connection: RBXScriptConnection, ...any) -> ()
	) -> nil,
	End: (self: ConnectorClass) -> nil,
	Cleanup: (self: ConnectorClass) -> nil,
}

type ConenctorNew = {
	new: () -> ConnectorClass,
}

local Connector = {
	new = function()
		return setmetatable({
			Connections = {},
		}, {
			__index = {
				Attach = function(self: ConnectorClass, connection: Connection, method)
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
					for _, connection in self.Connections do
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

return Connector
