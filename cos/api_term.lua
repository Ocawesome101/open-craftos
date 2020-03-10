-- term API --

local gpu = component.proxy(component.list("gpu")())

gpu.bind(component.list("screen")())

--local w,h = gpu.maxResolution()

--gpu.setResolution((w > 50 and 51) or 50, (h > 18 and 19) or 15) -- Requires a t2 GPU for full compatibility
gpu.setResolution(gpu.maxResolution())

-- These color codes are taken from the CC wiki
local ccColors = {
  [1]     = 0xf0f0f0,
  [2]     = 0xf2b233,
  [4]     = 0xe57fd8,
  [8]     = 0x99b2f2,
  [16]    = 0xdede6c,
  [32]    = 0x7fcc19,
  [64]    = 0xf2b2cc,
  [128]   = 0x4c4c4c,
  [256]   = 0x999999,
  [512]   = 0x4c99b2,
  [1024]  = 0xb266e5,
  [2048]  = 0x3366cc,
  [4096]  = 0x7f664c,
  [8192]  = 0x57a64e,
  [16384] = 0xcc4c4c,
  [32768] = 0x191919
}

local ccColorLetters = {
  ["0"] = 1,
  ["1"] = 2,
  ["2"] = 4,
  ["3"] = 8,
  ["4"] = 16,
  ["5"] = 32,
  ["6"] = 64,
  ["7"] = 128,
  ["8"] = 256,
  ["9"] = 512,
  ["a"] = 1024,
  ["b"] = 2048,
  ["c"] = 4096,
  ["d"] = 8192,
  ["e"] = 16284,
  ["f"] = 32768
}

_G.term = {}

local x, y = 1, 1
local w, h = gpu.getResolution()

gpu.fill(1, 1, w, h, " ")

function term.getCursorPos()
  return x, y
end

function term.isColor()
  return gpu.maxDepth() > 1
end

function term.getBackgroundColor()
  for k,v in pairs(ccColors) do
    if v == gpu.getBackground() then
      return k
    end
  end
  return 32768
end

function term.getTextColor()
  for k,v in pairs(ccColors) do
    if v == gpu.getForeground() then
      return k
    end
  end
  return 1
end

function term.scroll(amount)
  checkArg(1, amount, "number")
  gpu.copy(1, 1, w, h, 0, 0 - amount)
  gpu.fill(1, h, w, amount, " ")
end

function term.getPaletteColor(c)
  checkArg(1, c, "number")
  return ccColors[c]
end

function term.setPaletteColor(c, h)
  checkArg(1, c, "number")
  checkArg(2, h, "number")
  if not ccColors[c] then
    return false, "Invalid index"
  end
  ccColors[c] = h
end

function term.clear()
  gpu.fill(1, 1, w, h, " ")
end

function term.getSize()
  return gpu.getResolution()
end

function term.write(str)
  checkArg(1, str, "string", "number")
  if type(str) == "number" then
    return
  end
  str = str:gsub("\t", "    ")
  gpu.set(x, y, str)
  x = x + #str
end

local blink = false

function term.setCursorBlink(b)
  checkArg(1, b, "boolean")
  blink = b
  return
end

function term.getCursorBlink()
  return blink
end

function term.setCursorPos(nx, ny)
  checkArg(1, nx, "number")
  checkArg(2, ny, "number")
  if blink then
    local b,f = gpu.getBackground(), gpu.getForeground()
    gpu.setForeground(b)
    gpu.setBackground(f)
    local char = gpu.get(nx, ny)
    local chr2 = gpu.get(x, y)
    gpu.set(nx, ny, char)
    gpu.setForeground(f)
    gpu.setBackground(b)
    if x ~= nx or y ~= ny then gpu.set(x, y, chr2) end
  end
  x, y = nx, ny
end

function term.blit(text, fg, bg)
  checkArg(1, text, "string")
  checkArg(2, fg, "string")
  checkArg(3, bg, "string")
  if #text ~= #fg or #text ~= #bg then
    error("Mismatched argument lengths")
  end
  for i=1, #text, 1 do
    local f = ccColors[ccColorLetters[fg:sub(i,i)]] or fg:sub(i,i) == " " and gpu.getForeground()
    local b = ccColors[ccColorLetters[bg:sub(i,i)]] or bg:sub(i,i) == " " and gpu.getBackground()
    if not f then
      error("Invalid foreground color " .. fg:sub(i,i))
    end
    if not b then
      error("Invalid background color " .. bg:sub(i,i))
    end
    gpu.setForeground(f)
    gpu.setBackground(b)
    term.write(text:sub(i,i))
  end
end

function term.clearLine()
  gpu.set(1, y, (" "):rep(w))
end

function term.setBackgroundColor(c)
  checkArg(1, c, "number")
  if not ccColors[c] then
    error("Invalid color index " .. c)
  end
  gpu.setBackground(ccColors[c])
end

function term.setTextColor(c)
  checkArg(1, c, "number")
  if not ccColors[c] then
    error("Invalid color index " .. tostring(c))
  end
  gpu.setForeground(ccColors[c])
end

local nativeTerm = {}
  
function term.native()return nativeTerm end

function term.redirect(termObj)
  checkArg(1, termObj, "table")
  for k,v in pairs(term) do
    if not termObj[k] then
      error("Redirect object is missing method " .. k)
    end
  end
  
  term = termObj
end

-- Looking at you, people-who-spell-things-wrong
term.getTextColour = term.getTextColor
term.setTextColour = term.setTextColor
term.getBackgroundColour = term.getBackgroundColor
term.setBackgroundColour = term.setBackgroundColor
term.getPaletteColour = term.getPaletteColor
term.setPaletteColour = term.setPaletteColor
term.isColour = term.isColor

-- Preserve the native term, else term.native won't really work
for k,v in pairs(term) do
  nativeTerm[k] = v
end
