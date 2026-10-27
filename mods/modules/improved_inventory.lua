-- ============================================================================
-- OmniQoL: Improved Inventory Module (Gen 1: Red, Blue, Yellow)
-- Target: Pokemon Gen1Recomp (bryanthaboi/gen1recomp)
--
-- Features:
-- - Expanded Bag Capacity:
--   * Holds up to 99 unique items (expanded from vanilla 20).
--   * Preserves standard 99 item quantity stacks.
--   * Integrates with Gen1Recomp's official constants registry (bagSize).
-- - Expanded PC Item Storage:
--   * Holds up to 99 unique items (expanded from vanilla 50).
--   * Prevents storage bottlenecks when depositing from the 99-item Bag.
--   * Integrates with Gen1Recomp's PC constants (pcItemCap / pcItemSize).
-- - Deterministic Automatic Sorting:
--   * Regular items and Key Items are always sorted alphabetically (A-Z).
--   * TMs and HMs (both TM01/HM01 and TM_<MOVE>/HM_<MOVE>) are grouped at the
--     bottom and sorted numerically: TM01 through TM50, then HM01 through HM05.
--   * CANCEL / Exit options are strictly grouped at the absolute bottom (Group 4).
--   * Directly sorts save.bagOrder and save.pcOrder (Gen1Recomp inventory model).
-- - D-Pad Left / Right Page-Jumping Navigation:
--   * Jump up or down by 5 items per press in Bag and PC menus (BagMenu, ItemMenu, PlayerPC).
--   * Preserves standard SELECT (item swapping) and directional navigation.
-- - Options Menu Integration & Safe Toggle-OFF:
--   * Configurable directly under OPTION -> OMNIQOL ('INVENTORY').
--   * Enabled by default with per-save persistence.
--   * When toggling OFF: automatically deposits excess items (>20) to PC storage.
--   * If PC storage is full and cannot fit all excess items, disabling is safely
--     blocked with user feedback to prevent any item loss.
-- ============================================================================

local ImprovedInventory = {}

-- Constants
ImprovedInventory.VANILLA_BAG_CAPACITY = 20
ImprovedInventory.EXPANDED_BAG_CAPACITY = 99
ImprovedInventory.VANILLA_PC_CAPACITY = 50
ImprovedInventory.EXPANDED_PC_CAPACITY = 99
ImprovedInventory.PAGE_JUMP_SIZE = 5

-- Standard Gen 1 TM and HM numeric ID mappings
-- (In Gen 1 hex: HM01 = 0xC4 (196) .. HM05 = 0xC8 (200), TM01 = 0xC9 (201) .. TM50 = 0xFA (250))
local HM_MIN_ID = 196
local HM_MAX_ID = 200
local TM_MIN_ID = 201
local TM_MAX_ID = 250

-- Gen1Recomp named TM identifiers -> TM numbers (1..50)
local GEN1_TM_NUMBERS = {
  TM_MEGA_PUNCH = 1,
  TM_RAZOR_WIND = 2,
  TM_SWORDS_DANCE = 3,
  TM_WHIRLWIND = 4,
  TM_MEGA_KICK = 5,
  TM_TOXIC = 6,
  TM_HORN_DRILL = 7,
  TM_BODY_SLAM = 8,
  TM_TAKE_DOWN = 9,
  TM_DOUBLE_EDGE = 10,
  TM_BUBBLEBEAM = 11,
  TM_WATER_GUN = 12,
  TM_ICE_BEAM = 13,
  TM_BLIZZARD = 14,
  TM_HYPER_BEAM = 15,
  TM_PAY_DAY = 16,
  TM_SUBMISSION = 17,
  TM_COUNTER = 18,
  TM_SEISMIC_TOSS = 19,
  TM_RAGE = 20,
  TM_MEGA_DRAIN = 21,
  TM_SOLARBEAM = 22,
  TM_DRAGON_RAGE = 23,
  TM_THUNDERBOLT = 24,
  TM_THUNDER = 25,
  TM_EARTHQUAKE = 26,
  TM_FISSURE = 27,
  TM_DIG = 28,
  TM_PSYCHIC_M = 29,
  TM_TELEPORT = 30,
  TM_MIMIC = 31,
  TM_DOUBLE_TEAM = 32,
  TM_REFLECT = 33,
  TM_BIDE = 34,
  TM_METRONOME = 35,
  TM_SELFDESTRUCT = 36,
  TM_EGG_BOMB = 37,
  TM_FIRE_BLAST = 38,
  TM_SWIFT = 39,
  TM_SKULL_BASH = 40,
  TM_SOFTBOILED = 41,
  TM_DREAM_EATER = 42,
  TM_SKY_ATTACK = 43,
  TM_REST = 44,
  TM_THUNDER_WAVE = 45,
  TM_PSYWAVE = 46,
  TM_EXPLOSION = 47,
  TM_ROCK_SLIDE = 48,
  TM_TRI_ATTACK = 49,
  TM_SUBSTITUTE = 50,
}

-- Gen1Recomp named HM identifiers -> HM numbers (1..5)
local GEN1_HM_NUMBERS = {
  HM_CUT = 1,
  HM_FLY = 2,
  HM_SURF = 3,
  HM_STRENGTH = 4,
  HM_FLASH = 5,
}

--- Applies or restores Gen1Recomp constants registry limits (bagSize, pcItemCap).
function ImprovedInventory.applyConstants(mod, enabled)
  if not mod or not mod.content or not mod.content.constants then return end
  if type(mod.content.constants.patch) ~= "function" then return end

  local bagCap = enabled and ImprovedInventory.EXPANDED_BAG_CAPACITY or ImprovedInventory.VANILLA_BAG_CAPACITY
  local pcCap = enabled and ImprovedInventory.EXPANDED_PC_CAPACITY or ImprovedInventory.VANILLA_PC_CAPACITY

  pcall(function() mod.content.constants:patch("bagSize", bagCap) end)
  pcall(function() mod.content.constants:patch("pcItemCap", pcCap) end)
  pcall(function() mod.content.constants:patch("pcItemSize", pcCap) end)
end

--- Extracts a sorting key for any item representation (table, string, or number).
-- Returns { group = 1|2|3|4, index = number, name = string, id = any }
-- Group 1: General Items & Key Items (sorted alphabetically A-Z by display name)
-- Group 2: TMs (sorted numerically 1..50)
-- Group 3: HMs (sorted numerically 1..5)
-- Group 4: CANCEL / Exit options (always placed at the very bottom)
function ImprovedInventory.getItemSortKey(item)
  if not item then
    return { group = 1, index = 0, name = "", id = "" }
  end

  local rawId = type(item) == "table" and (item.value or item.id or item.itemId or item.item or item.name or item[1]) or item
  local rawName = type(item) == "table" and (item.label or item.name or item.displayName) or nil
  local idStr = tostring(rawId or ""):upper():gsub("^ITEM_", "")
  local nameStr = tostring(rawName or ""):upper()

  -- 0. Check for CANCEL / Exit menu entries (Group 4: Must remain at the absolute bottom)
  if item == "CANCEL" or item == "CANCEL_MENU" or item == "EXIT" or item == "QUIT" or item == 0xFF or item == 255 then
    return {
      group = 4,
      index = 0,
      name = "CANCEL",
      id = "CANCEL",
    }
  end

  if rawId == "CANCEL" or rawId == "CANCEL_MENU" or rawId == "EXIT" or rawId == "QUIT" or rawId == 0xFF or rawId == 255 then
    return {
      group = 4,
      index = 0,
      name = "CANCEL",
      id = rawId,
    }
  end

  if idStr == "CANCEL" or idStr == "CANCEL_MENU" or idStr == "EXIT" or idStr == "QUIT" then
    return {
      group = 4,
      index = 0,
      name = "CANCEL",
      id = rawId,
    }
  end

  if type(item) == "table" and (item.cancel or item.isCancel or item.isExit) then
    return {
      group = 4,
      index = 0,
      name = "CANCEL",
      id = rawId,
    }
  end

  if rawName and nameStr:gsub("[^%w]", "") == "CANCEL" then
    return {
      group = 4,
      index = 0,
      name = "CANCEL",
      id = rawId,
    }
  end

  -- 1. Check for TM / HM by machine table metadata (e.g. { machine = { kind = "TM", number = 28 } })
  if type(item) == "table" and item.machine then
    if item.machine.kind == "TM" then
      return {
        group = 2,
        index = tonumber(item.machine.number) or 0,
        name = rawName or idStr,
        id = rawId,
      }
    elseif item.machine.kind == "HM" then
      return {
        group = 3,
        index = tonumber(item.machine.number) or 0,
        name = rawName or idStr,
        id = rawId,
      }
    end
  end

  -- 2. Check for TM / HM by Gen1Recomp named move keys (e.g. 'TM_DIG', 'TM_MEGA_PUNCH', 'HM_CUT')
  local namedTmNum = GEN1_TM_NUMBERS[rawId] or GEN1_TM_NUMBERS[idStr] or GEN1_TM_NUMBERS["TM_" .. idStr]
  if namedTmNum then
    return {
      group = 2,
      index = namedTmNum,
      name = rawName or idStr,
      id = rawId,
    }
  end

  local namedHmNum = GEN1_HM_NUMBERS[rawId] or GEN1_HM_NUMBERS[idStr] or GEN1_HM_NUMBERS["HM_" .. idStr]
  if namedHmNum then
    return {
      group = 3,
      index = namedHmNum,
      name = rawName or idStr,
      id = rawId,
    }
  end

  -- 3. Check for TM by string ID or label (e.g., 'TM01', 'TM_01', 'TM 01', 'TM-01', 'TM28 DIG', 'TM 28 DIG')
  local tmNum = idStr:match("^TM[%s_%-]?(%d+)") or nameStr:match("^TM[%s_%-]?(%d+)")
  if tmNum then
    return {
      group = 2,
      index = tonumber(tmNum) or 0,
      name = rawName or idStr,
      id = rawId,
    }
  end

  -- 4. Check for HM by string ID or label (e.g., 'HM01', 'HM_01', 'HM 01', 'HM-01', 'HM01 CUT')
  local hmNum = idStr:match("^HM[%s_%-]?(%d+)") or nameStr:match("^HM[%s_%-]?(%d+)")
  if hmNum then
    return {
      group = 3,
      index = tonumber(hmNum) or 0,
      name = rawName or idStr,
      id = rawId,
    }
  end

  -- 5. Check for TM or HM by numeric ID (standard Gen 1 RAM values: 196..200 for HM, 201..250 for TM)
  if type(rawId) == "number" then
    if rawId >= TM_MIN_ID and rawId <= TM_MAX_ID then
      return {
        group = 2,
        index = rawId - TM_MIN_ID + 1,
        name = rawName or string.format("TM%02d", rawId - TM_MIN_ID + 1),
        id = rawId,
      }
    elseif rawId >= HM_MIN_ID and rawId <= HM_MAX_ID then
      return {
        group = 3,
        index = rawId - HM_MIN_ID + 1,
        name = rawName or string.format("HM%02d", rawId - HM_MIN_ID + 1),
        id = rawId,
      }
    end
  end

  -- 6. Regular item or Key Item (Group 1: Alphabetical by cleaned display name)
  local displayName = rawName
  if not displayName or #displayName == 0 then
    if type(rawId) == "string" then
      displayName = rawId:gsub("^ITEM_", ""):gsub("_", " ")
    else
      displayName = tostring(rawId)
    end
  end

  -- Normalize name: uppercase, trim leading/trailing whitespace
  local normName = displayName:upper():gsub("^%s+", ""):gsub("%s+$", "")

  return {
    group = 1,
    index = 0,
    name = normName,
    id = rawId,
  }
end

--- Comparator function for sorting two items according to the specification.
-- Group 1 (Items A-Z) < Group 2 (TMs 1..50) < Group 3 (HMs 1..5) < Group 4 (CANCEL)
function ImprovedInventory.compareItems(a, b)
  local keyA = ImprovedInventory.getItemSortKey(a)
  local keyB = ImprovedInventory.getItemSortKey(b)

  -- Compare group (Group 1 < Group 2 < Group 3 < Group 4)
  if keyA.group ~= keyB.group then
    return keyA.group < keyB.group
  end

  -- Group 1: Compare display name alphabetically (A-Z)
  if keyA.group == 1 then
    if keyA.name ~= keyB.name then
      return keyA.name < keyB.name
    end
    return tostring(keyA.id) < tostring(keyB.id)
  end

  -- Groups 2 & 3: Compare TM / HM numeric index (e.g. TM01 < TM02)
  if keyA.group == 2 or keyA.group == 3 then
    if keyA.index ~= keyB.index then
      return keyA.index < keyB.index
    end
    return tostring(keyA.id) < tostring(keyB.id)
  end

  -- Group 4: CANCEL entries (stable comparison)
  return tostring(keyA.id) < tostring(keyB.id)
end

--- Returns whether a list is already sorted according to the compareItems contract.
function ImprovedInventory.isListSorted(items)
  if type(items) ~= "table" or #items <= 1 then
    return true
  end
  for i = 1, #items - 1 do
    if ImprovedInventory.compareItems(items[i + 1], items[i]) then
      return false
    end
  end
  return true
end

--- Sorts a list of items in-place according to the alphabetical + TM numerical order.
-- @param items Table (array of item objects or item IDs)
-- @return Table The sorted items array
function ImprovedInventory.sortItems(items)
  if type(items) ~= "table" or #items <= 1 then
    return items
  end
  if not ImprovedInventory.isListSorted(items) then
    table.sort(items, ImprovedInventory.compareItems)
  end
  return items
end

--- Enforces sorting across all inventory collections in a save object.
-- Specifically targets save.bagOrder and save.pcOrder (the Gen1Recomp native model).
function ImprovedInventory.enforceSortingOnSave(save)
  if not save or type(save) ~= "table" then return end

  -- 1. Gen1Recomp native model: save.bagOrder and save.pcOrder
  if type(save.bagOrder) == "table" and #save.bagOrder > 1 then
    ImprovedInventory.sortItems(save.bagOrder)
  end

  if type(save.pcOrder) == "table" and #save.pcOrder > 1 then
    ImprovedInventory.sortItems(save.pcOrder)
  end

  -- 2. Fallback / alternative object models
  if type(save.bag) == "table" and type(save.bag.items) == "table" and #save.bag.items > 1 then
    ImprovedInventory.sortItems(save.bag.items)
  end

  if type(save.pcItems) == "table" and #save.pcItems > 1 then
    ImprovedInventory.sortItems(save.pcItems)
  end
end

--- Determines if a ListMenu items array corresponds strictly to the player's Bag or PC item storage.
-- Explicitly excludes non-inventory menus like Mart buy stock, PC box Pokémon lists, elevator floors, etc.
-- @param title string|nil Menu title
-- @param items table Array of list items
-- @param opts table|nil ListMenu constructor options
-- @return boolean
function ImprovedInventory.isPlayerInventoryList(title, items, opts)
  opts = opts or {}
  local kind = opts.kind

  -- 1. Explicit player inventory kinds
  if kind == "bag" or kind == "pc" then
    return true
  end
  if type(kind) == "string" and kind:find("^pc_item_") ~= nil then
    -- pc_item_withdraw, pc_item_deposit, pc_item_toss
    return true
  end

  -- 2. Explicit exclusions (never sort non-inventory lists)
  if type(kind) == "string" then
    if kind:find("^pc_box_") ~= nil
        or kind == "elevator_floors"
        or kind == "badge_descriptions"
        or kind == "pokedex"
        or kind == "moves"
        or kind == "controls" then
      return false
    end
  end

  -- 3. Exclude ShopMenu Buy stock (clerk dialogue + money callback)
  if opts.dialogue and opts.money and not opts.onSelectKey then
    return false
  end

  -- 4. Exclude BattleState tutorial / scripted menus
  if opts.script then
    return false
  end

  -- 5. Fallback check for title == "ITEMS" when not in a dialogue/shop flow
  if title and (title == "ITEMS" or tostring(title):find("^ITEMS")) and not opts.dialogue then
    return true
  end

  return false
end

--- Calculates target cursor position after a page-jump navigation step.
-- @param currentIndex number (1-based current cursor index)
-- @param maxIndex number (total selectable items or max selectable row)
-- @param direction number (-1 for Page Up / Left, 1 for Page Down / Right)
-- @param jumpSize number (default 5 items)
-- @return number newIndex clamped within [1, maxIndex]
function ImprovedInventory.handlePageJump(currentIndex, maxIndex, direction, jumpSize)
  currentIndex = currentIndex or 1
  maxIndex = maxIndex or 1
  jumpSize = jumpSize or ImprovedInventory.PAGE_JUMP_SIZE
  direction = (direction and direction < 0) and -1 or 1

  if maxIndex <= 1 then return 1 end

  local target = currentIndex + (direction * jumpSize)
  if target < 1 then
    target = 1
  elseif target > maxIndex then
    target = maxIndex
  end
  return target
end

--- Checks if the player's Bag and PC can safely transition when disabling Improved Inventory.
-- Returns canDisable (boolean), reason (string or nil), excessItems (table or nil)
function ImprovedInventory.canSafelyDisable(mod, moduleManager, save)
  save = save or (mod and mod.save) or {}

  -- Count bag items from save.bagOrder (Gen1Recomp) or save.bag.items / save.inventory
  local realBagItems = {}

  if type(save.bagOrder) == "table" then
    for _, it in ipairs(save.bagOrder) do
      local key = ImprovedInventory.getItemSortKey(it)
      if key.group ~= 4 then
        table.insert(realBagItems, it)
      end
    end
  else
    local bag = save.bag or save.inventory or (mod and mod.bag)
    local bagItems = (type(bag) == "table" and (bag.items or bag)) or {}
    if type(bagItems) ~= "table" then bagItems = {} end
    for _, it in ipairs(bagItems) do
      local key = ImprovedInventory.getItemSortKey(it)
      if key.group ~= 4 then
        table.insert(realBagItems, it)
      end
    end
  end

  local totalBagItems = #realBagItems
  if totalBagItems <= ImprovedInventory.VANILLA_BAG_CAPACITY then
    return true, nil, {}
  end

  local excessCount = totalBagItems - ImprovedInventory.VANILLA_BAG_CAPACITY
  local excessList = {}
  for i = ImprovedInventory.VANILLA_BAG_CAPACITY + 1, totalBagItems do
    table.insert(excessList, realBagItems[i])
  end

  -- Calculate available PC storage
  local currentPCItems = 0
  if type(save.pcOrder) == "table" then
    for _, it in ipairs(save.pcOrder) do
      local key = ImprovedInventory.getItemSortKey(it)
      if key.group ~= 4 then
        currentPCItems = currentPCItems + 1
      end
    end
  else
    local pc = save.pcItems or save.boxItems or save.storage or (mod and mod.pcItems)
    local pcItems = (type(pc) == "table" and (pc.items or pc)) or {}
    if type(pcItems) ~= "table" then pcItems = {} end
    for _, it in ipairs(pcItems) do
      local key = ImprovedInventory.getItemSortKey(it)
      if key.group ~= 4 then
        currentPCItems = currentPCItems + 1
      end
    end
  end

  local availablePCSpace = ImprovedInventory.VANILLA_PC_CAPACITY - currentPCItems
  if excessCount > availablePCSpace then
    local errMsg = string.format("Cannot disable: PC needs %d free slots for excess items (has %d).", excessCount, math.max(0, availablePCSpace))
    return false, errMsg, nil
  end

  return true, nil, excessList
end

--- Automatically deposits excess bag items (>20) into PC storage and truncates bag to 20.
-- @param save Table save state
-- @return boolean success, string or nil error
function ImprovedInventory.autoDepositExcessToPC(save)
  if not save then return true end

  local canDisable, err, excessList = ImprovedInventory.canSafelyDisable(nil, nil, save)
  if not canDisable then
    return false, err
  end

  -- 1. Gen1Recomp native model: save.bagOrder, save.inventory, save.pcOrder, save.pcItems
  if type(save.bagOrder) == "table" then
    save.pcOrder = save.pcOrder or {}
    save.pcItems = save.pcItems or {}
    local inv = save.inventory or {}

    for _, itemId in ipairs(excessList) do
      local qty = inv[itemId] or 1
      table.insert(save.pcOrder, itemId)
      save.pcItems[itemId] = (save.pcItems[itemId] or 0) + qty
      inv[itemId] = nil

      -- Remove from bagOrder
      for i = #save.bagOrder, 1, -1 do
        if save.bagOrder[i] == itemId then
          table.remove(save.bagOrder, i)
          break
        end
      end
    end

    ImprovedInventory.enforceSortingOnSave(save)
    return true
  end

  -- 2. Fallback object model: save.bag / save.pcItems
  local bag = save.bag or save.inventory
  local bagItems = type(bag) == "table" and (bag.items or bag)
  if type(bagItems) == "table" then
    local pc = save.pcItems or save.boxItems or save.storage
    if type(pc) ~= "table" then
      save.pcItems = {}
      pc = save.pcItems
    end
    local pcItems = pc.items or pc

    for _, item in ipairs(excessList) do
      table.insert(pcItems, item)
      for i = #bagItems, 1, -1 do
        if bagItems[i] == item then
          table.remove(bagItems, i)
          break
        end
      end
    end

    if bag.count then bag.count = #bagItems end
    if pc.count then pc.count = #pcItems end
  end

  return true
end

--- Registers the Improved Inventory module with ModuleManager.
function ImprovedInventory.register(moduleManager)
  moduleManager:register({
    id = "improved_inventory",
    label = "INVENTORY",
    desc = "99 items, page jump & auto-sort.",
    default = true,
    supportedGenerations = { "gen1" },
    beforeChange = function(mod, mgr, nextVal)
      local willBeEnabled = (nextVal == true or (nextVal ~= false and nextVal ~= "OFF" and nextVal ~= "off"))
      if not willBeEnabled then
        local save = (mod and mod.save) or {}
        local ok, err = ImprovedInventory.canSafelyDisable(mod, mgr, save)
        if not ok then
          return false, err
        end
        local depositOk, depositErr = ImprovedInventory.autoDepositExcessToPC(save)
        if not depositOk then
          return false, depositErr
        end
      end
      return true
    end,
    onChange = function(mod, mgr, newVal)
      local isEnabled = (newVal == true or (newVal ~= false and newVal ~= "OFF" and newVal ~= "off"))
      ImprovedInventory.applyConstants(mod, isEnabled)
      if isEnabled and mod and mod.save then
        ImprovedInventory.enforceSortingOnSave(mod.save)
      end
    end,
    init = function(mod, mgr)
      ImprovedInventory.initHooks(mod, mgr)
    end,
  })
end

--- Returns the active maximum bag capacity based on module state.
function ImprovedInventory.getBagCapacity(moduleManager, game)
  if moduleManager and moduleManager:isEnabled("improved_inventory", game) then
    return ImprovedInventory.EXPANDED_BAG_CAPACITY
  end
  return ImprovedInventory.VANILLA_BAG_CAPACITY
end

--- Returns the active maximum PC storage capacity based on module state.
function ImprovedInventory.getPCCapacity(moduleManager, game)
  if moduleManager and moduleManager:isEnabled("improved_inventory", game) then
    return ImprovedInventory.EXPANDED_PC_CAPACITY
  end
  return ImprovedInventory.VANILLA_PC_CAPACITY
end

--- Initializes all engine hooks, inventory hooks, and menu navigation wrappers.
function ImprovedInventory.initHooks(mod, moduleManager)
  -- Apply initial Gen1Recomp constants patch
  ImprovedInventory.applyConstants(mod, moduleManager:isEnabled("improved_inventory"))

  -- 1. Hook engine capacity & lifecycle checks via mod.hooks
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    -- Per-frame / input step hook: ensure save.bagOrder and save.pcOrder stay sorted
    mod.hooks:wrap("input.step", function(next, game, dt)
      if game and game.save and moduleManager:isEnabled("improved_inventory", game) then
        ImprovedInventory.enforceSortingOnSave(game.save)
      end
      return next and next(game, dt)
    end)

    -- Overworld map load hook: ensure save is sorted upon entering maps
    mod.hooks:wrap("overworld.load_map", function(next, game, ...)
      if game and game.save and moduleManager:isEnabled("improved_inventory", game) then
        ImprovedInventory.enforceSortingOnSave(game.save)
      end
      return next and next(game, ...)
    end)

    -- Start Menu hook: ensure items are sorted before the player clicks ITEM
    mod.hooks:wrap("ui.start_menu.items", function(next, game, items, ...)
      if game and game.save and moduleManager:isEnabled("improved_inventory", game) then
        ImprovedInventory.enforceSortingOnSave(game.save)
      end
      return next and next(game, items, ...)
    end)

    -- ListMenu hook: enable pageJump navigation strictly for bag and PC item lists
    mod.hooks:wrap("ui.list_menu", function(next, opts, meta, ...)
      local res = next and next(opts, meta, ...) or opts or {}
      if moduleManager:isEnabled("improved_inventory") then
        local kind = (meta and meta.kind) or (opts and opts.kind)
        if kind == "bag" or (type(kind) == "string" and kind:find("^pc_item_") ~= nil) then
          res.pageJump = true
        end
      end
      return res
    end)

    -- Bag capacity hooks
    mod.hooks:wrap("bag.capacity", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_BAG_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_BAG_CAPACITY
    end)

    mod.hooks:wrap("inventory.capacity", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_BAG_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_BAG_CAPACITY
    end)

    mod.hooks:wrap("bag.max_items", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_BAG_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_BAG_CAPACITY
    end)

    mod.hooks:wrap("inventory.max_items", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_BAG_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_BAG_CAPACITY
    end)

    -- PC Storage capacity hooks
    mod.hooks:wrap("pc_items.capacity", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_PC_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_PC_CAPACITY
    end)

    mod.hooks:wrap("pc_items.max_items", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_PC_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_PC_CAPACITY
    end)

    mod.hooks:wrap("box_items.max_items", function(next, game, ...)
      if moduleManager:isEnabled("improved_inventory", game) then
        return ImprovedInventory.EXPANDED_PC_CAPACITY
      end
      return next and next(game, ...) or ImprovedInventory.VANILLA_PC_CAPACITY
    end)

    -- Can Add hooks
    mod.hooks:wrap("bag.can_add", function(next, bagOrGame, item, count, ...)
      if moduleManager:isEnabled("improved_inventory") then
        local items = type(bagOrGame) == "table" and (bagOrGame.items or bagOrGame.bagOrder or bagOrGame) or {}
        if type(items) == "table" then
          for _, it in ipairs(items) do
            local itId = type(it) == "table" and (it.id or it[1]) or it
            local targetId = type(item) == "table" and (item.id or item[1]) or item
            if itId == targetId then
              local itQty = type(it) == "table" and (it.count or it.quantity or it[2]) or 1
              if itQty + (count or 1) <= 99 then
                return true
              end
            end
          end
          return #items < ImprovedInventory.EXPANDED_BAG_CAPACITY
        end
        return true
      end
      return next and next(bagOrGame, item, count, ...)
    end)

    -- Bag & PC open / add hooks to enforce sorting
    mod.hooks:wrap("bag.open", function(next, game, bag, ...)
      local save = (game and game.save) or (bag and bag.save) or (mod and mod.save)
      if moduleManager:isEnabled("improved_inventory", game) then
        ImprovedInventory.enforceSortingOnSave(save)
        if bag then
          local items = bag.items or bag.bagOrder or bag
          if type(items) == "table" then
            ImprovedInventory.sortItems(items)
          end
        end
      end
      return next and next(game, bag, ...)
    end)

    mod.hooks:wrap("pc_items.open", function(next, game, pc, ...)
      local save = (game and game.save) or (pc and pc.save) or (mod and mod.save)
      if moduleManager:isEnabled("improved_inventory", game) then
        ImprovedInventory.enforceSortingOnSave(save)
        if pc then
          local items = pc.items or pc.pcOrder or pc
          if type(items) == "table" then
            ImprovedInventory.sortItems(items)
          end
        end
      end
      return next and next(game, pc, ...)
    end)

    mod.hooks:wrap("bag.add", function(next, bag, item, count, ...)
      local res = next and next(bag, item, count, ...)
      local save = (bag and bag.save) or (mod and mod.save)
      if moduleManager:isEnabled("improved_inventory") then
        ImprovedInventory.enforceSortingOnSave(save)
        if bag then
          local items = bag.items or bag.bagOrder or bag
          if type(items) == "table" then
            ImprovedInventory.sortItems(items)
          end
        end
      end
      return res
    end)
  end

  -- 2. Hook and wrap engine Inventory & Bag classes if present
  local okBag, BagClass = pcall(require, "src.inventory.Bag")
  if okBag and BagClass then
    if BagClass.MAX_ITEMS then
      BagClass.MAX_ITEMS = ImprovedInventory.EXPANDED_BAG_CAPACITY
    end
    if type(BagClass.getMaxItems) == "function" then
      local origGetMax = BagClass.getMaxItems
      BagClass.getMaxItems = function(self, ...)
        if moduleManager:isEnabled("improved_inventory") then
          return ImprovedInventory.EXPANDED_BAG_CAPACITY
        end
        return origGetMax(self, ...)
      end
    end
    if type(BagClass.order) == "function" then
      local origOrder = BagClass.order
      BagClass.order = function(save, data, ...)
        local order = origOrder(save, data, ...)
        if moduleManager:isEnabled("improved_inventory") and type(order) == "table" and #order > 1 then
          ImprovedInventory.sortItems(order)
        end
        return order
      end
    end
    if type(BagClass.pcOrder) == "function" then
      local origPCOrder = BagClass.pcOrder
      BagClass.pcOrder = function(save, data, ...)
        local order = origPCOrder(save, data, ...)
        if moduleManager:isEnabled("improved_inventory") and type(order) == "table" and #order > 1 then
          ImprovedInventory.sortItems(order)
        end
        return order
      end
    end
  end

  local okPC, PCClass = pcall(require, "src.inventory.PCItems")
  if okPC and PCClass then
    if PCClass.MAX_ITEMS then
      PCClass.MAX_ITEMS = ImprovedInventory.EXPANDED_PC_CAPACITY
    end
  end

  -- Hook ListMenu.new to ensure only player bag and PC item lists are sorted upon construction
  local okList, ListMenu = pcall(require, "src.ui.ListMenu")
  if okList and ListMenu and type(ListMenu.new) == "function" then
    local origListNew = ListMenu.new
    ListMenu.new = function(game, title, items, opts)
      if moduleManager:isEnabled("improved_inventory", game) then
        if type(items) == "table" and #items > 1 and ImprovedInventory.isPlayerInventoryList(title, items, opts) then
          ImprovedInventory.sortItems(items)
        end
      end
      return origListNew(game, title, items, opts)
    end
  end

  -- 3. Hook BagMenu and PlayerPC UI to enforce sorted save data on open
  local function wrapMenu(MenuClass)
    if not MenuClass then return end

    -- Hook instantiation / initialization to ensure save collections are sorted
    if type(MenuClass.new) == "function" then
      local origNew = MenuClass.new
      MenuClass.new = function(game, ...)
        if game and game.save and moduleManager:isEnabled("improved_inventory", game) then
          ImprovedInventory.enforceSortingOnSave(game.save)
        end
        local instance = origNew(game, ...)
        if instance and moduleManager:isEnabled("improved_inventory") then
          local save = (instance.game and instance.game.save) or (game and game.save) or (mod and mod.save)
          ImprovedInventory.enforceSortingOnSave(save)
        end
        return instance
      end
    end

    if type(MenuClass.init) == "function" then
      local origInit = MenuClass.init
      MenuClass.init = function(self, ...)
        local res = origInit(self, ...)
        if moduleManager:isEnabled("improved_inventory") then
          local save = (self.game and self.game.save) or (mod and mod.save)
          ImprovedInventory.enforceSortingOnSave(save)
        end
        return res
      end
    end
  end

  local okBagUI, BagMenu = pcall(require, "src.ui.BagMenu")
  if okBagUI and BagMenu then
    wrapMenu(BagMenu)
  end

  local okItemUI, ItemMenu = pcall(require, "src.ui.ItemMenu")
  if okItemUI and ItemMenu then
    wrapMenu(ItemMenu)
  end

  local okPCUI, PCItemMenu = pcall(require, "src.ui.PCItemMenu")
  if okPCUI and PCItemMenu then
    wrapMenu(PCItemMenu)
  end

  local okPlayerPC, PlayerPC = pcall(require, "src.ui.PlayerPC")
  if okPlayerPC and PlayerPC then
    if PlayerPC.pcItemCap then
      PlayerPC.pcItemCap = ImprovedInventory.EXPANDED_PC_CAPACITY
    end
    wrapMenu(PlayerPC)
  end
end

return ImprovedInventory
