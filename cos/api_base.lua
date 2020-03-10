-- Misc things

local ld = load

function _G.setfenv(func, env)
  checkArg(1, func, "function")
  checkArg(2, env, "table")
  return ld(func, "=setfenv", "bt", env) -- Might work
end

function _G.getfenv()
  return _G
end

_G._CC_DISABLE_LUA51_FEATURES = true -- Compatibility

_G.unpack = table.unpack

_G.unicode = nil -- We won't be needing this

function _G.loadstring(string, env)
  return load(string, "=" .. string, "t", _G)
end

_G._HOST = "OpenComputers " .. _VERSION

function table.maxn(t)
  checkArg(1, t, "table")
  return #t
end
