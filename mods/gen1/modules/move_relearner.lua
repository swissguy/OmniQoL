-- ============================================================================
-- OmniQoL: Move Relearner Module (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
--
-- Features:
-- - Move Reminder NPC present in every Pokémon Center across Kanto:
--   * Viridian, Pewter, Cerulean, Vermilion, Lavender, Celadon, Fuchsia,
--     Saffron, Cinnabar, Indigo Plateau, Route 4 (Mt. Moon), Route 10 (Rock Tunnel).
-- - Distinguished Gentleman sprite standing in the lobby at (x=1, y=4).
-- - Free to use (Sword & Shield style — no Pokédollars or items required).
-- - Comprehensive pre-evolution move retention:
--   * Pokémon can relearn all level-up moves their current species and any
--     prior evolutionary stage could have learned up to their current level.
--   * Solves early stone/trade evolution penalties (e.g. Raichu, Arcanine,
--     Ninetales, Vileplume, Victreebel, Starmie, Cloyster, Exeggutor).
--   * Includes Level 1 starting moves for all stages in the line.
-- - Move replacement & HM overwriting:
--   * Direct learning if fewer than 4 moves known.
--   * Selection menu to choose which move to overwrite if 4 moves known.
--   * Respects the separate 'FORGET HMS' module toggle.
-- - Options Menu Integration:
--   * Configurable directly in OMNIQOL Settings screen (`RELEARNER`).
--   * Enabled by default with per-save persistence.
-- ============================================================================

local MoveRelearnerModule = {}

-- Load Relearner Data and Forget HMs helper
local function loadSubmodule(path)
  local ok, res = pcall(require, path)
  if ok and res then return res end
  if type(dofile) == "function" then
    local dOk, dRes = pcall(dofile, "mods/gen1/" .. path .. ".lua")
    if dOk and dRes then return dRes end
    dOk, dRes = pcall(dofile, path .. ".lua")
    if dOk and dRes then return dRes end
  end
  return nil
end

local RelearnerData = loadSubmodule("modules/relearner_data") or {}
local ForgetHMsModule = loadSubmodule("modules/forget_hms") or {}

-- ----------------------------------------------------------------------------
-- Pokémon Center Maps
-- ----------------------------------------------------------------------------
local POKECENTER_MAPS = {
  VIRIDIAN_POKECENTER = true,
  PEWTER_POKECENTER = true,
  CERULEAN_POKECENTER = true,
  MT_MOON_POKECENTER = true,
  ROCK_TUNNEL_POKECENTER = true,
  VERMILION_POKECENTER = true,
  CELADON_POKECENTER = true,
  LAVENDER_POKECENTER = true,
  FUCHSIA_POKECENTER = true,
  CINNABAR_POKECENTER = true,
  SAFFRON_POKECENTER = true,
  INDIGO_PLATEAU_LOBBY = true,
}

local function isPokeCenter(mapId)
  if not mapId then return false end
  local str = tostring(mapId):upper():gsub("[^%w_]", "")
  if POKECENTER_MAPS[str] then return true end
  return str:find("POKECENTER") ~= nil
      or str:find("POKEMONCENTER") ~= nil
end

-- ----------------------------------------------------------------------------
-- Party Extraction Helper
-- ----------------------------------------------------------------------------
local function getPlayerParty(game)
  local okGame, Game = pcall(require, "src.core.Game")
  local g = game or (okGame and Game)
  if not g then return {} end

  local save = g.save or g.savedata
  if save and type(save.party) == "table" and #save.party > 0 then
    return save.party
  end
  if g.party and type(g.party) == "table" and #g.party > 0 then
    return g.party
  end
  return {}
end

local function getMonName(mon)
  if not mon then return "POKéMON" end
  local n = mon.nickname or mon.name or mon.species or "POKéMON"
  return tostring(n):upper()
end

local function getMoveName(move)
  if not move then return "" end
  local n = type(move) == "table" and (move.id or move.name) or move
  return tostring(n):upper():gsub("_", " ")
end

-- ----------------------------------------------------------------------------
-- UI State Machine Screen
-- ----------------------------------------------------------------------------
local SCREEN_ID = "OmniMoveRelearnerScreen"

local function createRelearnerScreen(game, mod, moduleManager)
  local okFont, Font = pcall(require, "src.render.Font")
  if not okFont or not Font then
    Font = mod and mod.ui and mod.ui.Font
  end

  local STATE_PARTY = 1
  local STATE_MOVE = 2
  local STATE_REPLACE = 3
  local STATE_MSG = 4

  local state = {
    isOpaque = true,
    curState = STATE_PARTY,
    selectedParty = 1,
    partyScrollOffset = 0,
    selectedMove = 1,
    moveScrollOffset = 0,
    selectedReplace = 1,
    chosenMon = nil,
    eligibleMoves = {},
    targetMove = nil,
    msgLines = {},
    nextState = STATE_PARTY,
  }

  local function showMessage(lines, afterState)
    state.msgLines = type(lines) == "table" and lines or { tostring(lines) }
    state.nextState = afterState or STATE_PARTY
    state.curState = STATE_MSG
  end

  local function playSound(name)
    pcall(function()
      local Sound = require("src.core.Sound")
      if Sound and type(Sound.play) == "function" then
        Sound.play(game, name)
      elseif Sound and type(Sound.playSFX) == "function" then
        Sound.playSFX(name)
      end
    end)
  end

  local function playCry(species)
    pcall(function()
      local Sound = require("src.core.Sound")
      if Sound and type(Sound.playCry) == "function" then
        Sound.playCry(species)
      end
    end)
  end

  local function getActiveInput()
    if game and game.input then return game.input end
    local okG, G = pcall(require, "src.core.Game")
    if okG and G and G.input then return G.input end
    return nil
  end

  local function popScreen()
    if game and game.stack and type(game.stack.pop) == "function" then
      game.stack:pop()
      return
    end
    local okG, G = pcall(require, "src.core.Game")
    if okG and G and G.stack and type(G.stack.pop) == "function" then
      G.stack:pop()
    end
  end

  function state:update()
    local party = getPlayerParty(game)
    local input = getActiveInput()
    if not input then return end

    -- 1. STATE_PARTY
    if self.curState == STATE_PARTY then
      if #party == 0 then
        if input:wasPressed("b") or input:wasPressed("a") then
          popScreen()
        end
        return
      end

      local totalParty = #party
      local maxVisible = 4

      if input:wasPressed("up") then
        self.selectedParty = self.selectedParty - 1
        if self.selectedParty < 1 then
          self.selectedParty = totalParty
          self.partyScrollOffset = math.max(0, totalParty - maxVisible)
        elseif self.selectedParty <= self.partyScrollOffset then
          self.partyScrollOffset = self.selectedParty - 1
        end
      elseif input:wasPressed("down") then
        self.selectedParty = self.selectedParty + 1
        if self.selectedParty > totalParty then
          self.selectedParty = 1
          self.partyScrollOffset = 0
        elseif self.selectedParty > self.partyScrollOffset + maxVisible then
          self.partyScrollOffset = self.selectedParty - maxVisible
        end
      elseif input:wasPressed("b") then
        popScreen()
      elseif input:wasPressed("a") then
        local mon = party[self.selectedParty]
        if mon then
          self.chosenMon = mon
          local mode = moduleManager and moduleManager:getValue("move_relearner") or "RELEARN"
          self.eligibleMoves = RelearnerData.getEligibleMoves and RelearnerData.getEligibleMoves(mon, mode) or {}
          if #self.eligibleMoves == 0 then
            showMessage({
              getMonName(mon) .. " has no",
              "moves to learn!",
            }, STATE_PARTY)
          else
            self.selectedMove = 1
            self.moveScrollOffset = 0
            self.curState = STATE_MOVE
          end
        end
      end

    -- 2. STATE_MOVE
    elseif self.curState == STATE_MOVE then
      local totalMoves = #self.eligibleMoves
      local maxVisible = 4

      if input:wasPressed("up") then
        self.selectedMove = self.selectedMove - 1
        if self.selectedMove < 1 then
          self.selectedMove = totalMoves
          self.moveScrollOffset = math.max(0, totalMoves - maxVisible)
        elseif self.selectedMove <= self.moveScrollOffset then
          self.moveScrollOffset = self.selectedMove - 1
        end
      elseif input:wasPressed("down") then
        self.selectedMove = self.selectedMove + 1
        if self.selectedMove > totalMoves then
          self.selectedMove = 1
          self.moveScrollOffset = 0
        elseif self.selectedMove > self.moveScrollOffset + maxVisible then
          self.moveScrollOffset = self.selectedMove - maxVisible
        end
      elseif input:wasPressed("b") then
        self.curState = STATE_PARTY
      elseif input:wasPressed("a") then
        local candidate = self.eligibleMoves[self.selectedMove]
        if candidate and self.chosenMon then
          self.targetMove = candidate
          local currentMoves = self.chosenMon.moves or {}

          -- If fewer than 4 moves: learn immediately!
          if #currentMoves < 4 then
            local newMoveKey = candidate.name
            local basePP = candidate.pp or 20
            table.insert(currentMoves, {
              id = newMoveKey,
              name = newMoveKey,
              pp = basePP,
              maxPp = basePP,
            })
            self.chosenMon.moves = currentMoves
            playSound("Level_Up")
            playCry(self.chosenMon.species)
            showMessage({
              getMonName(self.chosenMon) .. " learned",
              candidate.name .. "!",
            }, STATE_PARTY)
          else
            -- Already knows 4 moves: choose which to overwrite
            self.selectedReplace = 1
            self.curState = STATE_REPLACE
          end
        end
      end

    -- 3. STATE_REPLACE
    elseif self.curState == STATE_REPLACE then
      local currentMoves = self.chosenMon and self.chosenMon.moves or {}
      local totalSlots = math.min(4, #currentMoves)

      if input:wasPressed("up") then
        self.selectedReplace = self.selectedReplace - 1
        if self.selectedReplace < 1 then self.selectedReplace = totalSlots end
      elseif input:wasPressed("down") then
        self.selectedReplace = self.selectedReplace + 1
        if self.selectedReplace > totalSlots then self.selectedReplace = 1 end
      elseif input:wasPressed("b") then
        self.curState = STATE_MOVE
      elseif input:wasPressed("a") then
        local oldSlot = currentMoves[self.selectedReplace]
        local oldName = getMoveName(oldSlot)
        local isHM = ForgetHMsModule.isHMMove and ForgetHMsModule.isHMMove(oldSlot)

        -- If it's an HM move and forget_hms module is disabled, block replacement
        if isHM and not moduleManager:isEnabled("forget_hms") then
          showMessage({
            "HM moves cannot be",
            "forgotten! (FORGET HMS: OFF)",
          }, STATE_REPLACE)
          return
        end

        -- Replace the move
        local newMoveKey = self.targetMove.name
        local basePP = self.targetMove.pp or 20
        currentMoves[self.selectedReplace] = {
          id = newMoveKey,
          name = newMoveKey,
          pp = basePP,
          maxPp = basePP,
        }
        self.chosenMon.moves = currentMoves
        playSound("Level_Up")
        playCry(self.chosenMon.species)
        showMessage({
          getMonName(self.chosenMon) .. " forgot " .. oldName .. "!",
          "And learned " .. newMoveKey .. "!",
        }, STATE_PARTY)
      end

    -- 4. STATE_MSG
    elseif self.curState == STATE_MSG then
      if input:wasPressed("a") or input:wasPressed("b") then
        self.curState = self.nextState
      end
    end
  end

  function state:draw()
    if not Font or type(Font.drawBox) ~= "function" then return end

    local party = getPlayerParty(game)

    -- ========================================================================
    -- DRAW: PARTY SELECTION
    -- ========================================================================
    if self.curState == STATE_PARTY then
      Font.drawBox(0, 0, 20, 11)
      Font.draw("MOVE REMINDER", 16, 10)
      Font.draw("================", 16, 18)

      if #party == 0 then
        Font.draw("NO POKeMON IN PARTY", 16, 36)
      else
        local maxVisible = 4
        local startY = 28
        local stepY = 14
        local total = #party

        for idx = 1, maxVisible do
          local pIdx = (self.partyScrollOffset or 0) + idx
          if pIdx <= total then
            local mon = party[pIdx]
            local yPos = startY + (idx - 1) * stepY
            local isSel = (pIdx == self.selectedParty)
            if isSel then
              if type(Font.drawCode) == "function" then
                Font.drawCode(0xED, 8, yPos)
              else
                Font.draw(">", 8, yPos)
              end
            end

            local nameStr = getMonName(mon):sub(1, 10)
            local lvlStr = "L" .. tostring(mon.level or 1)
            Font.draw(nameStr, 16, yPos)
            Font.draw(lvlStr, 110, yPos)
          end
        end

        -- Scroll arrows
        if (self.partyScrollOffset or 0) > 0 then
          Font.draw("^", 144, 28)
        end
        if (self.partyScrollOffset or 0) + maxVisible < total then
          Font.draw("v", 144, 70)
        end
      end

      -- Bottom box
      Font.drawBox(0, 11, 20, 7)
      Font.draw("Choose a POKeMON", 16, 98)
      Font.draw("to remember a move.", 16, 112)
      Font.draw("A:SELECT  B:EXIT", 16, 126)

    -- ========================================================================
    -- DRAW: MOVE SELECTION
    -- ========================================================================
    elseif self.curState == STATE_MOVE then
      Font.drawBox(0, 0, 20, 11)
      local monTitle = getMonName(self.chosenMon):sub(1, 9) .. "'S MOVES"
      Font.draw(monTitle, 16, 10)
      Font.draw("================", 16, 18)

      local maxVisible = 4
      local startY = 28
      local stepY = 14
      local total = #self.eligibleMoves

      for idx = 1, maxVisible do
        local mIdx = self.moveScrollOffset + idx
        if mIdx <= total then
          local cand = self.eligibleMoves[mIdx]
          local yPos = startY + (idx - 1) * stepY
          local isSel = (mIdx == self.selectedMove)

          if isSel then
            if type(Font.drawCode) == "function" then
              Font.drawCode(0xED, 8, yPos)
            else
              Font.draw(">", 8, yPos)
            end
          end

          local mName = getMoveName(cand.name):sub(1, 12)
          Font.draw(mName, 16, yPos)
          local badge = cand.badge or (cand.level == 1 and "Lv 1" or ("Lv" .. tostring(cand.level)))
          Font.draw(badge, 114, yPos)
        end
      end

      -- Scroll arrows
      if self.moveScrollOffset > 0 then
        Font.draw("^", 144, 28)
      end
      if self.moveScrollOffset + maxVisible < total then
        Font.draw("v", 144, 70)
      end

      -- Bottom box: active move details
      Font.drawBox(0, 11, 20, 7)
      local selCand = self.eligibleMoves[self.selectedMove]
      if selCand then
        local line1 = selCand.type .. "  PP " .. tostring(selCand.pp) .. "/" .. tostring(selCand.pp)
        Font.draw(line1, 16, 98)
        if selCand.isTM and selCand.tmCode then
          local line2 = "Learned via " .. selCand.tmCode
          Font.draw(line2, 16, 112)
        elseif selCand.fromStage and selCand.fromStage ~= getMonName(self.chosenMon) then
          local line2 = "Pre-Evo: " .. selCand.fromStage:sub(1, 9)
          Font.draw(line2, 16, 112)
        end
      end
      Font.draw("A:LEARN  B:BACK", 16, 126)

    -- ========================================================================
    -- DRAW: REPLACE MOVE SELECTION
    -- ========================================================================
    elseif self.curState == STATE_REPLACE then
      Font.drawBox(0, 0, 20, 11)
      Font.draw("FORGET WHICH MOVE?", 16, 10)
      Font.draw("================", 16, 18)

      local currentMoves = self.chosenMon and self.chosenMon.moves or {}
      local startY = 28
      local stepY = 14

      for i = 1, 4 do
        local mv = currentMoves[i]
        local yPos = startY + (i - 1) * stepY
        local isSel = (i == self.selectedReplace)

        if isSel then
          if type(Font.drawCode) == "function" then
            Font.drawCode(0xED, 8, yPos)
          else
            Font.draw(">", 8, yPos)
          end
        end

        if mv then
          local nameStr = getMoveName(mv):sub(1, 12)
          local isHM = ForgetHMsModule.isHMMove and ForgetHMsModule.isHMMove(mv)
          Font.draw(nameStr, 16, yPos)
          if isHM then
            Font.draw("HM", 126, yPos)
          end
        else
          Font.draw("-", 16, yPos)
        end
      end

      -- Bottom box
      Font.drawBox(0, 11, 20, 7)
      if self.targetMove then
        Font.draw("New: " .. getMoveName(self.targetMove.name):sub(1, 12), 16, 98)
      end
      Font.draw("A:FORGET  B:CANCEL", 16, 126)

    -- ========================================================================
    -- DRAW: MESSAGE PROMPT
    -- ========================================================================
    elseif self.curState == STATE_MSG then
      Font.drawBox(0, 0, 20, 11)
      Font.draw("MOVE REMINDER", 16, 10)
      Font.draw("================", 16, 18)

      Font.drawBox(0, 11, 20, 7)
      if self.msgLines[1] then
        Font.draw(self.msgLines[1], 16, 98)
      end
      if self.msgLines[2] then
        Font.draw(self.msgLines[2], 16, 112)
      end
      Font.draw("A:CONTINUE", 16, 126)
    end
  end

  return state
end

-- ----------------------------------------------------------------------------
-- Public Module Lifecycle
-- ----------------------------------------------------------------------------
function MoveRelearnerModule.register(moduleManager)
  moduleManager:register({
    id = "move_relearner",
    label = "RELEARN",
    desc = "Relearn level-up moves (with pre-evos).",
    default = "RELEARN",
    values = { "OFF", "RELEARN", "RELEARN+TMS" },
    init = function(mod, mgr)
      MoveRelearnerModule.init(mod, mgr)
    end,
  })
end

function MoveRelearnerModule.open(game, mod, moduleManager)
  local okGame, Game = pcall(require, "src.core.Game")
  local targetGame = game or (okGame and Game)
  local stack = targetGame and targetGame.stack

  if stack and type(stack.push) == "function" then
    stack:push(createRelearnerScreen(targetGame, mod, moduleManager))
  elseif mod and mod.ui and type(mod.ui.push) == "function" then
    mod.ui.push(targetGame, SCREEN_ID)
  end
end

-- Inject NPC into map definitions
local function injectMapObjects()
  local okData, Data = pcall(require, "src.core.Data")
  if not (okData and Data and Data.maps) then return end

  for mapId, _ in pairs(POKECENTER_MAPS) do
    local def = Data.maps[mapId]
    if def and def.objects then
      local exists = false
      for _, o in ipairs(def.objects) do
        if o.name == "OMNI_RELEARNER" then
          exists = true
          break
        end
      end
      if not exists then
        local newIndex = #def.objects + 1
        table.insert(def.objects, {
          index = newIndex,
          movement = "STAY",
          name = "OMNI_RELEARNER",
          range = "RIGHT",
          sprite = "SPRITE_GENTLEMAN",
          text = "TEXT_OMNI_RELEARNER",
          x = (mapId == "INDIGO_PLATEAU_LOBBY") and 2 or 1,
          y = (mapId == "INDIGO_PLATEAU_LOBBY") and 5 or 4,
        })
      end
    end
  end
end

function MoveRelearnerModule.init(mod, moduleManager)
  -- 1. Register screen in content registry
  if mod.content and mod.content.screens and type(mod.content.screens.register) == "function" then
    mod.content.screens:register(SCREEN_ID, {
      new = function(game)
        return createRelearnerScreen(game, mod, moduleManager)
      end,
    })
  end

  -- 2. Inject NPC objects into all Pokémon Center map definitions up front
  injectMapObjects()

  -- 3. Intercept talking to the Move Relearner NPC in the overworld
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("world.talk", function(next, ow, npc)
      if npc and npc.def and (npc.def.name == "OMNI_RELEARNER" or (npc.id and npc.id:find("OMNI_RELEARNER"))) then
        if moduleManager:isEnabled("move_relearner") then
          local okGame, Game = pcall(require, "src.core.Game")
          local game = (okGame and Game) or (ow and (ow.game or ow))
          MoveRelearnerModule.open(game, mod, moduleManager)
        end
        return
      end
      return next and next(ow, npc)
    end)

    -- Control visibility via objectVisible hook
    mod.hooks:wrap("world.object_visible", function(next, save, mapId, obj)
      if obj and obj.name == "OMNI_RELEARNER" then
        return moduleManager:isEnabled("move_relearner")
      end
      return next and next(save, mapId, obj)
    end)
  end

  -- 4. Listen to map entry to ensure live map object instantiation
  if mod.events and type(mod.events.on) == "function" then
    mod.events:on("map.entered", function(payload)
      local mapId = type(payload) == "table" and payload.mapId or payload
      if isPokeCenter(mapId) then
        injectMapObjects()

        -- If live OverworldState has npcPool, make sure the NPC instance is live
        local okGame, Game = pcall(require, "src.core.Game")
        if okGame and Game and Game.overworld and Game.overworld.map and Game.overworld.map.id == mapId then
          local ow = Game.overworld
          local found = false
          for _, n in ipairs(ow.npcs or {}) do
            if n.def and n.def.name == "OMNI_RELEARNER" then
              found = true
              break
            end
          end
          if not found and ow.addRuntimeObject and moduleManager:isEnabled("move_relearner") then
            ow:addRuntimeObject(mapId, {
              movement = "STAY",
              name = "OMNI_RELEARNER",
              range = "RIGHT",
              sprite = "SPRITE_GENTLEMAN",
              text = "TEXT_OMNI_RELEARNER",
              x = (mapId == "INDIGO_PLATEAU_LOBBY") and 2 or 1,
              y = (mapId == "INDIGO_PLATEAU_LOBBY") and 5 or 4,
            }, mod.id or "omni_qol")
          end
        end
      end
    end)
  end
end

return MoveRelearnerModule
