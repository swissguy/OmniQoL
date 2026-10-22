-- ============================================================================
-- OmniQoL: Core Module Manager (Generation 1 & Generation 2)
-- Handles registration, state lookup, per-save persistence, global defaults,
-- and generation/game compatibility filtering.
-- ============================================================================

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(mod, gameDetector)
  local self = setmetatable({}, ModuleManager)
  self.mod = mod
  self.detector = gameDetector
  self.game = gameDetector and gameDetector.detectGame(mod) or "red"
  self.generation = gameDetector and gameDetector.detectGeneration(mod) or "gen1"
  self.modules = {}          -- list for ordered iteration
  self.modulesById = {}      -- map for quick lookup
  self.globalDefaults = {}   -- fallback storage for Title Screen / New Game
  return self
end

--- Registers a new QoL module.
-- @param def Table containing module metadata, compatibility constraints, and lifecycle hooks
function ModuleManager:register(def)
  assert(def and def.id, "Module definition must have an 'id'")
  assert(def.label, "Module definition must have a 'label'")
  if def.default == nil then def.default = true end

  -- Check generation compatibility
  if def.supportedGenerations then
    local genMatch = false
    for _, gen in ipairs(def.supportedGenerations) do
      if gen == self.generation then
        genMatch = true
        break
      end
    end
    if not genMatch then
      return nil
    end
  end

  -- Check specific game compatibility
  if def.supportedGames then
    local gameMatch = false
    for _, g in ipairs(def.supportedGames) do
      if g == self.game then
        gameMatch = true
        break
      end
    end
    if not gameMatch then
      return nil
    end
  end

  local modEntry = {
    id = def.id,
    label = def.label,
    desc = def.desc or "",
    default = def.default,
    values = def.values,
    init = def.init,
    supportedGenerations = def.supportedGenerations,
    supportedGames = def.supportedGames,
  }

  table.insert(self.modules, modEntry)
  self.modulesById[def.id] = modEntry
  self.globalDefaults[def.id] = def.default

  -- Read persistent global option if mod.options API exists
  if self.mod and self.mod.options and type(self.mod.options.get) == "function" then
    local ok, optVal = pcall(function() return self.mod.options:get(def.id) end)
    if ok and optVal ~= nil then
      if def.values then
        self.globalDefaults[def.id] = tostring(optVal)
      else
        self.globalDefaults[def.id] = (optVal == true)
      end
    end
  end

  if type(def.init) == "function" then
    local ok, err = pcall(def.init, self.mod, self)
    if not ok then
      if self.mod.log and self.mod.log.error then
        self.mod.log:error("Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      else
        print("[OmniQoL] Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      end
    end
  end

  return modEntry
end

--- Gets whether a module is currently enabled.
-- Checks per-save storage first; falls back to global defaults / initial default.
-- @param id string
-- @return boolean
--- Gets the raw or typed value of a module setting.
-- Checks per-save storage first; falls back to global defaults / initial default.
-- @param id string
-- @return any
function ModuleManager:getValue(id)
  local entry = self.modulesById[id]
  local fallback = self.globalDefaults[id]
  if fallback == nil then
    fallback = entry and entry.default
  end

  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.get) == "function" then
    local ok, val = pcall(function() return saveObj:get(id) end)
    if ok and val ~= nil then
      if entry and entry.values then
        if val == true then return "RELEARN" end
        if val == false then return "OFF" end
      end
      return val
    end
  end

  if entry and entry.values and type(fallback) == "boolean" then
    return fallback and "RELEARN" or "OFF"
  end

  return fallback
end

--- Gets whether a module is currently enabled.
-- @param id string
-- @return boolean
function ModuleManager:isEnabled(id)
  local val = self:getValue(id)
  if val == false or val == nil or val == "OFF" or val == "off" then
    return false
  end
  return true
end

--- Sets a module's value (boolean or multi-state string).
-- Saves per-save if an active save exists; also updates global defaults.
-- @param id string
-- @param value any
function ModuleManager:setValue(id, value)
  local entry = self.modulesById[id]
  if not entry then return false end

  self.globalDefaults[id] = value
  if self.mod and self.mod.options and type(self.mod.options.set) == "function" then
    pcall(function() self.mod.options:set(id, value) end)
  end

  -- Update per-save storage if active
  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.set) == "function" then
    pcall(function() saveObj:set(id, value) end)
  end

  return true
end

--- Sets a module's enabled state (boolean helper).
-- @param id string
-- @param value boolean
function ModuleManager:setEnabled(id, value)
  local entry = self.modulesById[id]
  if entry and entry.values then
    return self:setValue(id, value and "RELEARN" or "OFF")
  else
    return self:setValue(id, value == true)
  end
end

--- Cycles a module's value forward or backward.
-- @param id string
-- @param dir number (1 for forward, -1 for backward)
function ModuleManager:cycle(id, dir)
  local entry = self.modulesById[id]
  if not entry then return end
  dir = dir or 1

  if entry.values then
    local cur = self:getValue(id)
    local curIdx = 1
    for i, v in ipairs(entry.values) do
      if v == cur then
        curIdx = i
        break
      end
    end
    local nextIdx = curIdx + dir
    if nextIdx > #entry.values then
      nextIdx = 1
    elseif nextIdx < 1 then
      nextIdx = #entry.values
    end
    self:setValue(id, entry.values[nextIdx])
  else
    local cur = self:isEnabled(id)
    self:setEnabled(id, not cur)
  end
end

--- Gets all registered module entries.
-- @return table
function ModuleManager:getAll()
  return self.modules
end

--- Gets module entry by ID.
-- @param id string
-- @return table|nil
function ModuleManager:get(id)
  return self.modulesById[id]
end

--- Generates a compact summary string of active modules for the Options Menu row.
-- @return string
function ModuleManager:getSummary()
  local total = #self.modules
  if total == 0 then return "NONE" end

  local enabledCount = 0
  for _, entry in ipairs(self.modules) do
    if self:isEnabled(entry.id) then
      enabledCount = enabledCount + 1
    end
  end

  if enabledCount == total then
    return "ALL ON"
  elseif enabledCount == 0 then
    return "ALL OFF"
  else
    return string.format("%d/%d ON", enabledCount, total)
  end
end

return ModuleManager
