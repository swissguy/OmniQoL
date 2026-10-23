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
--     Stat EXP across all 5 stats.
-- - Clean, Streamlined Announcements:
--   * Active battlers receive their standard individual EXP gain text.
--   * Benched team members are announced with a single consolidated message:
--     "The rest of the team gained EXP!"
--   * Immediate sequence for level-ups, stat boxes, and move learning.
-- - Seamless Options Menu Integration:
--   * Configured directly in the OMNIQOL Settings screen.
--   * No Bag inventory space consumed.
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

  -- 1. Hook exp.gain to award 50% EXP to benched party members
  -- Note: Active battlers continue receiving 100% EXP.
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("exp.gain", function(next, ctx)
      local baseExp = tonumber(next and next(ctx)) or 0
      if moduleManager:isEnabled("exp_share") and ctx and ctx.mon and benchedMons[ctx.mon] then
        return math.max(1, math.floor(baseExp / 2))
      end
      return baseExp
    end)
  end

  -- 2. Hook battle.exp_award to orchestrate party-wide distribution
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("battle.exp_award", function(next, ctx)
      -- Fallback to vanilla if module is toggled off
      if not moduleManager:isEnabled("exp_share") then
        return next and next(ctx)
      end

      if type(ctx) ~= "table" or not ctx.battle or type(ctx.applyShare) ~= "function" then
        return next and next(ctx)
      end

      local battle = ctx.battle
      local playerParty = battle:playerPartyView()
      if type(playerParty) ~= "table" then
        return next and next(ctx)
      end

      -- Identify active living battlers
      local aliveBattlers = ctx.alive or {}

      -- 1) Award 100% EXP & full Stat EXP to each living active participant (Gen 8+ style)
      for _, mon in ipairs(aliveBattlers) do
        -- split = 1 awards 100% Stat EXP and 100% EXP; announce = true prints standard gain text
        ctx.applyShare(mon, 1, true)
      end

      -- 2) Identify non-fainted party members that did not fight
      local benched = {}
      for _, mon in ipairs(playerParty) do
        local fought = false
        for _, active in ipairs(aliveBattlers) do
          if active == mon then
            fought = true
            break
          end
        end
        if not fought and mon.hp and mon.hp > 0 then
          table.insert(benched, mon)
        end
      end

      -- 3) Distribute 50% EXP & full Stat EXP to benched members
      if #benched > 0 then
        -- Print single consolidated notification for benched members
        local msg = "The rest of the\nteam gained EXP!"
        local ok, Strings = pcall(require, "src.core.Strings")
        if ok and Strings and type(Strings) == "function" then
          msg = Strings(msg)
        end
        battle:sayNext(msg)

        -- Apply shares silently; if a mon levels up, applyShare automatically
        -- queues its level-up fanfare, stat box, and move learning prompt.
        for _, mon in ipairs(benched) do
          benchedMons[mon] = true
          -- split = 1 ensures full (100%) Stat EXP is added to mon.statExp
          -- announce = false suppresses individual repetitive "X gained Y EXP" boxes
          local okShare, err = pcall(ctx.applyShare, mon, 1, false)
          benchedMons[mon] = nil
          if not okShare and mod.log and mod.log.error then
            mod.log:error("[OmniQoL] Error applying EXP share to benched mon: " .. tostring(err))
          end
        end
      end
    end)
  end
end

return ExpShareModule
