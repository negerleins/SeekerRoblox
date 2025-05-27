-- Dependencies
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Variables
local Imports = ReplicatedStorage:WaitForChild("Imports") :: Folder & {
	Packet: ModuleScript,
	HashLib: ModuleScript,
}

-- Imports
local __packet = Imports:FindFirstChild("Packet") or Imports:WaitForChild("Packet")
local __hashlib = Imports:FindFirstChild("HashLib") or Imports:WaitForChild("HashLib")

-- HashLib
local HashLib = require(__hashlib)

-- Replicator
local Replicator = setmetatable({
	Packets = {
		Client = nil,
		Server = nil,
	},
	Connections = {
		Client = {},
		Server = {},
	},
}, {
	__index = {
		init = function(self)
			local Packet = require(__packet)

			if RunService:IsClient() then
				local NewPacket = Packet("Replication", Packet.StringLong):Response(Packet.Any)
				self.Packets.Client = NewPacket

				NewPacket.OnClientInvoke = function(data)
                    local array = HttpService:JSONDecode(data) :: { Category: string, Data: { any } }
					local method = rawget(self.Connections.Client, array.Category)

					if method then
						local success, response = pcall(method, unpack(array.Data))
						if not success then
							warn(response)
						end
					end
				end
			elseif RunService:IsServer() then
				local NewPacket = Packet("Replication", Packet.StringLong):Response(Packet.Any)
				self.Packets.Server = NewPacket

				NewPacket.OnServerInvoke = function(player: Player, data: any)
					local parse = HttpService:JSONDecode(data) :: {
						timestamp: string,
						signature: string,
						publickey: string,
						payload: string,
						category: string,
					}
                    
					if typeof(parse) ~= "table" then
						return player:Kick("Invalid parse, please reconnect")
					end

					if not rawget(parse, "category") then
						return player:Kick("Invalid missing data, please reconnect")
					end

					if typeof(parse.category) ~= "string" then
						return player:Kick("Invalid category, please reconnect")
					end

					local method = rawget(self.Connections.Server, parse.category)
					if not method then
						return player:Kick("Invalid method, please reconnect")
					end

					local expectedSig = HashLib.hmac(HashLib.sha256, parse.publickey, parse.payload)
					if expectedSig ~= parse.signature then
						return player:Kick("Invalid sync, please reconnect")
					end

					local timestamp = DateTime.now().UnixTimestamp
					if math.abs(timestamp - tonumber(parse.timestamp)) > 20 then
						return player:Kick("Lost connection to server, please reconnect.")
					end

					local __data = HttpService:JSONDecode(parse.payload)

					local success, response = pcall(method, player, unpack(__data))
					if not success and response then
						warn(parse.category, response. player, unpack(__data))
					end

					return
				end
			end

			print("Replication: Initialized")
		end,
		SendToServer = function(self, category: string, ...) -- Never trust what the client says.
			local secret = `blacksmith-v1-public-{HttpService:GenerateGUID(false)}`
			local timestamp = DateTime.now().UnixTimestamp

			local data = { ... }
			local sig = HashLib.hmac(HashLib.sha256, secret, HttpService:JSONEncode(data))
			local _sentdata = {
				["timestamp"] = timestamp,
				["signature"] = sig,
				["publickey"] = secret,
				["payload"] = HttpService:JSONEncode(data),
				["category"] = category,
			}

			local _encoded = HttpService:JSONEncode(_sentdata)
			self.Packets.Client:Fire(_encoded)
		end,
		SendToClient = function(self, category, player, ...)
            local data = HttpService:JSONEncode({
                Category = category,
                Data = { ... },
            })

			self.Packets.Server:FireClient(player, data)
		end,
		SendToAllClients = function(self, category, ...)
			for _, player in Players:GetPlayers() do
                self:SendToClient(category, player, ...)
			end
		end,
		Connect = function(self, callback, name)
			if RunService:IsClient() then
				rawset(self.Connections.Client, name, callback)
			elseif RunService:IsServer() then
				rawset(self.Connections.Server, name, callback)
			end
		end,
	},
})

return Replicator
