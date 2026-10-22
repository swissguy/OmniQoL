-- Forwarding entry shim to init.lua for compatibility across mod loaders
local initFn = require and (function()
  local ok, res = pcall(require, "init")
  if ok and res then return res end
  ok, res = pcall(require, "mods.init")
  if ok and res then return res end
  ok, res = pcall(require, "omni_qol.init")
  if ok and res then return res end
  return nil
end)()

if not initFn and type(dofile) == "function" then
  local candidates = { "mods/init.lua", "init.lua", "omni_qol/init.lua" }
  for _, path in ipairs(candidates) do
    local ok, res = pcall(dofile, path)
    if ok and res then
      initFn = res
      break
    end
  end
end

return function(mod)
  if type(initFn) == "function" then
    return initFn(mod)
  end
  local candidates = { "mods/init.lua", "init.lua", "omni_qol/init.lua" }
  if loadfile then
    for _, path in ipairs(candidates) do
      local chunk = loadfile(path)
      if chunk then return chunk()(mod) end
    end
  end
  error("[OmniQoL] Unable to locate init.lua from main.lua shim")
end
