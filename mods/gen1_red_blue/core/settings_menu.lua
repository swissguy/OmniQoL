-- ============================================================================
-- OmniQoL: Options Menu & Settings Screen Integration
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
          Font.draw("OMNIQOL MODS", 16, 12)

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
          return moduleManager:getSummary()
        end,
        activate = function(g)
          if mod.ui and type(mod.ui.push) == "function" then
            mod.ui.push(g, screenId)
          elseif g.stack and type(g.stack.push) == "function" then
            local screenDef = mod.content and mod.content.screens and mod.content.screens:get(screenId)
            if screenDef and screenDef.new then
              g.stack:push(screenDef.new(g))
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
