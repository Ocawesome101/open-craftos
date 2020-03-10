-- An OS that attempts to be mostly API-compatible with ComputerCraft's CraftOS. setfenv might work. --

local rootfs = component.proxy(computer.getBootAddress())

function _G.loadfile(file, mode, env)
  checkArg(1, file, "string")
  checkArg(2, mode, "string", "nil")
  checkArg(3, env, "table", "nil")

  local handle, err = rootfs.open(file, "r")
  if not handle then
    error(err .. " not found")
  end

  local data = ""
  repeat
    local chunk = rootfs.read(handle, math.huge)
    data = data .. (chunk or "")
  until not chunk

  rootfs.close(handle)

  return load(data, "=" .. file, mode or "bt", env or _G)
end

local function include(file)
  local ok, err = loadfile(file)
  if not ok then 
    error(err)
  end

  ok()
end

include("/cos/api_base.lua")

include("/cos/api_os.lua")

include("/cos/api_term.lua")

include("/cos/api_fs.lua")

include("/cos/api_peripheral.lua")

include("/cos/api_redstone.lua")

include("/cos/api_http.lua")

local ok, err = loadfile("/rom/bios.lua")
if not ok then
  error(err)
end

local bios = coroutine.create(ok)
local eventData = {}
local pe = os.pullEventRaw
while true do
  local ok, filter = coroutine.resume(bios, table.unpack(eventData))
  if not ok then
    error(filter)
  end
  eventData = {pe()}
end

error("BIOS exited!")
