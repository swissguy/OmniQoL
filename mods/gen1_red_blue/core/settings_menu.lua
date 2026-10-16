-- ============================================================================
-- G1R Deluxe: Start Menu & Settings Screen Integration
-- Injects 'MODS' entry into the overworld Start Menu and provides a custom
-- interactive UI screen to toggle modules on/off per save file.
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

  -- 2. Register custom UI screen for in-game Start Menu
  local screenId = "G1RDeluxeSettings"
  if mod.content and mod.content.screens and type(mod.content.screens.register) == "function" then
    mod.content.screens:register(screenId, {
      new = function(game)
        local Font = mod.ui and mod.ui.Font
        local selectedIndex = 1
        local state = { isOpaque = true }

        function state:update()
          local modules = moduleManager:getAll()
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
              if selectedIndex < 1 then selectedIndex = total end
            elseif game.input:wasPressed("down") then
              selectedIndex = selectedIndex + 1
              if selectedIndex > total then selectedIndex = 1 end
            elseif game.input:wasPressed("a") or game.input:wasPressed("left") or game.input:wasPressed("right") then
              local targetMod = modules[selectedIndex]
              if targetMod then
                moduleManager:toggle(targetMod.id)
              end
            elseif game.input:wasPressed("b") then
              game.stack:pop()
            end
          end
        end

        function state:draw()
          local modules = moduleManager:getAll()
          if not Font or type(Font.drawBox) ~= "function" then
            return
          end

          -- Full-screen Gen 1 tile dimensions: 20 columns x 18 rows
          Font.drawBox(0, 0, 20, 18)
          Font.draw("G1R DELUXE MODS", 16, 12)

          -- Divider line
          Font.draw("==================", 8, 24)

          -- List modules
          local startY = 38
          for i, modDef in ipairs(modules) do
            local yPos = startY + (i - 1) * 16
            local isSelected = (i == selectedIndex)
            local prefix = isSelected and ">" or " "
            local enabled = moduleManager:isEnabled(modDef.id)
            local statusTag = enabled and "[ON ]" or "[OFF]"

            -- Format row: e.g. "> RUNNING    [ON ]"
            local label = modDef.label:sub(1, 10)
            local padding = string.rep(" ", 11 - #label)
            local lineText = string.format("%s%-10s%s%s", prefix, label, padding, statusTag)
            Font.draw(lineText, 12, yPos)
          end

          -- Bottom info box
          Font.drawBox(0, 12, 20, 6)
          local activeDef = modules[selectedIndex]
          if activeDef and activeDef.desc and #activeDef.desc > 0 then
            -- Wrap / slice description to fit two 18-character lines
            local descLine1 = activeDef.desc:sub(1, 18)
            local descLine2 = activeDef.desc:sub(19, 36)
            Font.draw(descLine1, 12, 106)
            if #descLine2 > 0 then
              Font.draw(descLine2, 12, 118)
            end
          end

          Font.draw("A:TOGGLE  B:EXIT", 12, 132)
        end

        return state
      end,
    })
  end

  -- 3. Wrap Start Menu items hook to inject 'MODS'
  if mod.hooks and type(mod.hooks.wrap) == "function" then
    mod.hooks:wrap("ui.start_menu.items", function(next, game, items)
      local out = next and next(game, items) or items
      if type(out) ~= "table" then return out end

      local modsMenuItem = {
        label = "MODS",
        onSelect = function()
          if mod.ui and type(mod.ui.push) == "function" then
            mod.ui.push(game, screenId)
          elseif game.stack and type(game.stack.push) == "function" then
            local screenDef = mod.content and mod.content.screens and mod.content.screens:get(screenId)
            if screenDef and screenDef.new then
              game.stack:push(screenDef.new(game))
            end
          end
        end,
      }

      -- Try inserting before 'OPTION' (canonical Gen 1 position)
      if mod.ui and type(mod.ui.insertBefore) == "function" then
        local ok, result = pcall(function()
          return mod.ui.insertBefore(out, "OPTION", modsMenuItem)
        end)
        if ok and result then return result end
      end

      -- Fallback: Insert right before the last item (typically 'CANCEL')
      if #out > 1 then
        table.insert(out, #out, modsMenuItem)
      else
        table.insert(out, modsMenuItem)
      end

      return out
    end)
  end
end

return SettingsMenu
