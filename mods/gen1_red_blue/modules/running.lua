-- ============================================================================
-- G1R Deluxe: Running Module (Pokémon Red & Blue)
--
-- Features:
-- - Hold B to run at 2x walking speed (8 frames per tile instead of 16).
-- - Usable everywhere (indoors, outdoors, caves, buildings).
-- - Preserves normal Bicycle and Surf speeds (no unintended acceleration).
-- - Preserves standard wild encounter rates (no encounter penalty).
-- - Restores vanilla stepFramesCur when idle or during scripted cutscenes
--   (preventing desyncs with escort NPCs like Professor Oak).
-- ============================================================================

local RunningModule = {}

local WALK_FRAMES = 16   -- Engine vanilla walking duration per tile
local MIN_FRAMES = 4     -- Absolute floor for frame duration
local SPEED_FACTOR = 2   -- 2x walking speed (matching Bicycle speed)

function RunningModule.register(moduleManager)
  moduleManager:register({
    id = "running",
    label = "RUNNING",
    desc = "Hold B to run at 2x walking speed.",
    default = true,
    init = function(mod, mgr)
      RunningModule.initHooks(mod, mgr)
    end,
  })
end

function RunningModule.initHooks(mod, moduleManager)
  local tracked = nil
  local ourFrames = nil
  local vanillaFrames = nil

  --- Restores the player's stepFramesCur back to the engine's original duration.
  local function restore()
    local player = tracked
    tracked = nil
    if not player then return end

    -- Only restore if the current step duration is still our custom running duration.
    -- If something else changed it (e.g., bike mount/dismount), leave it untouched.
    if player.stepFramesCur == ourFrames then
      player.stepFramesCur = vanillaFrames
    end
  end

  -- Wrap movement.speed hook
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("movement.speed", function(next, frames, ctx)
      local base = tonumber(next and next(frames, ctx) or frames) or WALK_FRAMES
      if type(ctx) ~= "table" then return base end

      -- Check if the Running module is toggled ON in active save
      if not moduleManager:isEnabled("running") then
        return base
      end

      -- If player is on a bicycle or surfing, preserve standard behavior
      if ctx.onBike or ctx.surfing then
        return base
      end

      -- Check if B button is held
      local input = ctx.input
      if not (input and type(input.isDown) == "function" and input:isDown("b")) then
        return base
      end

      -- Calculate 2x speed duration (16 -> 8 frames)
      local sped = math.floor(base / SPEED_FACTOR + 0.5)
      if sped < MIN_FRAMES then sped = MIN_FRAMES end
      if sped > base then return base end

      -- Track the player entity and duration to restore when idle
      tracked = ctx.player
      ourFrames = sped
      vanillaFrames = base

      return sped
    end)
  end

  -- Restore duration when the player finishes moving
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("input.step", function(next, game, dt)
      local out = next and next(game, dt)
      if tracked and not tracked.moving then
        restore()
      end
      return out
    end)
  end

  -- Restore duration immediately when a script or cutscene begins
  -- (e.g., Oak walking player to lab, Pewter museum guide, Viridian catching tutorial)
  if mod.events and type(mod.events.on) == "function" then
    mod.events:on("script.started", function()
      restore()
    end)

    -- Clean up tracking on map transitions or battles
    mod.events:on("map.exited", function()
      restore()
    end)

    mod.events:on("battle.started", function()
      restore()
    end)
  end
end

return RunningModule
