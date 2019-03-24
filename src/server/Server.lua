
local config = require("config")
local websocket = require("websocket")
local Client = require("Client")

local Server = class("Server")

function Server:__construct()
  self.clients = {}

  -- start websocket server
  self.wss = websocket.server.ev.listen({
    port = config.port,
    default = function(ws) self:onConnect(ws) end
  })

  print("Server launched on port "..config.port..".")

  -- every 10s tick test
  self.tick_task = itask(10, function()
    print("server tick: "..clock().."s")
  end)
end

function Server:close()
  self.tick_task:remove()

  -- close clients
  for client in pairs(self.clients) do
    client:close()
  end

  print("Server exited.")
end

function Server:onConnect(ws)
  -- new client
  local client = Client(self, ws)
  self.clients[client] = true

  print("client ("..client.endpoint..") connected")
end

function Server:onDisconnect(client)
  self.clients[client] = nil

  print("client ("..client.endpoint..") disconnected")
end

return Server
