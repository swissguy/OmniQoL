-- ============================================================================
-- OmniQoL: Options Menu & Settings Screen Integration (Gen 1 & Gen 2)
-- Injects 'OMNIQOL' entry into the native Options Menu (accessible both
-- during gameplay and on the Title Screen), while leaving the top-level
-- overworld Start Menu clean and vanilla.
-- ============================================================================

local SettingsMenu = {}

function SettingsMenu.setup(mod, moduleManager)
  -- 1. Register fallback engine options if mod.options API exists (Recipe R34 compliant)
  if mod.options and type(mod.options.define) == "function" then
    local optionDefs = {}
    for _, modEntry in ipairs(moduleManager:getAll()) do
      local def = {
        id = modEntry.id,
        key = modEntry.id,
        label = modEntry.label,
        name = modEntry.label,
        type = "boolean",
        default = modEntry.default,
        description = modEntry.desc,
      }
      table.insert(optionDefs, def)
      -- Support individual option definition registration
      pcall(function() mod.options:define(def) end)
    end
    -- Support batch option definitions registration
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
                local ok, reason = moduleManager:cycle(targetMod.id, -1)
                if ok == false and reason then
                  pcall(function()
                    local Sound = require("src.core.Sound")
                    if Sound and type(Sound.play) == "function" then
                      Sound.play("collision")
                    end
                  end)
                end
              end
            elseif game.input:wasPressed("right") or game.input:wasPressed("a") then
              local targetMod = modules[selectedIndex]
              if targetMod then
                local ok, reason = moduleManager:cycle(targetMod.id, 1)
                if ok == false and reason then
                  pcall(function()
                    local Sound = require("src.core.Sound")
                    if Sound and type(Sound.play) == "function" then
                      Sound.play("collision")
                    end
                  end)
                end
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
              local isSelected = (i == selectedIndex)
              local statusTag = moduleManager.getDisplayStatus and moduleManager:getDisplayStatus(modDef.id)
                or (moduleManager:isEnabled(modDef.id, game) and "[ON ]" or "[OFF]")

              -- Draw authentic Pokemon triangle cursor arrow (0xED) or fallback
              if isSelected then
                if type(Font.drawCode) == "function" then
                  Font.drawCode(0xED, 8, yPos)
                else
                  Font.draw(">", 8, yPos)
                end
              end

              -- Label at x=16 (fits within 8-9 characters)
              local label = (modDef.label or ""):sub(1, 9)
              Font.draw(label, 16, yPos)

              -- Position badge based on width
              local tagX = (statusTag:len() > 6) and 78 or 104
              Font.draw(statusTag, tagX, yPos)
            end
          end

          -- Draw scroll indicator arrows if more modules exist
          if scrollOffset > 0 then
            Font.draw("^", 144, 26)
          end
          if scrollOffset + maxVisible < total then
            Font.draw("v", 144, 70)
          end

          -- Bottom info box: 20 columns x 7 rows (y: 88 to 144)
          Font.drawBox(0, 11, 20, 7)
          local activeDef = modules[selectedIndex]
          if activeDef then
            local desc = activeDef.desc or ""
            if activeDef.id == "move_relearner" then
              local val = tostring(moduleManager:getValue("move_relearner")):upper()
              if val == "OFF" then
                desc = "Move Relearner is disabled."
              elseif val == "RELEARN+TMS" or val == "RELEARN+TM" then
                desc = "Teach level-up moves & all TMs."
              else
                desc = "Relearn natural level-up moves."
              end
            elseif activeDef.id == "improved_inventory" then
              local val = moduleManager:isEnabled("improved_inventory", game)
              if not val then
                desc = "Vanilla 20 Bag and 50 PC items."
              else
                desc = "99 Bag & PC, page jump, auto-sort."
              end
            end
            local line1, line2 = wrapDesc(desc, 16)
            Font.draw(line1, 16, 98)
            if #line2 > 0 then
              Font.draw(line2, 16, 112)
            end
          end

          -- Bottom controls prompt: y=126 ends at y=134 (safely above bottom border at 136)
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
