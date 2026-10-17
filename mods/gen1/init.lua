-- ============================================================================
-- OmniQoL: Quality of Life Mod Entry Point (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
-- ============================================================================

return function(mod)
  -- Determine base path of the mod and ensure package.path can resolve submodules
  local modDir = mod.dir or mod.path or "mods/gen1"
  local cleanDir = modDir:gsub("\\", "/")
  if not package.path:find(cleanDir, 1, true) then
    package.path = cleanDir .. "/?.lua;" .. cleanDir .. "/?/init.lua;" .. package.path
  end

  -- Safe submodule loader supporting require, love.filesystem, and dofile
  local function loadModule(relPath)
    -- Try direct require
    local reqPath = relPath:gsub("%.lua$", ""):gsub("/", ".")
    local ok, res = pcall(require, reqPath)
    if ok and res then return res end

    -- Try prefixing with mod directory
    local fullReqPath = cleanDir:gsub("^mods/", ""):gsub("/", ".") .. "." .. reqPath
    ok, res = pcall(require, fullReqPath)
    if ok and res then return res end

    -- Try love.filesystem.load
    if love and love.filesystem and love.filesystem.load then
      local lfsPath = cleanDir .. "/" .. relPath
      if not lfsPath:match("%.lua$") then lfsPath = lfsPath .. ".lua" end
      ok, res = pcall(love.filesystem.load, lfsPath)
      if ok and type(res) == "function" then
        return res()
      end
    end

    -- Try standard dofile
    if type(dofile) == "function" then
      local doPath = cleanDir .. "/" .. relPath
      if not doPath:match("%.lua$") then doPath = doPath .. ".lua" end
      ok, res = pcall(dofile, doPath)
      if ok and res then return res end
    end

    error(string.format("[OmniQoL] Could not load module: %s", relPath))
  end

  -- Initialize Core Framework
  local ModuleManager = loadModule("core/module_manager.lua")
  local SettingsMenu = loadModule("core/settings_menu.lua")

  local manager = ModuleManager.new(mod)

  -- Register Modules
  local RunningModule = loadModule("modules/running.lua")
  RunningModule.register(manager)

  -- Setup Options Menu injection & In-Game UI screen
  SettingsMenu.setup(mod, manager)

  -- Log successful boot
  if mod.log and type(mod.log.info) == "function" then
    mod.log:info("OmniQoL suite loaded successfully for Gen 1 (Running Shoes active).")
  else
    print("[OmniQoL] Loaded successfully for Pokémon Red, Blue & Yellow.")
  end
end
