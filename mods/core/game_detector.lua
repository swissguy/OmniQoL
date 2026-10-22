-- ============================================================================
-- OmniQoL: Game & Generation Detector
-- Cross-generation support for Gen 1 (Red, Blue, Yellow) and Gen 2 (Gold, Silver, Crystal)
-- ============================================================================

local GameDetector = {}

local GEN1_GAMES = {
  red = true,
  blue = true,
  yellow = true,
}

local GEN2_GAMES = {
  gold = true,
  silver = true,
  crystal = true,
}

--- Resolves the normalized game identifier ('red', 'blue', 'yellow', 'gold', 'silver', 'crystal')
-- @param mod Table provided by the recomp mod loader
-- @param game Optional Game instance if available
-- @return string Normalized game identifier in lowercase
function GameDetector.detectGame(mod, game)
  -- 1. Check mod table passed by recomp engine
  if mod and mod.game and type(mod.game) == "string" then
    local g = mod.game:lower():gsub("[^%w]", "")
    if GEN1_GAMES[g] or GEN2_GAMES[g] then return g end
    if g:find("crystal") then return "crystal" end
    if g:find("gold") then return "gold" end
    if g:find("silver") then return "silver" end
    if g:find("yellow") then return "yellow" end
    if g:find("blue") then return "blue" end
    if g:find("red") then return "red" end
  end

  -- 2. Check GameVersion singleton if present in engine
  local okGV, GV = pcall(require, "src.core.GameVersion")
  if okGV and GV and type(GV.get) == "function" then
    local okCall, v = pcall(GV.get)
    if okCall and v and type(v) == "string" then
      local g = v:lower():gsub("[^%w]", "")
      if GEN1_GAMES[g] or GEN2_GAMES[g] then return g end
      if g:find("crystal") then return "crystal" end
      if g:find("gold") then return "gold" end
      if g:find("silver") then return "silver" end
      if g:find("yellow") then return "yellow" end
      if g:find("blue") then return "blue" end
      if g:find("red") then return "red" end
    end
  end

  -- 3. Check active or global Game object
  local targetGame = game
  if not targetGame then
    local okGame, Game = pcall(require, "src.core.Game")
    if okGame and Game then targetGame = Game end
  end

  if targetGame then
    -- Check game.version
    if targetGame.version and type(targetGame.version) == "string" then
      local v = targetGame.version:lower()
      if v:find("crystal") then return "crystal" end
      if v:find("gold") then return "gold" end
      if v:find("silver") then return "silver" end
      if v:find("yellow") then return "yellow" end
      if v:find("blue") then return "blue" end
      if v:find("red") then return "red" end
    end

    -- Check game.gameId or game.id
    local gid = targetGame.gameId or targetGame.id
    if gid and type(gid) == "string" then
      local idLower = gid:lower()
      if idLower:find("crystal") then return "crystal" end
      if idLower:find("gold") then return "gold" end
      if idLower:find("silver") then return "silver" end
      if idLower:find("yellow") then return "yellow" end
      if idLower:find("blue") then return "blue" end
      if idLower:find("red") then return "red" end
    end

    -- Check game.romName
    if targetGame.romName and type(targetGame.romName) == "string" then
      local rom = targetGame.romName:lower()
      if rom:find("crystal") then return "crystal" end
      if rom:find("gold") then return "gold" end
      if rom:find("silver") then return "silver" end
      if rom:find("yellow") then return "yellow" end
      if rom:find("blue") then return "blue" end
      if rom:find("red") then return "red" end
    end
  end

  -- Default fallback is red (Gen 1)
  return "red"
end

--- Returns the generation string ("gen1" or "gen2") for the given game or environment
-- @param mod Table provided by mod loader
-- @param game Optional Game instance
-- @return string "gen1" or "gen2"
function GameDetector.detectGeneration(mod, game)
  local gameId = GameDetector.detectGame(mod, game)
  if GEN2_GAMES[gameId] then
    return "gen2"
  end
  return "gen1"
end

--- Checks if active target is Gen 1
function GameDetector.isGen1(mod, game)
  return GameDetector.detectGeneration(mod, game) == "gen1"
end

--- Checks if active target is Gen 2
function GameDetector.isGen2(mod, game)
  return GameDetector.detectGeneration(mod, game) == "gen2"
end

return GameDetector
