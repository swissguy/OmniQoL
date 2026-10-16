-- ============================================================================
-- G1R Deluxe: Core Module Manager
-- Handles registration, state lookup, and per-save persistence for QoL modules.
-- ============================================================================

local ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager.new(mod)
  local self = setmetatable({}, ModuleManager)
  self.mod = mod
  self.modules = {}      -- list for ordered iteration
  self.modulesById = {}  -- map for quick lookup
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

  if type(def.init) == "function" then
    local ok, err = pcall(def.init, self.mod, self)
    if not ok then
      if self.mod.log and self.mod.log.error then
        self.mod.log:error("Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      else
        print("[G1R Deluxe] Failed to initialize module '" .. def.id .. "': " .. tostring(err))
      end
    end
  end

  return modEntry
end

--- Gets whether a module is currently enabled.
-- Checks per-save storage first; falls back to the module's default value.
-- @param id string
-- @return boolean
function ModuleManager:isEnabled(id)
  local entry = self.modulesById[id]
  local defaultVal = entry and entry.default or false

  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.get) == "function" then
    local ok, val = pcall(function() return saveObj:get(id) end)
    if ok and val ~= nil then
      return val == true
    end
  end

  return defaultVal
end

--- Sets a module's enabled state in per-save storage.
-- @param id string
-- @param value boolean
function ModuleManager:setEnabled(id, value)
  local entry = self.modulesById[id]
  if not entry then return false end

  local saveObj = self.mod and self.mod.save
  if saveObj and type(saveObj.set) == "function" then
    pcall(function() saveObj:set(id, value == true) end)
    return true
  end

  return false
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
