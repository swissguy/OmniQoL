-- ============================================================================
-- OmniQoL: Core Module Manager (Pokémon Yellow)
-- Handles registration, state lookup, per-save persistence, and global defaults.
-- ============================================================================

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(mod)
  local self = setmetatable({}, ModuleManager)
  self.mod = mod
  self.modules = {}          -- list for ordered iteration
  self.modulesById = {}      -- map for quick lookup
  self.globalDefaults = {}   -- fallback storage for Title Screen / New Game
  return self
end

--- Registers a new QoL module.
-- @param def Table containing module metadata and lifecycle hooks
function ModuleManager:register(def)
  assert(def and def.id, "Module definition must have an 'id'")
  assert(def.label, "Module definition must have a 'label'")
  if def.default == nil then def.default = true end

  local modEntry = {
    id = def.id,
    label = def.label,
    desc = def.desc or "",
    default = def.default,
    init = def.init,
  }

  table.insert(self.modules, modEntry)
  self.modulesById[def.id] = modEntry
  self.globalDefaults[def.id] = def.default

  -- Read persistent global option if mod.options is active
  if self.mod and self.mod.options and type(self.mod.options.get) == "function" then
    local ok, optVal = pcall(function() return self.mod.options:get(def.id) end)
    if ok and optVal ~= nil then
      self.globalDefaults[def.id] = (optVal == true)
    end
  end

  if type(def.init) == "function" then
    local ok, err = pcall(def.init, self.mod, self)
    if not ok then
      if self.mod.log and self.mod.log.error then
        self.mod.log:error("Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      else
        print("[OmniQoL Yellow] Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      end
    end
  end

  return modEntry
end

--- Gets whether a module is currently enabled.
-- Checks per-save storage first; falls back to global defaults / initial default.
-- @param id string
-- @return boolean
function ModuleManager:isEnabled(id)
  local entry = self.modulesById[id]
  local fallback = self.globalDefaults[id]
  if fallback == nil then
    fallback = entry and entry.default or false
  end

  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.get) == "function" then
    local ok, val = pcall(function() return saveObj:get(id) end)
    if ok and val ~= nil then
      return val == true
    end
  end

  return fallback
end

--- Sets a module's enabled state.
-- Saves per-save if an active save exists; also updates global defaults.
-- @param id string
-- @param value boolean
function ModuleManager:setEnabled(id, value)
  local entry = self.modulesById[id]
  if not entry then return false end
  local boolVal = (value == true)

  -- Always update global defaults (used for Title Screen / new saves)
  self.globalDefaults[id] = boolVal
  if self.mod and self.mod.options and type(self.mod.options.set) == "function" then
    pcall(function() self.mod.options:set(id, boolVal) end)
  end

  -- Update per-save storage if active
  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.set) == "function" then
    pcall(function() saveObj:set(id, boolVal) end)
  end

  return true
end

--- Toggles a module's enabled state.
-- @param id string
-- @return boolean The new state
function ModuleManager:toggle(id)
  local current = self:isEnabled(id)
  local newState = not current
  self:setEnabled(id, newState)
  return newState
end

--- Returns a concise summary string for display in the Options menu row.
-- e.g. "RUNNING: ON" or "1 ACTIVE"
-- @return string
function ModuleManager:getSummary()
  local activeCount = 0
  local total = #self.modules

  for _, modDef in ipairs(self.modules) do
    if self:isEnabled(modDef.id) then
      activeCount = activeCount + 1
    end
  end

  if total == 1 then
    local onlyMod = self.modules[1]
    local enabled = self:isEnabled(onlyMod.id)
    return string.format("%s: %s", onlyMod.label, enabled and "ON" or "OFF")
  elseif activeCount == 0 then
    return "ALL OFF"
  elseif activeCount == total then
    return "ALL ACTIVE"
  else
    return string.format("%d ACTIVE", activeCount)
  end
end

--- Returns the list of all registered modules.
-- @return table
function ModuleManager:getAll()
  return self.modules
end

--- Returns a specific module definition by ID.
-- @param id string
-- @return table|nil
function ModuleManager:get(id)
  return self.modulesById[id]
end

return ModuleManager
