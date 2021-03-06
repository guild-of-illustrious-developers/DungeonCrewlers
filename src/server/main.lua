local ev = require("ev")
local msgpack = require("MessagePack")
local Luaseq = require("Luaseq")
async = Luaseq.async
local Luaoop = require("Luaoop")
class = Luaoop.class

local config = require("config")
local Server = require("Server")

-- globals

-- return current loop time in seconds
function clock()
  return ev.Loop.default:now()
end

-- execute callback after delay (seconds)
-- return task (task:remove() to prevent callback)
function task(delay, cb)
  local timer = ev.Timer.new(function(loop, timer, revents)
    cb()
    timer:stop(loop)
  end, delay)

  function timer:remove()
    self:stop(ev.Loop.default)
  end

  timer:start(ev.Loop.default)
  return timer
end

-- execute callback with interval (seconds)
-- return task (task:remove() to stop interval)
function itask(delay, cb)
  local timer = ev.Timer.new(function(loop, timer, revents)
    cb()
  end, delay, delay)

  function timer:remove()
    self:stop(ev.Loop.default)
  end

  timer:start(ev.Loop.default)
  return timer
end

-- create server

server = Server()

-- loop

-- loop stop function (with async support)
local function stop()
  async(function()
    server:close()
    ev.Loop.default:unloop()
  end)
end

-- SIGINT
local sigint = ev.Signal.new(function(loop, sig)
  print() -- Ctrl-C new line
  stop()
end, 2)
sigint:start(ev.Loop.default)

-- SIGTERM
local sigterm = ev.Signal.new(function(loop, sig)
  stop()
end, 15)
sigterm:start(ev.Loop.default)

-- start loop
ev.Loop.default:loop()
