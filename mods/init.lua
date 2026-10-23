-- ============================================================================
-- OmniQoL: Quality of Life Mod Entry Point
-- Target Engines: Gen1Recomp & Gen2Recomp (bryanthaboi/gen1recomp, gen2recomp)
-- Supported Games: Red, Blue, Yellow, Gold, Silver, Crystal
-- ============================================================================

return function(mod)
  -- Determine base path of the mod and ensure package.path can resolve submodules
  local modDir = mod.dir or mod.path or "mods"
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

    -- Try prefixing with omni_qol
    local omniReqPath = "omni_qol." .. reqPath
    ok, res = pcall(require, omniReqPath)
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

      -- Also test relative to current working directory
      if not doPath:find("^mods/") then
        local fallbackPath = "mods/" .. relPath
        if not fallbackPath:match("%.lua$") then fallbackPath = fallbackPath .. ".lua" end
        ok, res = pcall(dofile, fallbackPath)
        if ok and res then return res end
      end
    end

    error(string.format("[OmniQoL] Could not load module: %s", relPath))
  end

  -- Initialize Core Framework & Game Detection
  local GameDetector = loadModule("core/game_detector.lua")
  local ModuleManager = loadModule("core/module_manager.lua")
  local SettingsMenu = loadModule("core/settings_menu.lua")

  local manager = ModuleManager.new(mod, GameDetector)
  local gen = manager:getGeneration()
  local gameId = manager:getGame()

  -- Register Running Module (Universal: Gen 1 & Gen 2)
  local RunningModule = loadModule("modules/running.lua")
  RunningModule.register(manager)

  -- Register Gen 1 Modules (gated by supportedGenerations = {"gen1"} inside ModuleManager)
  local ExpShareModule = loadModule("modules/exp_share.lua")
  ExpShareModule.register(manager)

  local TradeEvosModule = loadModule("modules/trade_evos.lua")
  TradeEvosModule.register(manager)

  local Catch151Module = loadModule("modules/catch_151.lua")
  Catch151Module.register(manager)

  local ForgetHMsModule = loadModule("modules/forget_hms.lua")
  ForgetHMsModule.register(manager)

  local MoveRelearnerModule = loadModule("modules/move_relearner.lua")
  MoveRelearnerModule.register(manager)

  -- Setup Options Menu injection & In-Game UI screen
  SettingsMenu.setup(mod, manager)

  -- Expose mod manager via official Gen1Recomp Inter-Mod API (mod.exports)
  mod.exports = manager

  -- Log successful boot
  local logMsg
  if gen == "gen2" then
    logMsg = string.format("OmniQoL suite loaded successfully for Gen 2 [%s] (Running Shoes active).", gameId:upper())
  else
    logMsg = string.format("OmniQoL suite loaded successfully for Gen 1 [%s] (Running Shoes, EXP Share, Trade Evos, Catch 151, Relearner & Forget HMs active).", gameId:upper())
  end

  if mod.log and type(mod.log.info) == "function" then
    mod.log:info(logMsg)
  else
    print("[OmniQoL] " .. logMsg)
  end

  return manager
end
