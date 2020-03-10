-- Partial reimplementation of the os API --

function os.epoch()
  return os.time()
end

local timers = {}

local function pullEvent() -- Wrap signals into CraftOS-compatible events
  local e = {computer.pullSignal()}
  local rtn = {}
  if e[1] == "key_down" then
    if e[3] >= 32 and e[3] < 127 then
      computer.pushSignal("char", string.char(e[3]))
    end
    rtn[1] = "key"
    rtn[2] = e[4]
    rtn[3] = false
  elseif e[1] == "key_up" then
    rtn[1] = e[1]
    rtn[2] = e[4]
  elseif e[1] == "clipboard" then
    rtn[1] = "paste"
    rtn[2] = e[3]
  elseif e[1] == "touch" then
    rtn[1] = "mouse_click"
    rtn[2] = e[5]
    rtn[3] = e[3]
    rtn[4] = e[4]
  elseif e[1] == "drop" then
    rtn[1] = "mouse_up"
    rtn[2] = e[5]
    rtn[3] = e[3]
    rtn[4] = e[4]
  else
    rtn = e
  end
  local time = computer.uptime()
  for i=1,#timers,1 do
    if timers[i] <= time then
      computer.pushSignal("timer", i)
      timers[i] = nil
    else
      timers[i] = computer.uptime()
    end
  end
  return table.unpack(rtn)
end

function os.pullEventRaw(filter)
  checkArg(1, filter, "string", "nil")
  while true do
    local e = {pullEvent()}
    if e[1] == filter or not filter then
      return table.unpack(e)
    end
  end
end

function os.pullEvent(filter)
  local e = {os.pullEventRaw()}
  if e[1] == "terminate" then
    error("terminated")
  end
  return table.unpack(e)
end

os.queueEvent = computer.pushSignal

function os.startTimer(time)
  checkArg(1, time, "number")
  local time = time or 0
  local id = #timers + 1
  local start = computer.uptime()
  timers[id] = start + time
  return id
end

function os.cancelTimer(id)
  checkArg(1, id, "number")
  if timers[id] then
    timers[id] = nil
  end
end

function os.shutdown()
  computer.shutdown()
end

function os.reboot()
  computer.shutdown(true)
end
