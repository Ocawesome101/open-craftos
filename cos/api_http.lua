-- http API --

local internet = component.list("internet")()
if not internet then
  return false
end

internet = component.proxy(internet)

_G.http = {}

http.checkURL = function()return true end

http.request = function(...)
  local args = {...}
  os.queueEvent("http_success", args[1], internet.request(...))
end
