-- ============================================================================
-- OmniQoL: Trade Evolutions Module (Gen 1: Red, Blue, Yellow)
--
-- Features:
-- - Natural Level-Up Evolutions:
--   * Kadabra  -> Alakazam at Level 40
--   * Machoke  -> Machamp  at Level 40
--   * Graveler -> Golem    at Level 40
--   * Haunter  -> Gengar   at Level 40
-- - Coexistence with Link Trades:
--   * Traditional trading continues to function normally as an alternative.
-- - Rare Candy Support at Level 100 (Gen 8+ style):
--   * Using a Rare Candy on a Level 100 trade-evolution Pokémon triggers its
--     evolution sequence without leveling it past 100.
-- - Standard B-Button Cancellation:
--   * Preserves authentic level-up behavior: players can cancel the evolution
--     by pressing B during the sequence.
-- - In-Game NPC Trade Preservation:
--   * NPC trade Pokémon (e.g. Machoke in Underground Path/Blue) do not
--     instantly evolve upon receipt; they evolve upon their next level-up to 40+.
-- - Options Menu Integration:
--   * Configurable directly in the OMNIQOL Settings screen (`TRADE EVOS`).
--   * Enabled by default with per-save persistence and Title Screen global storage.
-- ============================================================================

local TradeEvosModule = {}

local EVOLUTION_LEVEL = 40

local TRADE_SPECIES = {
  KADABRA  = "ALAKAZAM",
  MACHOKE  = "MACHAMP",
  GRAVELER = "GOLEM",
  HAUNTER  = "GENGAR",
}

function TradeEvosModule.register(moduleManager)
  moduleManager:register({
    id = "trade_evos",
    label = "TRADE EVOS",
    desc = "Trade evolutions at Level 40.",
    default = true,
    init = function(mod, mgr)
      TradeEvosModule.init(mod, mgr)
    end,
  })
end

function TradeEvosModule.init(mod, moduleManager)
  -- 1. Patch Pokémon definitions if content registry is available
  if mod.content and mod.content.pokemon and type(mod.content.pokemon.patch) == "function" then
    for baseSpecies, targetSpecies in pairs(TRADE_SPECIES) do
      pcall(function()
        mod.content.pokemon:patch(baseSpecies, {
          evolutions = {
            { method = "TRADE", species = targetSpecies },
            { method = "LEVEL", level = EVOLUTION_LEVEL, species = targetSpecies, isTradeAlternative = true },
          },
        })
      end)
    end
  end

  -- 2. Hook evolution.check to dynamically evaluate level-up trigger
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("evolution.check", function(next, gameOrData, mon, evo, trigger)
      if not mon or not evo then
        return next and next(gameOrData, mon, evo, trigger) or false
      end

      -- If this is our tagged alternative level-up evolution row
      if evo.isTradeAlternative then
        if not moduleManager:isEnabled("trade_evos") then
          return false
        end
        return (mon.level or 0) >= (evo.level or EVOLUTION_LEVEL)
      end

      -- Dynamic fallback: if registry patch was not applied or was overwritten
      local targetSpecies = TRADE_SPECIES[mon.species]
      if targetSpecies and evo.method == "TRADE" and moduleManager:isEnabled("trade_evos") then
        if trigger and trigger.kind == "levelup" and (mon.level or 0) >= EVOLUTION_LEVEL then
          return true
        end
      end

      -- Normal check (handles genuine link-trades and other evolution methods)
      return next and next(gameOrData, mon, evo, trigger) or false
    end)
  end

  -- 3. Ensure B-button cancel is allowed for level-up triggered trade evolutions
  local okEvoState, EvolutionState = pcall(require, "src.ui.EvolutionState")
  if okEvoState and EvolutionState and type(EvolutionState.new) == "function" then
    local origNew = EvolutionState.new
    EvolutionState.new = function(game, mon, newSpecies, onDone, via)
      local state = origNew(game, mon, newSpecies, onDone, via)
      -- Allow B-cancel if triggered outside of actual multiplayer link session
      if moduleManager:isEnabled("trade_evos") and via == "TRADE" and state and not (game and game.link) then
        state.cancelable = true
      end
      return state
    end
  end

  -- 4. Support Rare Candy evolution at Level 100 (Gen 8+ QoL mechanic)
  local okItemEffects, ItemEffects = pcall(require, "src.inventory.ItemEffects")
  if okItemEffects and ItemEffects and type(ItemEffects.use) == "function" then
    local origUse = ItemEffects.use
    ItemEffects.use = function(data, save, itemId, target, battle, moveIndex, ow)
      if moduleManager:isEnabled("trade_evos") and itemId == "RARE_CANDY" and target and (target.level or 0) >= 100 then
        local targetSpecies = TRADE_SPECIES[target.species]
        if targetSpecies then
          pcall(function()
            local Sound = require("src.core.Sound")
            Sound.play(data, "Heal_Ailment")
          end)
          return "consumed", nil, { evolveTo = targetSpecies }
        end
      end
      return origUse(data, save, itemId, target, battle, moveIndex, ow)
    end
  end
end

return TradeEvosModule
