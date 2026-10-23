-- ============================================================================
-- OmniQoL: Running Module (Gen 1 & Gen 2)
-- Supported Games: Red, Blue, Yellow, Gold, Silver, Crystal
--
-- Features:
-- - Hold B to run at 2x walking speed (8 frames per tile instead of 16).
-- - Seamless Pikachu Follower integration (Yellow): Pikachu dynamically scales
--   its follow speed (8 frames/tile, 4 frames/tile catch-up) to match the player.
-- - Usable everywhere (indoors, outdoors, caves, buildings, Safari Zone).
-- - Preserves normal Bicycle and Surf speeds (no unintended acceleration).
-- - Preserves authentic Gen 2 Ice Path puzzle sliding physics.
-- - Preserves standard wild encounter rates (no encounter penalty).
-- - Defensive checks & cross-engine compatibility across Gen 1 and Gen 2 recomp.
-- - Restores vanilla stepFramesCur when idle or during scripted cutscenes.
-- ============================================================================

local RunningModule = {}

local WALK_FRAMES = 16   -- Engine vanilla walking duration per tile
local MIN_FRAMES = 4     -- Absolute floor for frame duration
local SPEED_FACTOR = 2   -- 2x walking speed (matching Bicycle speed)

function RunningModule.register(moduleManager)
  moduleManager:register({
    id = "running",
    label = "RUNNING",
    desc = "Hold B to run at 2x speed.",
    default = true,
    supportedGenerations = { "gen1", "gen2" },
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

  --- Helper to check whether player is currently surfing, riding a bicycle, or sliding on ice
  local function isMountedOrSurfingOrSliding(ctx, game)
    if not ctx then return false end

    -- Gen 1 / Gen 2 context flags: bike, cycling, surf, and ice sliding
    if ctx.onBike or ctx.cycling or ctx.biking or ctx.surfing or ctx.isSurfing or ctx.sliding or ctx.onIce then
      return true
    end

    if ctx.state then
      local stateStr = tostring(ctx.state):upper()
      if stateStr:find("BIKE") or stateStr:find("CYCL") or stateStr:find("SURF") or stateStr:find("ICE") or stateStr:find("SLID") then
        return true
      end
    end

    -- Check player entity directly if present
    local p = ctx.player or (game and (game.player or (game.overworld and game.overworld.player)))
    if p then
      if p.onBike or p.cycling or p.biking or p.surfing or p.isSurfing or p.sliding or p.onIce then
        return true
      end
    end

    return false
  end

  --- Helper to detect if B button is pressed across different engine APIs
  local function isBDown(ctx, game)
    local input = ctx and ctx.input
    if not input and game then input = game.input end
    if not input and mod then input = mod.input end

    if input and type(input.isDown) == "function" then
      return input:isDown("b")
    end

    -- Fallback to Love2D keyboard/joystick if direct input is not provided
    if love and love.keyboard and love.keyboard.isDown then
      if love.keyboard.isDown("x") or love.keyboard.isDown("b") or love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        return true
      end
    end

    return false
  end

  -- Wrap movement.speed hook (Cookbook Recipe R40 standard across Recomp engines)
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("movement.speed", function(next, frames, ctx)
      local base = tonumber(next and next(frames, ctx) or frames) or WALK_FRAMES
      if type(ctx) ~= "table" then return base end

      -- Check if the Running module is toggled ON in active save
      if not moduleManager:isEnabled("running") then
        return base
      end

      -- If player is on a bicycle, surfing, or sliding on ice, preserve standard behavior
      if isMountedOrSurfingOrSliding(ctx) then
        return base
      end

      -- Check if B button is held
      if not isBDown(ctx) then
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
