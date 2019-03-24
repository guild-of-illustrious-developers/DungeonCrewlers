local msgpack = require("MessagePack")
local websocket = require("websocket")
local net = require("net")

local Client = class("Client")

function Client:__construct(server, ws)
  self.server = server
  self.ws = ws
  self.endpoint = self.ws.sock:getpeername()
  self.closed = false

  -- websocket events
  ws:on_message(function(ws, message) self:_onMessage(message) end)
  ws:on_close(function() self:_onClose() end)

  self:sendPacket(-1, net) -- send protocol actions
end

function Client:close()
  self.ws:close()
end

-- handle websocket message
function Client:_onMessage()
  async(function()
    local data = msgpack.unpack(message)
    local p = nil
    local c = nil
    if data then
      p = data[1]
      c = data[2]
    end

    if p and c then
      self:onPacket(p, c)
    end
  end)
end

-- handle websocket close event
function Client:_onClose()
  if not self.closed then -- multiple close events fix
    self.closed = true

    async(function()
      self:onClose()
      self.server:onDisconnect(self) -- server disconnect event
    end)
  end
end

function Client:onClose()
end

function Client:onPacket(protocol, data)
end

function Client:sendPacket(protocol, data)
  if protocol and data then
    self.ws:send(msgpack.pack({protocol, data}), websocket.BINARY)
  end
end

return Client
