-- http API --

local internet = component.list("internet")()
if not internet then
  return false
end

internet = component.proxy(internet)

_G.http = {}

http.checkURL = function()return true end

http.get = function(url)
  checkArg(1, url, "string")
  local ok, err = internet.request(url)
  local r = {}
  ok.finishConnect()
  local responseCode, message, headers = ok.response()
  function r.read(a)
    return ok.read(a)
  end
  function r.readAll()
    local r = ""
    repeat
      local c = ok.read(math.huge)
      r = r .. (c or "")
    until not c
    return r
  end
  function r.close()
    ok.close()
    r = nil
  end
  function r.getResponseHeaders()
    return headers
  end
  return r
end
