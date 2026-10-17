-- Forwarding entry shim to init.lua for compatibility across mod loaders
local initFn = require and (function()
  local ok, res = pcall(require, "init")
  if ok and res then return res end
  ok, res = pcall(require, "mods.gen1.init")
  if ok and res then return res end
  return nil
end)()

if not initFn and type(dofile) == "function" then
  local ok, res = pcall(dofile, "mods/gen1/init.lua")
  if ok and res then initFn = res end
end

return function(mod)
  if type(initFn) == "function" then
    return initFn(mod)
  end
  local chunk = loadfile and loadfile("mods/gen1/init.lua")
  if chunk then return chunk()(mod) end
  error("[OmniQoL] Unable to locate init.lua from main.lua shim")
end
