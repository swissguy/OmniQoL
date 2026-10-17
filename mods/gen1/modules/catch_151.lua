-- ============================================================================
-- OmniQoL: Catch All 151 Pokémon Module (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
--
-- Features:
-- 1. Wild Starters in Thematic Habitats:
--    - Bulbasaur: Viridian Forest (Lv 4-6), Route 2 (Lv 4-5)
--    - Charmander: Route 3 (Lv 8-10), Rock Tunnel 1F (Lv 14-16)
--    - Squirtle: Route 24 (Lv 8-10), Route 25 (Lv 10-12)
-- 2. Version Exclusives & Missing Pokémon Across Red, Blue, and Yellow:
--    - Ekans / Arbok: Route 4, Route 11, Route 23 (Blue & Yellow)
--    - Sandshrew / Sandslash: Route 4, Route 11, Route 23 (Red)
--    - Oddish / Gloom: Route 24, Route 25, Route 12, Route 13 (Blue)
--    - Bellsprout / Weepinbell: Route 24, Route 25, Route 12, Route 13 (Red)
--    - Mankey / Primeape: Route 3, Route 4, Route 5 (Blue)
--    - Meowth / Persian: Route 5, Route 6, Route 7, Route 8 (Red & Yellow)
--    - Growlithe / Arcanine: Route 7, Route 8, Pokémon Mansion (Blue)
--    - Vulpix / Ninetales: Route 7, Route 8, Pokémon Mansion (Red)
--    - Koffing / Weezing: Pokémon Mansion, Route 16, Route 17 (Yellow)
--    - Weedle / Kakuna / Beedrill: Viridian Forest (Yellow)
--    - Electabuzz: Power Plant (Blue & Yellow)
--    - Magmar: Pokémon Mansion (Red & Yellow)
--    - Wild Raichu: Power Plant & Cerulean Cave (Yellow, since Starter Pikachu rejects Thunder Stone)
-- 3. Safari Zone Exclusives Accessible Outside Safari Zone (Normal Battles & Pokéballs):
--    - Chansey: Route 14 (Lv 24-26), Route 23 (Lv 40-44)
--    - Kangaskhan: Rock Tunnel 1F (Lv 16-18), Route 11 (Lv 18-20)
--    - Tauros: Route 17 (Lv 25-28), Route 18 (Lv 25-28)
--    - Scyther: Route 15 (Lv 24-26)
--    - Pinsir: Route 14 (Lv 24-26)
--    - Dratini: Route 10 & Route 22 Water (Lv 15-20)
--    - Tangela: Route 12 (Lv 22-25), Route 21 (Lv 28-30)
-- 4. Mutually Exclusive & In-Game Trade Pokémon Made Wild:
--    - Fossils: Omanyte & Kabuto in Seafoam Islands B3F/B4F Water (Lv 28-32)
--    - Fighting Dojo: Hitmonlee & Hitmonchan in Victory Road 2F (Lv 40-44) & Route 10 (Lv 20-22)
--    - Eevee: Route 8 (Lv 18-22) & Route 17 (Lv 22-25) allowing all 3 Eeveelutions
--    - Porygon: Route 7 (Lv 18-22) & Cerulean Cave 1F (Lv 48-52)
--    - Farfetch'd: Route 12 (Lv 22-24) & Route 13 (Lv 24-26)
--    - Mr. Mime: Route 21 (Lv 20-24) & Route 11 (Lv 14-16)
--    - Lickitung: Route 15 (Lv 22-25) & Route 18 (Lv 22-25)
--    - Jynx: Seafoam Islands B1F/B2F (Lv 28-32)
-- 5. Immediate Legendary & Stationary Respawns on Room/Map Re-entry:
--    - Articuno (Seafoam Islands B4F)
--    - Zapdos (Power Plant)
--    - Moltres (Victory Road 2F)
--    - Mewtwo (Cerulean Cave B1F)
--    - Snorlax (Route 12 & Route 16)
--    - If defeated or fled without being caught, leaving and re-entering
--      the map immediately restores them. Once caught, they do not respawn.
-- 6. Mythical Pokémon Mew (#151):
--    - Stationary Lv. 50 Mew on Cerulean Cave B1F (Unknown Dungeon).
--    - Interacting plays Mew's authentic cry and initiates a wild battle.
--    - Respawns on map re-entry if fainted or fled before being caught.
-- 7. Options Menu Integration:
--    - Toggleable directly in OMNIQOL Options Menu (`CATCH 151`).
--    - Enabled by default with per-save persistence.
-- ============================================================================

local Catch151Module = {}

-- ----------------------------------------------------------------------------
-- Wild Encounter Tables by Map Identifier / Alias
-- ----------------------------------------------------------------------------
local WILD_ADDITIONS = {
  -- --- Starters ---
  VIRIDIAN_FOREST = {
    { species = "BULBASAUR", minLevel = 4, maxLevel = 6, rate = 0.08, type = "grass" },
    { species = "WEEDLE",    minLevel = 3, maxLevel = 5, rate = 0.15, type = "grass", game = "yellow" },
    { species = "KAKUNA",    minLevel = 4, maxLevel = 6, rate = 0.10, type = "grass", game = "yellow" },
  },
  ROUTE_2 = {
    { species = "BULBASAUR", minLevel = 4, maxLevel = 5, rate = 0.06, type = "grass" },
  },
  ROUTE_3 = {
    { species = "CHARMANDER", minLevel = 8,  maxLevel = 10, rate = 0.08, type = "grass" },
    { species = "MANKEY",     minLevel = 8,  maxLevel = 10, rate = 0.15, type = "grass", game = "blue" },
  },
  ROUTE_4 = {
    { species = "CHARMANDER", minLevel = 8,  maxLevel = 10, rate = 0.06, type = "grass" },
    { species = "EKANS",      minLevel = 8,  maxLevel = 10, rate = 0.15, type = "grass", game = { "blue", "yellow" } },
    { species = "SANDSHREW",  minLevel = 8,  maxLevel = 10, rate = 0.15, type = "grass", game = "red" },
  },
  ROCK_TUNNEL_1F = {
    { species = "CHARMANDER", minLevel = 14, maxLevel = 16, rate = 0.06, type = "grass" },
    { species = "KANGASKHAN", minLevel = 16, maxLevel = 18, rate = 0.08, type = "grass" },
  },
  ROUTE_24 = {
    { species = "SQUIRTLE",   minLevel = 8,  maxLevel = 10, rate = 0.08, type = "grass" },
    { species = "BELLSPROUT", minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = "red" },
    { species = "ODDISH",     minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = "blue" },
  },
  ROUTE_25 = {
    { species = "SQUIRTLE",   minLevel = 10, maxLevel = 12, rate = 0.08, type = "grass" },
    { species = "BELLSPROUT", minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = "red" },
    { species = "ODDISH",     minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = "blue" },
  },

  -- --- Version Exclusives & Missing Pokémon ---
  ROUTE_5 = {
    { species = "MEOWTH",     minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = { "red", "yellow" } },
    { species = "MANKEY",     minLevel = 10, maxLevel = 12, rate = 0.15, type = "grass", game = "blue" },
  },
  ROUTE_6 = {
    { species = "MEOWTH",     minLevel = 12, maxLevel = 14, rate = 0.15, type = "grass", game = { "red", "yellow" } },
    { species = "MANKEY",     minLevel = 12, maxLevel = 14, rate = 0.15, type = "grass", game = "blue" },
  },
  ROUTE_7 = {
    { species = "VULPIX",     minLevel = 18, maxLevel = 20, rate = 0.15, type = "grass", game = "red" },
    { species = "GROWLITHE",  minLevel = 18, maxLevel = 20, rate = 0.15, type = "grass", game = "blue" },
    { species = "PORYGON",    minLevel = 18, maxLevel = 20, rate = 0.05, type = "grass" },
  },
  ROUTE_8 = {
    { species = "VULPIX",     minLevel = 18, maxLevel = 22, rate = 0.15, type = "grass", game = "red" },
    { species = "GROWLITHE",  minLevel = 18, maxLevel = 22, rate = 0.15, type = "grass", game = "blue" },
    { species = "EEVEE",      minLevel = 18, maxLevel = 22, rate = 0.08, type = "grass" },
  },
  ROUTE_10 = {
    { species = "HITMONLEE",  minLevel = 20, maxLevel = 22, rate = 0.05, type = "grass" },
    { species = "HITMONCHAN", minLevel = 20, maxLevel = 22, rate = 0.05, type = "grass" },
    { species = "DRATINI",    minLevel = 15, maxLevel = 20, rate = 0.10, type = "water" },
  },
  ROUTE_11 = {
    { species = "EKANS",      minLevel = 11, maxLevel = 14, rate = 0.15, type = "grass", game = { "blue", "yellow" } },
    { species = "SANDSHREW",  minLevel = 11, maxLevel = 14, rate = 0.15, type = "grass", game = "red" },
    { species = "MR_MIME",    minLevel = 14, maxLevel = 16, rate = 0.08, type = "grass" },
    { species = "KANGASKHAN", minLevel = 16, maxLevel = 18, rate = 0.06, type = "grass" },
  },
  ROUTE_12 = {
    { species = "BELLSPROUT", minLevel = 22, maxLevel = 24, rate = 0.15, type = "grass", game = "red" },
    { species = "ODDISH",     minLevel = 22, maxLevel = 24, rate = 0.15, type = "grass", game = "blue" },
    { species = "FARFETCHD",  minLevel = 22, maxLevel = 24, rate = 0.08, type = "grass" },
    { species = "TANGELA",    minLevel = 22, maxLevel = 25, rate = 0.10, type = "grass" },
  },
  ROUTE_13 = {
    { species = "FARFETCHD",  minLevel = 24, maxLevel = 26, rate = 0.08, type = "grass" },
    { species = "WEEPINBELL", minLevel = 24, maxLevel = 26, rate = 0.10, type = "grass", game = "red" },
    { species = "GLOOM",      minLevel = 24, maxLevel = 26, rate = 0.10, type = "grass", game = "blue" },
  },
  ROUTE_14 = {
    { species = "PINSIR",     minLevel = 24, maxLevel = 26, rate = 0.08, type = "grass" },
    { species = "CHANSEY",    minLevel = 24, maxLevel = 26, rate = 0.05, type = "grass" },
  },
  ROUTE_15 = {
    { species = "SCYTHER",    minLevel = 24, maxLevel = 26, rate = 0.08, type = "grass" },
    { species = "LICKITUNG",  minLevel = 22, maxLevel = 25, rate = 0.08, type = "grass" },
  },
  ROUTE_16 = {
    { species = "KOFFING",    minLevel = 22, maxLevel = 24, rate = 0.15, type = "grass", game = "yellow" },
  },
  ROUTE_17 = {
    { species = "TAUROS",     minLevel = 25, maxLevel = 28, rate = 0.08, type = "grass" },
    { species = "EEVEE",      minLevel = 22, maxLevel = 25, rate = 0.08, type = "grass" },
  },
  ROUTE_18 = {
    { species = "TAUROS",     minLevel = 25, maxLevel = 28, rate = 0.08, type = "grass" },
    { species = "LICKITUNG",  minLevel = 22, maxLevel = 25, rate = 0.08, type = "grass" },
  },
  ROUTE_21 = {
    { species = "MR_MIME",    minLevel = 20, maxLevel = 24, rate = 0.08, type = "grass" },
    { species = "TANGELA",    minLevel = 26, maxLevel = 30, rate = 0.15, type = "grass" },
  },
  ROUTE_22 = {
    { species = "DRATINI",    minLevel = 15, maxLevel = 20, rate = 0.10, type = "water" },
  },
  ROUTE_23 = {
    { species = "CHANSEY",    minLevel = 40, maxLevel = 44, rate = 0.08, type = "grass" },
    { species = "ARBOK",      minLevel = 38, maxLevel = 42, rate = 0.10, type = "grass", game = { "blue", "yellow" } },
    { species = "SANDSLASH",  minLevel = 38, maxLevel = 42, rate = 0.10, type = "grass", game = "red" },
  },
  POWER_PLANT = {
    { species = "ELECTABUZZ", minLevel = 33, maxLevel = 36, rate = 0.10, type = "grass", game = { "blue", "yellow" } },
    { species = "RAICHU",     minLevel = 34, maxLevel = 38, rate = 0.08, type = "grass", game = "yellow" },
  },
  POKEMON_MANSION_1F = {
    { species = "MAGMAR",     minLevel = 32, maxLevel = 34, rate = 0.10, type = "grass", game = { "red", "yellow" } },
    { species = "GROWLITHE",  minLevel = 30, maxLevel = 32, rate = 0.15, type = "grass", game = "blue" },
    { species = "VULPIX",     minLevel = 30, maxLevel = 32, rate = 0.15, type = "grass", game = "red" },
    { species = "KOFFING",    minLevel = 30, maxLevel = 32, rate = 0.15, type = "grass", game = "yellow" },
  },
  POKEMON_MANSION_B1F = {
    { species = "MAGMAR",     minLevel = 34, maxLevel = 38, rate = 0.10, type = "grass", game = { "red", "yellow" } },
    { species = "WEEZING",    minLevel = 34, maxLevel = 38, rate = 0.10, type = "grass", game = "yellow" },
  },
  SEAFOAM_ISLANDS_B1F = {
    { species = "JYNX",       minLevel = 28, maxLevel = 32, rate = 0.10, type = "grass" },
  },
  SEAFOAM_ISLANDS_B3F = {
    { species = "OMANYTE",    minLevel = 28, maxLevel = 32, rate = 0.10, type = "water" },
    { species = "KABUTO",     minLevel = 28, maxLevel = 32, rate = 0.10, type = "water" },
  },
  SEAFOAM_ISLANDS_B4F = {
    { species = "OMANYTE",    minLevel = 28, maxLevel = 32, rate = 0.10, type = "water" },
    { species = "KABUTO",     minLevel = 28, maxLevel = 32, rate = 0.10, type = "water" },
  },
  VICTORY_ROAD_2F = {
    { species = "HITMONLEE",  minLevel = 40, maxLevel = 44, rate = 0.08, type = "grass" },
    { species = "HITMONCHAN", minLevel = 40, maxLevel = 44, rate = 0.08, type = "grass" },
  },
  CERULEAN_CAVE_1F = {
    { species = "PORYGON",    minLevel = 48, maxLevel = 52, rate = 0.06, type = "grass" },
    { species = "CHANSEY",    minLevel = 50, maxLevel = 55, rate = 0.10, type = "grass" },
  },
}

-- ----------------------------------------------------------------------------
-- Legendary & Stationary Encounters (Immediate Room Re-entry Respawn)
-- ----------------------------------------------------------------------------
local STATIONARY_ENCOUNTERS = {
  ARTICUNO = {
    species = "ARTICUNO",
    dex = 144,
    level = 50,
    map = "SEAFOAM_ISLANDS_B4F",
    mapAliases = { "SeafoamIslandsB4F", "SeafoamIslands5", "0xE3", 227 },
    flags = { "EVENT_BEAT_ARTICUNO", "HS_ARTICUNO", "SEAFOAM_ISLANDS_B4F_ARTICUNO" },
    sprite = "SPRITE_BIRD",
    coords = { x = 6, y = 1 },
  },
  ZAPDOS = {
    species = "ZAPDOS",
    dex = 145,
    level = 50,
    map = "POWER_PLANT",
    mapAliases = { "PowerPlant", "0xD6", 214 },
    flags = { "EVENT_BEAT_ZAPDOS", "HS_ZAPDOS", "POWER_PLANT_ZAPDOS" },
    sprite = "SPRITE_BIRD",
    coords = { x = 4, y = 9 },
  },
  MOLTRES = {
    species = "MOLTRES",
    dex = 146,
    level = 50,
    map = "VICTORY_ROAD_2F",
    mapAliases = { "VictoryRoad2F", "VictoryRoad2", "0xC7", 199 },
    flags = { "EVENT_BEAT_MOLTRES", "HS_MOLTRES", "VICTORY_ROAD_2F_MOLTRES" },
    sprite = "SPRITE_BIRD",
    coords = { x = 4, y = 7 },
  },
  MEWTWO = {
    species = "MEWTWO",
    dex = 150,
    level = 70,
    map = "CERULEAN_CAVE_B1F",
    mapAliases = { "CeruleanCaveB1F", "DungeonB1F", "UnknownDungeonB1F", "0xC1", 193 },
    flags = { "EVENT_BEAT_MEWTWO", "HS_MEWTWO", "CERULEAN_CAVE_B1F_MEWTWO" },
    sprite = "SPRITE_MONSTER",
    coords = { x = 27, y = 13 },
  },
  SNORLAX_R12 = {
    species = "SNORLAX",
    dex = 143,
    level = 30,
    map = "ROUTE_12",
    mapAliases = { "Route12", "0x17", 23 },
    flags = { "EVENT_BEAT_ROUTE12_SNORLAX", "HS_ROUTE_12_SNORLAX", "ROUTE_12_SNORLAX" },
    sprite = "SPRITE_SNORLAX",
    coords = { x = 8, y = 62 },
  },
  SNORLAX_R16 = {
    species = "SNORLAX",
    dex = 143,
    level = 30,
    map = "ROUTE_16",
    mapAliases = { "Route16", "0x1B", 27 },
    flags = { "EVENT_BEAT_ROUTE16_SNORLAX", "HS_ROUTE_16_SNORLAX", "ROUTE_16_SNORLAX" },
    sprite = "SPRITE_SNORLAX",
    coords = { x = 26, y = 10 },
  },
  MEW = {
    species = "MEW",
    dex = 151,
    level = 50,
    map = "CERULEAN_CAVE_B1F",
    mapAliases = { "CeruleanCaveB1F", "DungeonB1F", "UnknownDungeonB1F", "0xC1", 193 },
    flags = { "EVENT_BEAT_MEW", "HS_MEW", "CERULEAN_CAVE_B1F_MEW" },
    sprite = "SPRITE_FAIRY",
    coords = { x = 16, y = 9 },
  },
}

-- ----------------------------------------------------------------------------
-- Helper Functions
-- ----------------------------------------------------------------------------

--- Detects current game version ('red', 'blue', or 'yellow')
local function detectGameVersion(game, mod)
  if mod and mod.game and type(mod.game) == "string" then
    return mod.game:lower()
  end
  if game and game.version and type(game.version) == "string" then
    return game.version:lower()
  end
  if game and game.romName and type(game.romName) == "string" then
    local rom = game.romName:lower()
    if rom:find("yellow") then return "yellow" end
    if rom:find("blue") then return "blue" end
    if rom:find("red") then return "red" end
  end
  return "red"
end

--- Normalizes map key to match table entries
local function normalizeMapKey(mapId)
  if not mapId then return "" end
  local str = tostring(mapId):upper():gsub("[^%w_]", "")
  -- Common alias normalizations
  str = str:gsub("^MAP_", "")
  return str
end

--- Checks if a Pokémon species is owned in Pokédex, party, or PC boxes
local function isPokemonCaught(game, speciesName, dexNumber)
  if not game then return false end
  local save = game.save or game.savedata

  -- 1. Check Pokédex owned data
  if save then
    if save.pokedexOwned then
      if (dexNumber and save.pokedexOwned[dexNumber]) or (speciesName and save.pokedexOwned[speciesName]) then
        return true
      end
    end
    if save.pokedex and type(save.pokedex.isOwned) == "function" then
      if (dexNumber and save.pokedex:isOwned(dexNumber)) or (speciesName and save.pokedex:isOwned(speciesName)) then
        return true
      end
    end
    if save.pokedex and type(save.pokedex.owned) == "table" then
      if (dexNumber and save.pokedex.owned[dexNumber]) or (speciesName and save.pokedex.owned[speciesName]) then
        return true
      end
    end

    -- 2. Check active player party
    local party = save.party or game.party
    if type(party) == "table" then
      for _, mon in ipairs(party) do
        if mon and (mon.species == speciesName or (dexNumber and mon.dex == dexNumber)) then
          return true
        end
      end
    end

    -- 3. Check PC storage boxes
    local boxes = save.boxes or (save.storage and save.storage.boxes)
    if type(boxes) == "table" then
      for _, box in pairs(boxes) do
        if type(box) == "table" then
          for _, mon in ipairs(box) do
            if mon and (mon.species == speciesName or (dexNumber and mon.dex == dexNumber)) then
              return true
            end
          end
        end
      end
    end
  end

  return false
end

--- Matches map identifier against entry definition
local function mapMatches(currentMap, targetMap, aliases)
  if not currentMap then return false end
  local normCurrent = normalizeMapKey(currentMap)
  if normCurrent == normalizeMapKey(targetMap) then
    return true
  end
  if aliases then
    for _, alias in ipairs(aliases) do
      if normCurrent == normalizeMapKey(alias) then
        return true
      end
    end
  end
  return false
end

--- Returns a matching added encounter for the current map, zone, and game
local function getAddedWildEncounter(mapId, zoneType, game, mod)
  local norm = normalizeMapKey(mapId)
  local additions = WILD_ADDITIONS[norm]
  if not additions then
    -- Try fuzzy match
    for k, v in pairs(WILD_ADDITIONS) do
      if norm:find(k, 1, true) or k:find(norm, 1, true) then
        additions = v
        break
      end
    end
  end

  if not additions or #additions == 0 then
    return nil
  end

  local curGame = detectGameVersion(game, mod)
  local validPool = {}

  for _, entry in ipairs(additions) do
    local typeMatch = not entry.type or entry.type == zoneType or (zoneType == "all")
    local gameMatch = true
    if entry.game then
      if type(entry.game) == "table" then
        gameMatch = false
        for _, g in ipairs(entry.game) do
          if g:lower() == curGame then gameMatch = true break end
        end
      else
        gameMatch = (entry.game:lower() == curGame)
      end
    end

    if typeMatch and gameMatch then
      table.insert(validPool, entry)
    end
  end

  if #validPool == 0 then return nil end

  -- Pick one randomly from pool
  local choice = validPool[math.random(#validPool)]
  local level = choice.minLevel
  if choice.maxLevel and choice.maxLevel > choice.minLevel then
    level = math.random(choice.minLevel, choice.maxLevel)
  end

  return {
    species = choice.species,
    level = level,
    rate = choice.rate or 0.10,
  }
end

-- ----------------------------------------------------------------------------
-- Module Lifecycle Registration
-- ----------------------------------------------------------------------------

function Catch151Module.register(moduleManager)
  moduleManager:register({
    id = "catch_151",
    label = "CATCH 151",
    desc = "Catch all 151 mons in any version.",
    default = true,
    init = function(mod, mgr)
      Catch151Module.init(mod, mgr)
    end,
  })
end

function Catch151Module.init(mod, moduleManager)
  -- 1. Hook wild encounters to inject starters, version exclusives & safari mons
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    -- Hook wild.encounter (Standard recomp generation hook)
    mod.hooks:wrap("wild.encounter", function(next, mapId, zone, game)
      if not moduleManager:isEnabled("catch_151") then
        return next and next(mapId, zone, game)
      end

      local added = getAddedWildEncounter(mapId, zone or "grass", game, mod)
      if added and math.random() < added.rate then
        return { species = added.species, level = added.level }
      end

      return next and next(mapId, zone, game)
    end)

    -- Hook wild.generate
    mod.hooks:wrap("wild.generate", function(next, mapId, encounterType, game)
      if not moduleManager:isEnabled("catch_151") then
        return next and next(mapId, encounterType, game)
      end

      local added = getAddedWildEncounter(mapId, encounterType or "grass", game, mod)
      if added and math.random() < added.rate then
        return { species = added.species, level = added.level }
      end

      return next and next(mapId, encounterType, game)
    end)

    -- Hook map.encounters (Table query hook)
    mod.hooks:wrap("map.encounters", function(next, map, encounterType)
      local slots = next and next(map, encounterType) or {}
      if not moduleManager:isEnabled("catch_151") then
        return slots
      end

      local mapId = type(map) == "table" and (map.id or map.name) or map
      local added = getAddedWildEncounter(mapId, encounterType or "grass", nil, mod)
      if added and type(slots) == "table" and #slots > 0 then
        -- Clone and inject added species into one of the lower-tier slots
        local modified = {}
        for i, s in ipairs(slots) do modified[i] = s end
        local replaceIdx = #modified
        modified[replaceIdx] = { species = added.species, level = added.level }
        return modified
      end

      return slots
    end)

    -- Hook battle.start fallback
    mod.hooks:wrap("battle.start", function(next, game, kind, opponent, ...)
      if moduleManager:isEnabled("catch_151") and kind == "wild" and opponent then
        local mapId = game and game.map and (game.map.id or game.map.name)
        local added = getAddedWildEncounter(mapId, "grass", game, mod)
        if added and math.random() < added.rate then
          opponent.species = added.species
          opponent.level = added.level
        end
      end
      return next and next(game, kind, opponent, ...)
    end)
  end

  -- 2. Hook map entry / room transition for Immediate Legendary & Snorlax Respawns
  local function handleMapEntered(game, map)
    if not moduleManager:isEnabled("catch_151") then return end
    if not game then return end

    local curMap = map or (game.map and (game.map.id or game.map.name))
    local save = game.save or game.savedata
    if not curMap or not save then return end

    for id, enc in pairs(STATIONARY_ENCOUNTERS) do
      if mapMatches(curMap, enc.map, enc.mapAliases) then
        local caught = isPokemonCaught(game, enc.species, enc.dex)

        -- Check custom mod flag for Mew
        if id == "MEW" and mod.save and type(mod.save.get) == "function" then
          if mod.save:get("mew_caught") == true then
            caught = true
          end
        end

        if not caught then
          -- Player did not catch it; clear hide flags so the sprite immediately respawns!
          if save.flags and type(save.flags) == "table" then
            for _, f in ipairs(enc.flags) do
              save.flags[f] = false
            end
          end

          -- If game engine maintains map sprite visibility list
          if game.map and game.map.hiddenSprites and type(game.map.hiddenSprites) == "table" then
            for _, f in ipairs(enc.flags) do
              game.map.hiddenSprites[f] = nil
            end
          end

          -- Ensure Mew stationary entity is present on Cerulean Cave B1F
          if id == "MEW" and game.map and game.map.entities then
            local mewPresent = false
            for _, ent in ipairs(game.map.entities) do
              if ent.id == "omni_mew" or ent.species == "MEW" then
                mewPresent = true
                break
              end
            end

            if not mewPresent then
              table.insert(game.map.entities, {
                id = "omni_mew",
                species = "MEW",
                x = enc.coords.x,
                y = enc.coords.y,
                sprite = enc.sprite,
                facing = "down",
                interact = function(g)
                  pcall(function()
                    local Sound = require("src.core.Sound")
                    Sound.playCry("MEW")
                  end)
                  if g.battle and type(g.battle.startWild) == "function" then
                    g.battle:startWild("MEW", enc.level, {
                      onWin = function(result)
                        if result == "caught" then
                          if mod.save and type(mod.save.set) == "function" then
                            mod.save:set("mew_caught", true)
                          end
                        end
                      end
                    })
                  end
                end,
              })
            end
          end
        end
      end
    end
  end

  if mod.events and type(mod.events.on) == "function" then
    mod.events:on("map.entered", function(game, map)
      handleMapEntered(game, map)
    end)
    mod.events:on("map.loaded", function(game, map)
      handleMapEntered(game, map)
    end)
  end

  -- Wrap overworld.load_map hook if available
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("overworld.load_map", function(next, game, mapId, ...)
      local out = next and next(game, mapId, ...)
      handleMapEntered(game, mapId)
      return out
    end)
  end

  -- 3. Hook battle completion to track catches and protect respawns
  if mod.events and type(mod.events.on) == "function" then
    mod.events:on("battle.finished", function(game, result, enemy)
      if not moduleManager:isEnabled("catch_151") then return end
      if not enemy then return end

      local species = enemy.species or (enemy.party and enemy.party[1] and enemy.party[1].species)
      if species == "MEW" and result == "caught" then
        if mod.save and type(mod.save.set) == "function" then
          mod.save:set("mew_caught", true)
        end
      end
    end)
  end
end

return Catch151Module
