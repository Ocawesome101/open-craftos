-- Peripheral API --

local sides = {
  right = false,
  left = false,
  up = false,
  down = false,
  back = false
}

_G.peripheral = {}

function peripheral.isPresent()
  return false
end
