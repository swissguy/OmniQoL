-- ============================================================================
-- OmniQoL: EXP Share Module (Gen 1 & Gen 2: Red, Blue, Yellow, Gold, Silver, Crystal)
--
-- Features:
-- - Modern Gen 6+ EXP Distribution:
--   * Active battlers receive 100% EXP (Gen 8+ style, full battler pool).
--   * Benched non-fainted party members receive 50% EXP.
--   * Fainted Pokémon receive 0 EXP.
-- - Full Stat EXP (Modern Gen 6+ EV style):
--   * Every Pokémon that earns EXP also receives 100% of the defeated Pokémon's
--     Stat EXP across all stats.
-- - Clean, Streamlined Announcements:
--   * Active battlers receive their standard individual EXP gain text.
--   * Benched team members are announced with a single consolidated message:
--     "The rest of the team gained EXP!"
--   * Immediate sequence for level-ups, stat boxes, and move learning.
-- - Cross-Generation Battle Engine Architecture:
--   * Full compatibility across Gen 1 (battle:playerPartyView) and Gen 2 (battle.party,
--     battle.player active mon, battle.save) battle structures.
--   * Hook priority 90 ensures execution precedence over default/overhaul handlers.
-- - Options Menu Integration:
--   * Configured directly in the OMNIQOL Settings screen across all supported games.
--   * No Bag inventory space or held item slot consumed.
--   * Enabled by default from the start of the game, with per-save persistence.
-- ============================================================================

local ExpShareModule = {}

function ExpShareModule.register(moduleManager)
  moduleManager:register({
    id = "exp_share",
    label = "EXP SHARE",
    desc = "Party shares EXP and Stat EXP.",
    default = true,
    supportedGenerations = { "gen1", "gen2" },
    init = function(mod, mgr)
      ExpShareModule.initHooks(mod, mgr)
    end,
  })
end

function ExpShareModule.initHooks(mod, moduleManager)
  -- Track which Pokémon are currently receiving their benched EXP share
  local benchedMons = setmetatable({}, { __mode = "k" })

  -- Helper to extract player party across Gen 1 & Gen 2 battle engines
  local function resolvePlayerParty(battle, ctx)
    -- 1. Gen 1 recomp: battle:playerPartyView()
    if battle and type(battle.playerPartyView) == "function" then
      local ok, res = pcall(battle.playerPartyView, battle)
      if ok and type(res) == "table" and #res > 0 then
        return res
      end
    end

    -- 2. Gen 2 recomp: battle.party
    if battle and type(battle.party) == "table" and #battle.party > 0 then
      return battle.party
    end

    -- 3. Alternative engine properties: battle.playerParty, ctx.party, ctx.playerParty
    if battle and type(battle.playerParty) == "table" and #battle.playerParty > 0 then
      return battle.playerParty
    end
    if ctx and type(ctx.party) == "table" and #ctx.party > 0 then
      return ctx.party
    end
    if ctx and type(ctx.playerParty) == "table" and #ctx.playerParty > 0 then
      return ctx.playerParty
    end

    -- 4. Player entity party: battle.player.party
    if battle and battle.player and type(battle.player.party) == "table" and #battle.player.party > 0 then
      return battle.player.party
    end

    -- 5. Save state party fallback: battle.save.party or mod.save.party
    if battle and battle.save and type(battle.save.party) == "table" and #battle.save.party > 0 then
      return battle.save.party
    end
    if mod and mod.save and type(mod.save.party) == "table" and #mod.save.party > 0 then
      return mod.save.party
    end

    return nil
  end

  -- Helper to safely display consolidated battle message across Gen 1 & Gen 2 engines
  local function sayBattleMessage(battle, msg)
    if not battle then return end

    local text = msg
    local okStrings, Strings = pcall(require, "src.core.Strings")
    if okStrings and Strings and type(Strings) == "function" then
      local okConv, resConv = pcall(Strings, text)
      if okConv and resConv then text = resConv end
    end

    if type(battle.sayNext) == "function" then
      pcall(battle.sayNext, battle, text)
    elseif type(battle.say) == "function" then
      pcall(battle.say, battle, text)
    elseif type(battle.message) == "function" then
      pcall(battle.message, battle, text)
    elseif type(battle.print) == "function" then
      pcall(battle.print, battle, text)
    elseif type(battle.textbox) == "function" then
      pcall(battle.textbox, battle, text)
    end
  end

  -- 1. Hook exp.gain to award 50% EXP to benched party members (Priority 90)
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("exp.gain", function(next, a1, a2)
      local ctx = (type(a1) == "table" and a1.mon and a1) or (type(a2) == "table" and a2.mon and a2) or (type(a1) == "table" and a1) or {}
      local baseExp = tonumber(next and next(a1, a2)) or 0
      local mon = ctx.mon or (type(a1) == "table" and a1.species and a1) or (type(a2) == "table" and a2.species and a2)

      if moduleManager:isEnabled("exp_share") and mon and benchedMons[mon] then
        return math.max(1, math.floor(baseExp / 2))
      end
      return baseExp
    end, 90)
  end

  -- 2. Hook battle.exp_award to orchestrate party-wide distribution across Gen 1 and Gen 2 (Priority 90)
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("battle.exp_award", function(next, a1, a2)
      -- Normalize ctx and battle parameters across varying engine hook signatures
      local ctx = (type(a1) == "table" and a1.battle and a1) or (type(a2) == "table" and a2.battle and a2) or (type(a1) == "table" and a1) or {}
      local battle = ctx.battle or (type(a1) == "table" and a1.party and a1) or (type(a1) == "table" and a1)

      -- Fallback to vanilla if module is toggled off in active save or settings
      if not moduleManager:isEnabled("exp_share", battle and (battle.game or battle)) then
        return next and next(a1, a2)
      end

      -- Resolve applyShare function from ctx or battle
      local applyShare = ctx.applyShare
      if type(applyShare) ~= "function" and battle and type(battle.applyShare) == "function" then
        applyShare = function(...) return battle:applyShare(...) end
      end

      -- If the engine does not provide applyShare facade, defer to vanilla
      if type(applyShare) ~= "function" then
        return next and next(a1, a2)
      end

      -- Resolve player party across Gen 1 and Gen 2 battle structures
      local playerParty = resolvePlayerParty(battle, ctx)
      if type(playerParty) ~= "table" or #playerParty == 0 then
        return next and next(a1, a2)
      end

      -- Identify living active battlers (ctx.alive in Gen 1; battle.player active mon in Gen 2)
      local aliveBattlers = (type(ctx.alive) == "table" and ctx.alive) or {}
      if #aliveBattlers == 0 and battle then
        local activeMon = (battle.player and type(battle.player) == "table" and battle.player) or battle.activeMon
        if activeMon and type(activeMon) == "table" then
          local hp = activeMon.hp or activeMon.currentHp or activeMon.curHp
          if hp == nil or hp > 0 then
            aliveBattlers = { activeMon }
          end
        end
      end

      -- 1) Award 100% EXP & full Stat EXP to each living active participant (Gen 8+ style)
      for _, mon in ipairs(aliveBattlers) do
        -- split = 1 awards 100% Stat EXP and 100% EXP; announce = true prints standard gain text
        pcall(applyShare, mon, 1, true)
      end

      -- 2) Identify non-fainted party members that did not fight
      local benched = {}
      for _, mon in ipairs(playerParty) do
        local fought = false
        for _, active in ipairs(aliveBattlers) do
          if active == mon or (active.uid and mon.uid and active.uid == mon.uid) then
            fought = true
            break
          end
        end
        local hp = mon.hp or mon.currentHp or mon.curHp
        local isAlive = (hp == nil or hp > 0) and not mon.fainted and not mon.isFainted
        if not fought and isAlive then
          table.insert(benched, mon)
        end
      end

      -- 3) Distribute 50% EXP & full Stat EXP to benched members
      if #benched > 0 then
        -- Print single consolidated notification for benched members
        sayBattleMessage(battle, "The rest of the\nteam gained EXP!")

        -- Apply shares silently; if a mon levels up, applyShare automatically
        -- queues its level-up fanfare, stat box, and move learning prompt.
        for _, mon in ipairs(benched) do
          benchedMons[mon] = true
          -- split = 1 ensures full (100%) Stat EXP is added to mon.statExp
          -- announce = false suppresses individual repetitive "X gained Y EXP" boxes
          local okShare, err = pcall(applyShare, mon, 1, false)
          benchedMons[mon] = nil
          if not okShare and mod and mod.log and mod.log.error then
            mod.log:error("[OmniQoL] Error applying EXP share to benched mon: " .. tostring(err))
          end
        end
      end
    end, 90)
  end
end

return ExpShareModule
