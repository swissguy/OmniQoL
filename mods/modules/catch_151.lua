-- ============================================================================
-- OmniQoL: Catch All 151 Pokémon Module (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
--
-- Features:
-- 1. Wild Starters in Thematic Habitats:
--    - Bulbasaur: Viridian Forest (Lv 4-6), Route 2 (Lv 4-5)
--    - Charmander: Route 3 (Lv 8-10), Route 4 (Lv 8-12)
--    - Squirtle: Route 24 (Lv 10-14), Route 25 (Lv 12-17)
-- 2. Version Exclusives & Missing Pokémon Across Red, Blue, and Yellow:
--    - Ekans / Arbok: Route 4, Route 9, Route 11, Route 23 (Blue & Yellow)
--    - Sandshrew / Sandslash: Route 3, Route 4, Route 9, Route 11, Route 23 (Red)
--    - Oddish / Gloom: Route 24, Route 25, Route 12, Route 13 (Blue)
--    - Bellsprout / Weepinbell: Route 24, Route 25, Route 12, Route 13 (Red)
--    - Mankey / Primeape: Route 22, Route 3, Route 4, Route 5, Route 6 (Blue/Red/Yellow)
--    - Meowth / Persian: Route 5, Route 6, Route 7, Route 8 (Red & Yellow)
--    - Growlithe / Arcanine: Route 7, Route 8, Pokémon Mansion (Blue)
--    - Vulpix / Ninetales: Route 7, Route 8, Pokémon Mansion (Red)
--    - Koffing / Weezing: Pokémon Mansion, Route 16, Route 17 (Yellow)
--    - Weedle / Caterpie: Route 2 (cross-pollinated across Red, Blue, and Yellow)
--    - Weedle / Kakuna / Beedrill: Viridian Forest (Yellow)
--    - Electabuzz: Power Plant (Blue & Yellow)
--    - Magmar: Pokémon Mansion (Red & Yellow)
--    - Psyduck: Route 6 (Lv 15-18 grass in Red, Blue, and Yellow)
--    - Wild Raichu: Power Plant & Cerulean Cave (Yellow, since Starter Pikachu rejects Thunder Stone)
-- 3. Safari Zone Exclusives Accessible Outside Safari Zone (Normal Battles & Pokéballs):
--    - Chansey: Route 14 (Lv 24-26), Route 23 (Lv 40-44)
--    - Kangaskhan: Route 11 (Lv 16-20), Rock Tunnel (Lv 18-24)
--    - Tauros: Route 17 (Lv 25-28), Route 18 (Lv 25-28)
--    - Scyther: Route 15 (Lv 24-26)
--    - Pinsir: Route 14 (Lv 24-26)
--    - Dratini: Route 10 & Route 22 Water (Lv 15-20)
--    - Tangela: Route 12 (Lv 22-25), Route 21 (Lv 28-30)
-- 4. Mutually Exclusive & In-Game Trade Pokémon Made Wild:
--    - Fossils: Omanyte & Kabuto in Seafoam Islands B3F/B4F Water (Lv 28-32)
--    - Fighting Dojo: Hitmonlee & Hitmonchan in Victory Road 2F (Lv 40-44) & Route 10 (Lv 18-22)
--    - Eevee: Route 25 (Lv 12-17), Route 8 (Lv 18-22) & Route 17 (Lv 22-25) allowing all 3 Eeveelutions
--    - Porygon: Route 7 (Lv 18-22) & Cerulean Cave 1F (Lv 48-52)
--    - Farfetch'd: Route 12 (Lv 22-24) & Route 13 (Lv 24-26)
--    - Mr. Mime: Route 21 (Lv 20-24) & Route 11 (Lv 16-20)
--    - Lickitung: Route 15 (Lv 22-25) & Route 18 (Lv 22-25)
--    - Jynx: Seafoam Islands B1F/B2F (Lv 28-32)
--    - Ditto: Route 5 (Lv 14-18) outside the Pokémon Day Care
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
-- Custom Route Rosters (Explicit Route Spawns & Balanced / Uniform Mode)
-- ----------------------------------------------------------------------------
local ROUTE_ROSTERS = {
  ROUTE_2 = {
    mode = "uniform", -- Every active species appears with equal probability (1/5 chance = 20% each)
    grass = {
      { species = "PIDGEY",    minLevel = 3, maxLevel = 5 },
      { species = "RATTATA",   minLevel = 2, maxLevel = 5 },
      { species = "WEEDLE",    minLevel = 3, maxLevel = 5 },
      { species = "CATERPIE",  minLevel = 3, maxLevel = 5 },
      { species = "BULBASAUR", minLevel = 4, maxLevel = 5 },
    },
  },
  ROUTE_22 = {
    mode = "uniform", -- Every active species appears with equal probability (1/5 chance = 20% each)
    grass = {
      { species = "RATTATA",   minLevel = 2, maxLevel = 5 },
      { species = "SPEAROW",   minLevel = 3, maxLevel = 5 },
      { species = "NIDORAN_F", minLevel = 3, maxLevel = 5 },
      { species = "NIDORAN_M", minLevel = 3, maxLevel = 5 },
      { species = "MANKEY",    minLevel = 3, maxLevel = 5 },
    },
  },
  VIRIDIAN_FOREST = {
    mode = "weighted", -- 7 species with weight 2 (~13.33% each); Pidgeotto with weight 1 (~6.67%, half rate)
    grass = {
      { species = "CATERPIE",  minLevel = 3, maxLevel = 5, weight = 2 },
      { species = "METAPOD",   minLevel = 4, maxLevel = 6, weight = 2 },
      { species = "WEEDLE",    minLevel = 3, maxLevel = 5, weight = 2 },
      { species = "KAKUNA",    minLevel = 4, maxLevel = 6, weight = 2 },
      { species = "PIDGEY",    minLevel = 3, maxLevel = 5, weight = 2 },
      { species = "PIKACHU",   minLevel = 3, maxLevel = 5, weight = 2 },
      { species = "BULBASAUR", minLevel = 4, maxLevel = 6, weight = 2 },
      { species = "PIDGEOTTO", minLevel = 9, maxLevel = 9, weight = 1 },
    },
  },
  ROUTE_3 = {
    mode = "uniform", -- 6 species with equal probability (~16.67% each)
    grass = {
      { species = "PIDGEY",     minLevel = 6, maxLevel = 10 },
      { species = "SPEAROW",    minLevel = 6, maxLevel = 10 },
      { species = "JIGGLYPUFF", minLevel = 6, maxLevel = 10 },
      { species = "MANKEY",     minLevel = 6, maxLevel = 10 },
      { species = "SANDSHREW",  minLevel = 6, maxLevel = 10 },
      { species = "CHARMANDER", minLevel = 8, maxLevel = 10 },
    },
  },
  MT_MOON_1F = {
    mode = "uniform", -- 25% each (Zubat, Geodude, Paras, Clefairy)
    grass = {
      { species = "ZUBAT",    minLevel = 7, maxLevel = 10 },
      { species = "GEODUDE",  minLevel = 7, maxLevel = 10 },
      { species = "PARAS",    minLevel = 7, maxLevel = 10 },
      { species = "CLEFAIRY", minLevel = 7, maxLevel = 10 },
    },
  },
  MT_MOON_B1F = {
    mode = "uniform", -- 25% each (Zubat, Geodude, Paras, Clefairy)
    grass = {
      { species = "ZUBAT",    minLevel = 8, maxLevel = 11 },
      { species = "GEODUDE",  minLevel = 8, maxLevel = 11 },
      { species = "PARAS",    minLevel = 8, maxLevel = 11 },
      { species = "CLEFAIRY", minLevel = 8, maxLevel = 11 },
    },
  },
  MT_MOON_B2F = {
    mode = "uniform", -- 25% each (Zubat, Geodude, Paras, Clefairy)
    grass = {
      { species = "ZUBAT",    minLevel = 9, maxLevel = 12 },
      { species = "GEODUDE",  minLevel = 9, maxLevel = 12 },
      { species = "PARAS",    minLevel = 9, maxLevel = 12 },
      { species = "CLEFAIRY", minLevel = 9, maxLevel = 12 },
    },
  },
  ROUTE_4 = {
    mode = "uniform", -- 6 species with equal probability (~16.67% each)
    grass = {
      { species = "RATTATA",    minLevel = 8, maxLevel = 12 },
      { species = "SPEAROW",    minLevel = 8, maxLevel = 12 },
      { species = "EKANS",      minLevel = 8, maxLevel = 12 },
      { species = "SANDSHREW",  minLevel = 8, maxLevel = 12 },
      { species = "MANKEY",     minLevel = 8, maxLevel = 12 },
      { species = "CHARMANDER", minLevel = 8, maxLevel = 12 },
    },
  },
  ROUTE_24 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "SQUIRTLE",   minLevel = 10, maxLevel = 14 },
      { species = "ABRA",       minLevel = 10, maxLevel = 14 },
      { species = "ODDISH",     minLevel = 10, maxLevel = 14 },
      { species = "BELLSPROUT", minLevel = 10, maxLevel = 14 },
      { species = "VENONAT",    minLevel = 10, maxLevel = 14 },
    },
  },
  ROUTE_25 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "SQUIRTLE",   minLevel = 12, maxLevel = 17 },
      { species = "ABRA",       minLevel = 12, maxLevel = 17 },
      { species = "ODDISH",     minLevel = 12, maxLevel = 17 },
      { species = "BELLSPROUT", minLevel = 12, maxLevel = 17 },
      { species = "EEVEE",      minLevel = 12, maxLevel = 17 },
    },
  },
  ROUTE_5 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "MANKEY",     minLevel = 14, maxLevel = 18 },
      { species = "MEOWTH",     minLevel = 14, maxLevel = 18 },
      { species = "ABRA",       minLevel = 14, maxLevel = 18 },
      { species = "JIGGLYPUFF", minLevel = 14, maxLevel = 18 },
      { species = "DITTO",      minLevel = 14, maxLevel = 18 },
    },
  },
  ROUTE_6 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "MANKEY",     minLevel = 15, maxLevel = 18 },
      { species = "MEOWTH",     minLevel = 15, maxLevel = 18 },
      { species = "ABRA",       minLevel = 15, maxLevel = 18 },
      { species = "JIGGLYPUFF", minLevel = 15, maxLevel = 18 },
      { species = "PSYDUCK",    minLevel = 15, maxLevel = 18 },
    },
  },
  ROUTE_11 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "DROWZEE",    minLevel = 16, maxLevel = 20 },
      { species = "EKANS",      minLevel = 16, maxLevel = 20 },
      { species = "SANDSHREW",  minLevel = 16, maxLevel = 20 },
      { species = "MR_MIME",    minLevel = 16, maxLevel = 20 },
      { species = "KANGASKHAN", minLevel = 16, maxLevel = 20 },
    },
  },
  ROUTE_9 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "EKANS",     minLevel = 16, maxLevel = 20 },
      { species = "SANDSHREW", minLevel = 16, maxLevel = 20 },
      { species = "NIDORINA",  minLevel = 16, maxLevel = 20 },
      { species = "NIDORINO",  minLevel = 16, maxLevel = 20 },
      { species = "SPEAROW",   minLevel = 16, maxLevel = 20 },
    },
  },
  ROUTE_10 = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "VOLTORB",    minLevel = 18, maxLevel = 22 },
      { species = "MAGNEMITE",  minLevel = 18, maxLevel = 22 },
      { species = "MACHOP",     minLevel = 18, maxLevel = 22 },
      { species = "HITMONLEE",  minLevel = 18, maxLevel = 22 },
      { species = "HITMONCHAN", minLevel = 18, maxLevel = 22 },
    },
  },
  ROCK_TUNNEL_1F = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "KANGASKHAN", minLevel = 18, maxLevel = 22 },
      { species = "ONIX",       minLevel = 18, maxLevel = 22 },
      { species = "MACHOP",     minLevel = 18, maxLevel = 22 },
      { species = "GEODUDE",    minLevel = 18, maxLevel = 22 },
      { species = "GRAVELER",   minLevel = 18, maxLevel = 22 },
    },
  },
  ROCK_TUNNEL_B1F = {
    mode = "uniform", -- 5 species with equal probability (20% each)
    grass = {
      { species = "KANGASKHAN", minLevel = 20, maxLevel = 24 },
      { species = "ONIX",       minLevel = 20, maxLevel = 24 },
      { species = "MACHOP",     minLevel = 20, maxLevel = 24 },
      { species = "GEODUDE",    minLevel = 20, maxLevel = 24 },
      { species = "GRAVELER",   minLevel = 20, maxLevel = 24 },
    },
  },
}

-- ----------------------------------------------------------------------------
-- Wild Encounter Tables by Map Identifier / Alias (Additions)
-- ----------------------------------------------------------------------------
local WILD_ADDITIONS = {

  -- --- Version Exclusives & Missing Pokémon ---
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
    { species = "DRATINI",    minLevel = 15, maxLevel = 20, rate = 0.10, type = "water" },
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
  local okGV, GV = pcall(require, "src.core.GameVersion")
  if okGV and GV and type(GV.get) == "function" then
    local v = GV.get()
    if v and type(v) == "string" then return v:lower() end
  end
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

--- High-entropy random helper prioritizing engine / LÖVE2D RNG over C rand
local function getRandom(a, b, rngFn)
  local fn = rngFn
  if not fn or type(fn) ~= "function" then
    if love and love.math and type(love.math.random) == "function" then
      fn = love.math.random
    else
      fn = math.random
    end
  end

  if a and b then
    return fn(a, b)
  elseif a then
    return fn(a)
  else
    return fn()
  end
end

--- Returns a matching added encounter for the current map, zone, and game
local function getAddedWildEncounter(mapId, zoneType, game, mod, rngFn)
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

  -- Calculate cumulative weights and select species based on relative weights
  local totalWeight = 0
  for _, entry in ipairs(validPool) do
    totalWeight = totalWeight + (entry.rate or 0.10)
  end

  local roll = getRandom(nil, nil, rngFn) * totalWeight
  local accum = 0
  local choice = validPool[1]
  for _, entry in ipairs(validPool) do
    accum = accum + (entry.rate or 0.10)
    if roll <= accum then
      choice = entry
      break
    end
  end

  local level = choice.minLevel
  if choice.maxLevel and choice.maxLevel > choice.minLevel then
    level = getRandom(choice.minLevel, choice.maxLevel, rngFn)
  end

  -- Total rate capped at 0.50 so vanilla Pokémon retain at least 50% appearance rate
  local effectiveRate = math.min(totalWeight, 0.50)

  return {
    species = choice.species,
    level = level,
    rate = effectiveRate,
  }
end

-- ----------------------------------------------------------------------------
-- Module Lifecycle Registration
-- ----------------------------------------------------------------------------


--- Gets encounter from custom route roster if defined
local function getRouteRosterEncounter(mapId, terrain, game, mod, rngFn)
  if not mapId then return nil end
  local norm = normalizeMapKey(mapId)
  local roster = ROUTE_ROSTERS[norm]
  if not roster then
    for k, v in pairs(ROUTE_ROSTERS) do
      if norm:find(k, 1, true) or k:find(norm, 1, true) then
        roster = v
        break
      end
    end
  end

  if not roster then return nil end

  local tKey = (terrain == "indoor" or not terrain) and "grass" or terrain
  local list = roster[tKey] or roster["grass"]
  if not list or #list == 0 then return nil end

  local curGame = detectGameVersion(game, mod)
  local validPool = {}

  for _, entry in ipairs(list) do
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

    if gameMatch then
      table.insert(validPool, entry)
    end
  end

  if #validPool == 0 then return nil end

  local choice
  if roster.mode == "uniform" then
    -- Equal probability across all valid species on this route
    choice = validPool[getRandom(#validPool, nil, rngFn)]
  else
    -- Weighted by entry.weight or entry.rate
    local totalWeight = 0
    for _, e in ipairs(validPool) do
      totalWeight = totalWeight + (e.weight or e.rate or 1)
    end
    local roll = getRandom(nil, nil, rngFn) * totalWeight
    local accum = 0
    choice = validPool[1]
    for _, e in ipairs(validPool) do
      accum = accum + (e.weight or e.rate or 1)
      if roll <= accum then
        choice = e
        break
      end
    end
  end

  local level = choice.minLevel
  if choice.maxLevel and choice.maxLevel > choice.minLevel then
    level = getRandom(choice.minLevel, choice.maxLevel, rngFn)
  end

  return {
    species = choice.species,
    level = level,
    isRosterOverride = true,
  }
end

function Catch151Module.register(moduleManager)
  moduleManager:register({
    id = "catch_151",
    label = "CATCH 151",
    desc = "Catch all 151 wild Pokemon.",
    default = true,
    supportedGenerations = { "gen1" },
    init = function(mod, mgr)
      Catch151Module.init(mod, mgr)
    end,
  })
end

function Catch151Module.init(mod, moduleManager)
  -- Synchronize in-memory Data.encounters tables for maps with custom route rosters
  local function patchMemoryEncounterTables()
    local okData, Data = pcall(require, "src.core.Data")
    if not (okData and Data and Data.encounters) then return end

    local curGame = detectGameVersion(nil, mod)

    for mapName, roster in pairs(ROUTE_ROSTERS) do
      local encMap = Data.encounters[mapName]
      if encMap and encMap.grass and roster.grass then
        local valid = {}
        for _, entry in ipairs(roster.grass) do
          local match = true
          if entry.game then
            if type(entry.game) == "table" then
              match = false
              for _, g in ipairs(entry.game) do
                if g:lower() == curGame then match = true break end
              end
            else
              match = (entry.game:lower() == curGame)
            end
          end
          if match then table.insert(valid, entry) end
        end

        if #valid > 0 and encMap.grass.slots then
          for i = 1, #encMap.grass.slots do
            local pick = valid[((i - 1) % #valid) + 1]
            encMap.grass.slots[i] = {
              species = pick.species,
              level = encMap.grass.slots[i].level or pick.minLevel or 4,
            }
          end
        end
      end
    end
  end
  patchMemoryEncounterTables()

  -- 1. Hook wild encounters to inject custom route rosters, starters & version exclusives
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    -- Gen1Recomp official encounter transform hook: encounter.species
    mod.hooks:wrap("encounter.species", function(next, enc, ctx)
      local result = next and next(enc, ctx) or enc
      if not moduleManager:isEnabled("catch_151") then
        return result
      end

      -- If already overridden by encounter.roll, preserve without re-rolling
      if enc and enc.isRosterOverride then
        return enc
      end

      local mapId = ctx and ctx.mapId
      local terrain = ctx and ctx.terrain or "grass"
      local rng = ctx and ctx.rng

      -- 1a. Check if map has a custom route roster (e.g. Route 2 uniform roster)
      local rosterMon = getRouteRosterEncounter(mapId, terrain, nil, mod, rng)
      if rosterMon then
        return { species = rosterMon.species, level = rosterMon.level, isRosterOverride = true }
      end

      -- 1b. Check additions table
      local added = getAddedWildEncounter(mapId, terrain, nil, mod, rng)
      if added and getRandom(nil, nil, rng) < added.rate then
        return { species = added.species, level = added.level }
      end

      return result
    end)

    -- Gen1Recomp official encounter roll hook: encounter.roll
    mod.hooks:wrap("encounter.roll", function(next, encDef, ctx)
      local enc = next and next(encDef, ctx)
      if not moduleManager:isEnabled("catch_151") then
        return enc
      end

      local mapId = ctx and ctx.mapId
      local terrain = ctx and ctx.terrain or "grass"
      local rng = ctx and ctx.rng
      if enc then
        local rosterMon = getRouteRosterEncounter(mapId, terrain, nil, mod, rng)
        if rosterMon then
          enc.species = rosterMon.species
          enc.level = rosterMon.level
          enc.isRosterOverride = true
        end
      end

      return enc
    end)

    -- Gen1Recomp official encounter table distribution hook: encounter.table
    mod.hooks:wrap("encounter.table", function(next, dist, ctx)
      local res = next and next(dist, ctx) or dist
      if not moduleManager:isEnabled("catch_151") then
        return res
      end

      local mapId = ctx and ctx.mapId
      local terrain = ctx and ctx.terrain or "grass"
      local tKey = (terrain == "indoor" or not terrain) and "grass" or terrain
      local norm = normalizeMapKey(mapId)
      local roster = ROUTE_ROSTERS[norm]
      local rosterList = roster and (roster[tKey] or roster["grass"])
      if roster and rosterList then
        local curGame = detectGameVersion(nil, mod)
        local valid = {}
        for _, entry in ipairs(rosterList) do
          local match = true
          if entry.game then
            if type(entry.game) == "table" then
              match = false
              for _, g in ipairs(entry.game) do
                if g:lower() == curGame then match = true break end
              end
            else
              match = (entry.game:lower() == curGame)
            end
          end
          if match then table.insert(valid, entry.species) end
        end

        if #valid > 0 then
          local newDist = {}
          local validEntries = {}
          local totalWeight = 0
          for _, entry in ipairs(rosterList) do
            local match = true
            if entry.game then
              if type(entry.game) == "table" then
                match = false
                for _, g in ipairs(entry.game) do
                  if g:lower() == curGame then match = true break end
                end
              else
                match = (entry.game:lower() == curGame)
              end
            end
            if match then
              table.insert(validEntries, entry)
              totalWeight = totalWeight + (entry.weight or entry.rate or 1)
            end
          end

          local accumulated = 0
          for _, entry in ipairs(validEntries) do
            local w = math.floor(256 * (entry.weight or entry.rate or 1) / totalWeight)
            accumulated = accumulated + w
            newDist[entry.species] = (newDist[entry.species] or 0) + w
          end
          if accumulated < 256 and #validEntries > 0 then
            local firstSp = validEntries[1].species
            newDist[firstSp] = (newDist[firstSp] or 0) + (256 - accumulated)
          end
          return newDist
        end
      end

      return res
    end)

    -- Legacy fallback hooks
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
    patchMemoryEncounterTables()
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

  -- 4. Celadon Department Store 4F: Add Moon Stone to Evolutionary Stones Inventory
  local CELADON_4F_IDENTIFIERS = {
    CELADON_MART_4F = true,
    CELADON_DEPT_STORE_4F = true,
    CELADONMART4F = true,
    CELADONMART4 = true,
    CELADONCITYDEPTSTORE4F = true,
    ["0x89"] = true,
    ["137"] = true,
  }

  local function isCeladon4FMart(id, items)
    if id then
      local norm = normalizeMapKey(id)
      if CELADON_4F_IDENTIFIERS[norm] or CELADON_4F_IDENTIFIERS[id] or norm:find("CELADON.*4") then
        return true
      end
    end
    if type(items) == "table" then
      local hasFire = false
      local hasLeaf = false
      for _, item in ipairs(items) do
        local itemId = type(item) == "table" and (item.id or item.name or item[1]) or item
        if itemId == "FIRE_STONE" or itemId == 0x20 or itemId == 32 then hasFire = true end
        if itemId == "LEAF_STONE" or itemId == 0x22 or itemId == 34 then hasLeaf = true end
      end
      if hasFire and hasLeaf then
        return true
      end
    end
    return false
  end

  local function addMoonStoneToList(items)
    if type(items) ~= "table" then return items end

    -- Avoid duplicate insertion
    for _, item in ipairs(items) do
      local itemId = type(item) == "table" and (item.id or item.name or item[1]) or item
      if itemId == "MOON_STONE" or itemId == 0x0A or itemId == 10 then
        return items
      end
    end

    local newItems = {}
    local inserted = false
    for _, item in ipairs(items) do
      table.insert(newItems, item)
      local itemId = type(item) == "table" and (item.id or item.name or item[1]) or item
      if itemId == "LEAF_STONE" or itemId == 0x22 or itemId == 34 then
        if type(item) == "table" and item.price then
          table.insert(newItems, { id = "MOON_STONE", price = 2100 })
        else
          table.insert(newItems, "MOON_STONE")
        end
        inserted = true
      end
    end

    if not inserted then
      if #items > 0 and type(items[1]) == "table" and items[1].price then
        table.insert(newItems, { id = "MOON_STONE", price = 2100 })
      else
        table.insert(newItems, "MOON_STONE")
      end
    end

    return newItems
  end

  -- Wrap mart/shop item hooks
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("mart.items", function(next, martId, items, ...)
      local list = next and next(martId, items, ...) or items
      if moduleManager:isEnabled("catch_151") and isCeladon4FMart(martId, list) then
        return addMoonStoneToList(list)
      end
      return list
    end)

    mod.hooks:wrap("shop.items", function(next, shopId, items, ...)
      local list = next and next(shopId, items, ...) or items
      if moduleManager:isEnabled("catch_151") and isCeladon4FMart(shopId, list) then
        return addMoonStoneToList(list)
      end
      return list
    end)

    mod.hooks:wrap("mart.open", function(next, game, martId, items, ...)
      if moduleManager:isEnabled("catch_151") and isCeladon4FMart(martId, items) then
        items = addMoonStoneToList(items)
      end
      return next and next(game, martId, items, ...)
    end)

    mod.hooks:wrap("ui.mart.items", function(next, game, martId, items, ...)
      local list = next and next(game, martId, items, ...) or items
      if moduleManager:isEnabled("catch_151") and isCeladon4FMart(martId, list) then
        return addMoonStoneToList(list)
      end
      return list
    end)
  end

  -- Patch item definitions for Moon Stone price (¥2,100 buy / ¥1,050 sell)
  if mod.content and mod.content.items and type(mod.content.items.patch) == "function" then
    pcall(function()
      mod.content.items:patch("MOON_STONE", { price = 2100 })
    end)
  end
end

return Catch151Module
