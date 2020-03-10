-- fs API --

_G.fs = component.proxy(computer.getBootAddress())

local oldOpen = fs.open

local function clean(path)
  if path:sub(1, 1) ~= "/" then
    return "/" .. path
  else
    return path
  end
end

function fs.open(file, mode)
  checkArg(1, file, "string")
  checkArg(2, mode, "string")
  
  local file = clean(file)
  local handle, err = oldOpen(file, mode)
  if not handle then
    error(err)
  end
  
  local h = {}
  setmetatable(h, {__handle = true})
  
  h.read = (mode == "r" or mode == "rw" or mode == "a") and function(amount)
    checkArg(1, amount, "number")
    return fs.read(handle, amount)
  end
  
  h.write = (mode == "w" or mode == "rw" or mode == "a") and function(data)
    checkArg(1, data, "string")
    return fs.write(handle, amount)
  end
  
  h.readAll = (mode == "r" or mode == "rw" or mode == "a") and function()
    local c = ""
    repeat
      local r = fs.read(handle, math.huge)
      c = c .. (r or "")
    until not r
    return c
  end
  
  function h.close()
    h = nil
    fs.close(handle)
  end
  
  return h
end

-- compaaaaaatibility
fs.isDir = function(p)checkArg(1,p,"string")return fs.isDirectory(clean(p))end
fs.getDrive = function(p)checkArg(1,p,"string")return nil end
fs.getSize = function(p)checkArg(1,p,"string")return fs.size(clean(p))end
fs.getFreeSpace = function()return fs.spaceTotal() - fs.spaceUsed()end
fs.makeDir = function()checkArg(1,p,"string")return fs.makeDirectory(clean(p))end
fs.move = function(p,d)checkArg(1,p,"string")checkArg(2,d,"string")return fs.rename(clean(p),clean(d))end
fs.delete = function(p)checkArg(1,p,"string")return fs.remove(clean(p))end
fs.find = function()return {} end -- I'm too lazy to properly implement this

local fslist = fs.list
fs.list = function(dir)
  checkArg(1, dir, "string")
  local files = fslist(clean(dir))
  files.n = nil
  return files
end

fs.getDir = function(path) -- Very ugly
  checkArg(1, path, "string")
  path = clean(path)
  local i = #path
  while true do
    if path:sub(i - 1,i - 1) == "/" or i == 1 then
      break
    end
    i = i - 1
  end
  return path:sub(0 - i)
end

function fs.getName(path)
  checkArg(1, path, "string")
  local last
  path = clean(path)
  for seg in path:gmatch("[^%/]+") do
    last = seg
  end
  return last
end

function fs.combine(path1, path2)
  checkArg(1, path1, "string")
  checkArg(2, path2, "string")
  local path = path1 .. "/" .. path2
  local rpath = ""
  for seg in path:gmatch("[^%/]+") do -- The power of gmatch :D
    rpath = rpath .. "/" .. seg
  end
  return clean(rpath)
end

-- Let's provide loadfile too, shall we?
function _G.loadfile(file, mode, env)
  checkArg(1, file, "string")
  checkArg(2, mode, "string", "nil")
  checkArg(3, env, "string", "nil")

  local handle, err = fs.open(file, "r")
  if not handle then
    error(err)
  end

  local data = handle.readAll()
  handle.close()

  return load(data, "=" .. file, (mode or "bt"), (env or _G))
end
