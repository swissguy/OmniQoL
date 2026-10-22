-- ============================================================================
-- OmniQoL: Options Menu & Settings Screen Integration (Gen 1 & Gen 2)
-- Injects 'OMNIQOL' entry into the native Options Menu (accessible both
-- during gameplay and on the Title Screen), while leaving the top-level
-- overworld Start Menu clean and vanilla.
-- ============================================================================

local SettingsMenu = {}

function SettingsMenu.setup(mod, moduleManager)
  -- 1. Register fallback engine options if mod.options API exists
  if mod.options and type(mod.options.define) == "function" then
    local optionDefs = {}
    for _, modEntry in ipairs(moduleManager:getAll()) do
      table.insert(optionDefs, {
        key = modEntry.id,
        label = modEntry.label,
        type = "toggle",
        default = modEntry.default,
      })
    end
    pcall(function() mod.options:define(optionDefs) end)
  end

  -- 2. Register custom UI screen for module configuration
  local screenId = "G1RDeluxeSettings"
  if mod.content and mod.content.screens and type(mod.content.screens.register) == "function" then
    mod.content.screens:register(screenId, {
      new = function(game)
        local Font = mod.ui and mod.ui.Font
        local selectedIndex = 1
        local scrollOffset = 0
        local maxVisible = 5
        local state = { isOpaque = true }

        function state:update()
          local modules = moduleManager:getAll(game)
          local total = #modules
          if total == 0 then
            if game.input and game.input:wasPressed("b") then
              game.stack:pop()
            end
            return
          end

          if game.input then
            if game.input:wasPressed("up") then
              selectedIndex = selectedIndex - 1
              if selectedIndex < 1 then
                selectedIndex = total
                scrollOffset = math.max(0, total - maxVisible)
              elseif selectedIndex <= scrollOffset then
                scrollOffset = selectedIndex - 1
              end
            elseif game.input:wasPressed("down") then
              selectedIndex = selectedIndex + 1
              if selectedIndex > total then
                selectedIndex = 1
                scrollOffset = 0
              elseif selectedIndex > scrollOffset + maxVisible then
                scrollOffset = selectedIndex - maxVisible
              end
            elseif game.input:wasPressed("left") then
              local targetMod = modules[selectedIndex]
              if targetMod then
                moduleManager:cycle(targetMod.id, -1)
              end
            elseif game.input:wasPressed("right") or game.input:wasPressed("a") then
              local targetMod = modules[selectedIndex]
              if targetMod then
                moduleManager:cycle(targetMod.id, 1)
              end
            elseif game.input:wasPressed("b") then
              game.stack:pop()
            end
          end
        end

        local function wrapDesc(text, maxLen)
          maxLen = maxLen or 16
          if not text or #text == 0 then return "", "" end
          if #text <= maxLen then return text, "" end

          local splitIdx = maxLen
          while splitIdx > 0 and text:sub(splitIdx, splitIdx) ~= " " do
            splitIdx = splitIdx - 1
          end
          if splitIdx == 0 then splitIdx = maxLen end
          local l1 = text:sub(1, splitIdx):gsub("%s+$", "")
          local remainder = text:sub(splitIdx + 1):gsub("^%s+", "")

          if #remainder <= maxLen then
            return l1, remainder
          end

          local split2 = maxLen
          while split2 > 0 and remainder:sub(split2, split2) ~= " " do
            split2 = split2 - 1
          end
          if split2 == 0 then split2 = maxLen end
          local l2 = remainder:sub(1, split2):gsub("%s+$", "")
          return l1, l2
        end

        function state:draw()
          local modules = moduleManager:getAll(game)
          if not Font or type(Font.drawBox) ~= "function" then
            return
          end

          local total = #modules

          -- Main module list box: 20 columns x 11 rows (y: 0 to 88)
          Font.drawBox(0, 0, 20, 11)
          Font.draw("OMNIQOL MODS", 16, 10)
          Font.draw("================", 16, 18)

          -- List modules within scroll window
          local startY = 26
          local stepY = 11
          for slot = 1, maxVisible do
            local i = scrollOffset + slot
            if i <= total then
              local modDef = modules[i]
              local yPos = startY + (slot - 1) * stepY

              if i == selectedIndex then
                Font.draw(">", 10, yPos)
              end

              Font.draw(modDef.label, 18, yPos)

              local rawVal = moduleManager:getValue(modDef.id)
              local valStr = (rawVal == true and "ON") or (rawVal == false and "OFF") or tostring(rawVal or "OFF")
              local valX = 150 - (#valStr * 8)
              Font.draw(valStr, valX, yPos)
            end
          end

          -- Description box: 20 columns x 5 rows (y: 88 to 128)
          Font.drawBox(0, 11, 20, 5)
          local curMod = modules[selectedIndex]
          if curMod then
            local descLine1, descLine2 = wrapDesc(curMod.desc, 18)
            Font.draw(descLine1, 8, 98)
            if #descLine2 > 0 then
              Font.draw(descLine2, 8, 108)
            end
          end

          -- Scroll arrows & help indicator
          if total > maxVisible then
            if scrollOffset > 0 then
              Font.draw("^", 148, 10)
            end
            if scrollOffset + maxVisible < total then
              Font.draw("v", 148, 76)
            end
          end

          Font.draw("A/</>:CHG B:EXIT", 16, 126)
        end

        return state
      end,
    })
  end

  -- 3. Wrap Options Menu rows hook to inject 'OMNIQOL' into the native Options menu
  -- (Active both in-game via Start Menu -> OPTION and on the Title Screen -> OPTION)
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("ui.options.rows", function(next, game, rows)
      local out = next and next(game, rows) or rows
      if type(out) ~= "table" then return out end

      local omniRow = {
        id = "omni_qol",
        label = "OMNIQOL",
        value = function(g)
          return moduleManager:getSummary(g or game)
        end,
        activate = function(g)
          local target = g or game
          if mod.ui and type(mod.ui.push) == "function" then
            mod.ui.push(target, screenId)
          elseif target and target.stack and type(target.stack.push) == "function" then
            local screenDef = mod.content and mod.content.screens and mod.content.screens:get(screenId)
            if screenDef and screenDef.new then
              target.stack:push(screenDef.new(target))
            end
          end
        end,
      }

      -- Insert near management entries (MODS / CONTROLS), right before CANCEL
      local inserted = false
      for i = #out, 1, -1 do
        local r = out[i]
        if r.id == "controls" or r.id == "mods" then
          table.insert(out, i + 1, omniRow)
          inserted = true
          break
        end
      end
      if not inserted then
        table.insert(out, omniRow)
      end

      return out
    end)
  end
end

return SettingsMenu
