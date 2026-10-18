-- ============================================================================
-- OmniQoL: Forget HMs Module (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
--
-- Features:
-- - Enables freely replacing and forgetting HM moves (Cut, Fly, Surf, Strength, Flash)
--   whenever learning any new move (via Level Up, TM, or the Move Relearner).
-- - In vanilla Gen 1, HM moves are locked and cannot be overwritten or forgotten.
--   This module removes that restriction when enabled.
-- - Separate, dedicated toggle in the OmniQoL Options Menu (`FORGET HMS`).
-- - Enabled by default with per-save persistence and Title Screen global storage.
-- ============================================================================

local ForgetHMsModule = {}

local HM_MOVES = {
  CUT = true,
  FLY = true,
  SURF = true,
  STRENGTH = true,
  FLASH = true,
}

local HM_MOVE_IDS = {
  [15] = true,   -- CUT
  [19] = true,   -- FLY
  [57] = true,   -- SURF
  [70] = true,   -- STRENGTH
  [148] = true,  -- FLASH
}

function ForgetHMsModule.isHMMove(move)
  if not move then return false end
  if type(move) == "number" then
    return HM_MOVE_IDS[move] == true
  end
  local name = type(move) == "table" and (move.id or move.name) or move
  local norm = tostring(name):upper():gsub("[^%w_]", "")
  return HM_MOVES[norm] == true
end

function ForgetHMsModule.register(moduleManager)
  moduleManager:register({
    id = "forget_hms",
    label = "FORGET HMS",
    desc = "Allows replacing and forgetting HM moves.",
    default = true,
    init = function(mod, mgr)
      ForgetHMsModule.init(mod, mgr)
    end,
  })
end

function ForgetHMsModule.init(mod, moduleManager)
  -- 1. Hook engine move queries
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    -- Hook move.can_forget
    mod.hooks:wrap("move.can_forget", function(next, moveId, ...)
      if moduleManager:isEnabled("forget_hms") then
        return true
      end
      return next and next(moveId, ...)
    end)

    -- Hook move.is_hm
    mod.hooks:wrap("move.is_hm", function(next, moveId, ...)
      if moduleManager:isEnabled("forget_hms") then
        return false
      end
      return next and next(moveId, ...)
    end)

    -- Hook pokemon.can_forget_move
    mod.hooks:wrap("pokemon.can_forget_move", function(next, mon, moveIndex, ...)
      if moduleManager:isEnabled("forget_hms") then
        return true
      end
      return next and next(mon, moveIndex, ...)
    end)

    -- Hook hm.can_forget
    mod.hooks:wrap("hm.can_forget", function(next, ...)
      if moduleManager:isEnabled("forget_hms") then
        return true
      end
      return next and next(...)
    end)
  end

  -- 2. Wrap ItemEffects if teaching a TM/HM
  local okItemEffects, ItemEffects = pcall(require, "src.inventory.ItemEffects")
  if okItemEffects and ItemEffects then
    if type(ItemEffects.canForgetMove) == "function" then
      local origCanForget = ItemEffects.canForgetMove
      ItemEffects.canForgetMove = function(mon, moveIdx, ...)
        if moduleManager:isEnabled("forget_hms") then
          return true
        end
        return origCanForget(mon, moveIdx, ...)
      end
    end

    if type(ItemEffects.isHMMove) == "function" then
      local origIsHM = ItemEffects.isHMMove
      ItemEffects.isHMMove = function(moveId, ...)
        if moduleManager:isEnabled("forget_hms") then
          return false
        end
        return origIsHM(moveId, ...)
      end
    end
  end

  -- 3. Wrap LearnMoveState UI if present
  local okLearnUI, LearnMoveState = pcall(require, "src.ui.LearnMoveState")
  if okLearnUI and LearnMoveState and type(LearnMoveState.canReplaceMove) == "function" then
    local origCanReplace = LearnMoveState.canReplaceMove
    LearnMoveState.canReplaceMove = function(self, moveIdx, ...)
      if moduleManager:isEnabled("forget_hms") then
        return true
      end
      return origCanReplace(self, moveIdx, ...)
    end
  end
end

return ForgetHMsModule
