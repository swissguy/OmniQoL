-- ============================================================================
-- OmniQoL: Core Module Manager (Generation 1: Red, Blue, Yellow)
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
    values = def.values,
    init = def.init,
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

  if entry.values and #entry.values > 0 then
    local cur = tostring(self:getValue(id)):upper()
    local curIdx = 1
    for idx, v in ipairs(entry.values) do
      if v:upper() == cur then
        curIdx = idx
        break
      end
    end
    local nextIdx = curIdx + dir
    if nextIdx > #entry.values then nextIdx = 1 end
    if nextIdx < 1 then nextIdx = #entry.values end
    local nextVal = entry.values[nextIdx]
    self:setValue(id, nextVal)
    return nextVal
  else
    local cur = self:isEnabled(id)
    local nxt = not cur
    self:setEnabled(id, nxt)
    return nxt
  end
end

--- Toggles a module's state (calls cycle forward).
-- @param id string
-- @return any The new state
function ModuleManager:toggle(id)
  return self:cycle(id, 1)
end

--- Gets a formatted display badge for the Options menu row.
-- @param id string
-- @return string e.g. "[ON ]", "[OFF]", "[RELEARN]", "[REL+TMS]"
function ModuleManager:getDisplayStatus(id)
  local entry = self.modulesById[id]
  if entry and entry.values then
    local val = tostring(self:getValue(id)):upper()
    if val == "OFF" then
      return "[OFF]"
    elseif val == "RELEARN" then
      return "[RELEARN]"
    elseif val == "RELEARN+TMS" or val == "RELEARN+TM" then
      return "[REL+TMS]"
    else
      return "[" .. val:sub(1, 7) .. "]"
    end
  else
    return self:isEnabled(id) and "[ON ]" or "[OFF]"
  end
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
