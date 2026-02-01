--[[
    Spell History Addon for WoW Midnight (12.0)
    Displays your cast and interrupted spells in a movable frame
]]

local addonName, addon = ...

--------------------------------------------------------------------------------
-- Namespace
--------------------------------------------------------------------------------
SpellHistory = {}
SpellHistory.history = {}

--------------------------------------------------------------------------------
-- Localization
--------------------------------------------------------------------------------
local L = {}
local locale = GetLocale()

if locale == "deDE" then
    L.ADDON_LOADED = "Spell History geladen. Nutze /spellhistory für Einstellungen."
    L.POSITION_RESET = "Position wurde zurückgesetzt."
    L.HISTORY_CLEARED = "Historie wurde gelöscht."
    L.INTERRUPTED = "Abgebrochen"
    L.SUCCEEDED = "Erfolgreich"
    L.SHOW_INTERRUPTED = "Abgebrochene Zauber anzeigen"
    L.SHOW_INTERRUPTED_DESC = "Zeigt abgebrochene/fehlgeschlagene Zauber in der Historie an"
    L.HIDE_PROFESSIONS = "Berufe-Zauber ausblenden"
    L.HIDE_PROFESSIONS_DESC = "Blendet Zauber von Berufen (Schmiedekunst, Alchemie, etc.) aus"
    L.ORIENTATION_VERTICAL = "Vertikale Ausrichtung"
    L.ORIENTATION_VERTICAL_DESC = "Zeigt die Icons vertikal statt horizontal an"
    L.CMD_HELP = "Befehle:"
    L.CMD_CONFIG = "Öffnet Einstellungen"
    L.CMD_CLEAR = "Löscht Historie"
else -- Default English
    L.ADDON_LOADED = "Spell History loaded. Use /spellhistory for settings."
    L.POSITION_RESET = "Position has been reset."
    L.HISTORY_CLEARED = "History has been cleared."
    L.INTERRUPTED = "Interrupted"
    L.SUCCEEDED = "Succeeded"
    L.SHOW_INTERRUPTED = "Show Interrupted Spells"
    L.SHOW_INTERRUPTED_DESC = "Shows interrupted/failed spells in the history"
    L.HIDE_PROFESSIONS = "Hide Profession Spells"
    L.HIDE_PROFESSIONS_DESC = "Hides spells from professions (Blacksmithing, Alchemy, etc.)"
    L.ORIENTATION_VERTICAL = "Vertical Orientation"
    L.ORIENTATION_VERTICAL_DESC = "Displays icons vertically instead of horizontally"
    L.CMD_HELP = "Commands:"
    L.CMD_CONFIG = "Opens settings"
    L.CMD_CLEAR = "Clears history"
end

SpellHistory.L = L

--------------------------------------------------------------------------------
-- Default Settings
--------------------------------------------------------------------------------
local defaults = {
    maxSpells = 10,
    iconSize = 40,
    spacing = 5,
    locked = false,
    showBorder = true,
    backgroundAlpha = 0.5,
    showInterrupted = true,
    hideProfessions = true,
    verticalOrientation = false,
    growDirection = "normal", -- "normal" or "reverse" (horizontal: left/right, vertical: top/bottom)
    position = {
        point = "CENTER",
        x = 0,
        y = 0
    }
}

--------------------------------------------------------------------------------
-- Database Initialization
--------------------------------------------------------------------------------
local function InitializeDB()
    if not SpellHistoryDB then
        SpellHistoryDB = CopyTable(defaults)
    else
        -- Merge with defaults for any missing values
        for k, v in pairs(defaults) do
            if SpellHistoryDB[k] == nil then
                SpellHistoryDB[k] = v
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Main Frame Creation
--------------------------------------------------------------------------------
local mainFrame = CreateFrame("Frame", "SpellHistoryFrame", UIParent, "BackdropTemplate")
mainFrame:SetSize(450, 50)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetClampedToScreen(true)

-- Background texture
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0.5)
mainFrame.bg = bg

-- Border backdrop
mainFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
mainFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

--------------------------------------------------------------------------------
-- Frame Update Functions
--------------------------------------------------------------------------------

-- Update lock state based on settings
function SpellHistory:UpdateLockState()
    if SpellHistoryDB.locked then
        mainFrame:EnableMouse(false)
        mainFrame:SetMovable(false)
    else
        mainFrame:EnableMouse(true)
        mainFrame:SetMovable(true)
    end
end

-- Update visual settings (border, background alpha)
function SpellHistory:UpdateVisuals()
    -- Background transparency
    mainFrame.bg:SetColorTexture(0, 0, 0, SpellHistoryDB.backgroundAlpha)

    -- Border visibility
    if SpellHistoryDB.showBorder then
        mainFrame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        mainFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    else
        mainFrame:SetBackdrop(nil)
    end
end

--------------------------------------------------------------------------------
-- Drag and Drop Handlers
--------------------------------------------------------------------------------
mainFrame:SetScript("OnDragStart", function(self)
    if not SpellHistoryDB.locked then
        self:StartMoving()
    end
end)

mainFrame:SetScript("OnDragStop", function(self)
    if not SpellHistoryDB.locked then
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        SpellHistoryDB.position.point = point
        SpellHistoryDB.position.x = x
        SpellHistoryDB.position.y = y
    end
end)

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
local iconPool = {}

-- Get or create an icon frame
local function GetIcon(index)
    if not iconPool[index] then
        local icon = CreateFrame("Frame", nil, mainFrame)
        icon:SetSize(SpellHistoryDB.iconSize, SpellHistoryDB.iconSize)

        -- Spell icon texture
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints(true)
        icon.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        -- Border (unused but kept for future use)
        icon.border = icon:CreateTexture(nil, "OVERLAY")
        icon.border:SetAllPoints(true)
        icon.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        icon.border:SetBlendMode("ADD")
        icon.border:Hide()

        -- Red overlay for interrupted spells
        icon.overlay = icon:CreateTexture(nil, "OVERLAY")
        icon.overlay:SetAllPoints(true)
        icon.overlay:SetColorTexture(1, 0, 0, 0.3)
        icon.overlay:Hide()

        -- Tooltip on hover
        icon:SetScript("OnEnter", function(self)
            if self.spellData then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetSpellByID(self.spellData.spellID)

                if self.spellData.interrupted then
                    GameTooltip:AddLine("|cFFFF0000" .. L.INTERRUPTED .. "|r", 1, 1, 1)
                else
                    GameTooltip:AddLine("|cFF00FF00" .. L.SUCCEEDED .. "|r", 1, 1, 1)
                end

                GameTooltip:Show()
            end
        end)

        icon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        iconPool[index] = icon
    end

    return iconPool[index]
end

--------------------------------------------------------------------------------
-- Display Update
--------------------------------------------------------------------------------
function SpellHistory:UpdateDisplay()
    local iconSize = SpellHistoryDB.iconSize
    local spacing = SpellHistoryDB.spacing
    local maxSpells = SpellHistoryDB.maxSpells

    -- Calculate and set frame size based on orientation
    local isVertical = SpellHistoryDB.verticalOrientation
    local frameWidth, frameHeight

    if isVertical then
        frameWidth = iconSize + 16
        frameHeight = (iconSize * maxSpells) + (spacing * (maxSpells - 1)) + 16
    else
        frameWidth = (iconSize * maxSpells) + (spacing * (maxSpells - 1)) + 16
        frameHeight = iconSize + 16
    end
    mainFrame:SetSize(frameWidth, frameHeight)

    -- Hide all icons first
    for _, icon in pairs(iconPool) do
        icon:Hide()
    end

    -- Display spell icons
    local displayCount = math.min(#self.history, maxSpells)
    local isReversed = SpellHistoryDB.growDirection == "reverse"

    for i = 1, displayCount do
        local spellData = self.history[i]
        local icon = GetIcon(i)

        -- Position icon based on orientation and grow direction
        icon:ClearAllPoints()
        if isVertical then
            if isReversed then
                -- Grow upward (newest at bottom)
                local yPos = 8 + ((i - 1) * (iconSize + spacing))
                icon:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, yPos)
            else
                -- Grow downward (newest at top) - default
                local yPos = -8 - ((i - 1) * (iconSize + spacing))
                icon:SetPoint("TOP", mainFrame, "TOP", 0, yPos)
            end
        else
            if isReversed then
                -- Grow leftward (newest at right)
                local xPos = -8 - ((i - 1) * (iconSize + spacing))
                icon:SetPoint("RIGHT", mainFrame, "RIGHT", xPos, 0)
            else
                -- Grow rightward (newest at left) - default
                local xPos = 8 + ((i - 1) * (iconSize + spacing))
                icon:SetPoint("LEFT", mainFrame, "LEFT", xPos, 0)
            end
        end
        icon:SetSize(iconSize, iconSize)

        -- Set spell texture
        icon.texture:SetTexture(spellData.icon)

        -- Show/hide interrupted overlay
        if spellData.interrupted then
            icon.overlay:Show()
        else
            icon.overlay:Hide()
        end

        -- Store spell data for tooltip
        icon.spellData = spellData

        icon:Show()
    end
end

--------------------------------------------------------------------------------
-- Profession Spell Detection
--------------------------------------------------------------------------------
local function IsProfessionSpell(spellID)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if not spellInfo then return false end

    -- Check if spell is a profession recipe
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(spellID)
    if recipeInfo and recipeInfo.learned then
        return true
    end

    -- Check spell name for common profession keywords
    local professionKeywords = {
        "Blacksmithing", "Schmiedekunst",
        "Alchemy", "Alchemie",
        "Engineering", "Ingenieurskunst",
        "Tailoring", "Schneiderei",
        "Leatherworking", "Lederverarbeitung",
        "Enchanting", "Verzauberkunst",
        "Jewelcrafting", "Juwelenschleifen",
        "Inscription", "Inschriftenkunde",
        "Herbalism", "Kräuterkunde",
        "Mining", "Bergbau",
        "Skinning", "Kürschnerei",
        "Cooking", "Kochkunst",
        "First Aid", "Erste Hilfe",
        "Fishing", "Angeln",
        "Archaeology", "Archäologie"
    }

    local spellName = spellInfo.name:lower()
    for _, keyword in ipairs(professionKeywords) do
        if spellName:find(keyword:lower(), 1, true) then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Spell History Management
--------------------------------------------------------------------------------
-- Track active empowered casts to avoid duplicates from SUCCEEDED events
local activeEmpowerCast = nil -- { spellID, castGUID }
-- Track recently added spells by spellID to handle any remaining duplicates
local recentSpells = {}
local DEDUP_TIME = 0.3 -- Same spell within 0.3 seconds is considered duplicate
local CLEANUP_INTERVAL = 30
local lastCleanupTime = 0

local function CleanupTracking()
    local now = GetTime()
    if now - lastCleanupTime < CLEANUP_INTERVAL then
        return
    end
    lastCleanupTime = now

    -- Clean up old spell entries
    for spellID, timestamp in pairs(recentSpells) do
        if now - timestamp > 5 then
            recentSpells[spellID] = nil
        end
    end
end

function SpellHistory:AddSpell(spellID, spellName, icon, interrupted)
    -- Filter profession spells if enabled
    if SpellHistoryDB.hideProfessions and IsProfessionSpell(spellID) then
        return
    end

    local now = GetTime()

    -- Check: Same spellID within short time window
    local lastCastTime = recentSpells[spellID]
    if lastCastTime and (now - lastCastTime) < DEDUP_TIME then
        return -- Same spell cast too recently
    end
    recentSpells[spellID] = now

    -- Periodic cleanup of old entries
    CleanupTracking()

    -- Insert at beginning of history
    table.insert(self.history, 1, {
        spellID = spellID,
        spellName = spellName,
        icon = icon,
        interrupted = interrupted,
        timestamp = now
    })

    -- Trim history to max size
    while #self.history > SpellHistoryDB.maxSpells * 2 do
        table.remove(self.history)
    end

    self:UpdateDisplay()
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
eventFrame:RegisterEvent("ADDON_LOADED")

-- Event dispatcher
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            InitializeDB()

            -- Restore saved position
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint(
                SpellHistoryDB.position.point,
                UIParent,
                SpellHistoryDB.position.point,
                SpellHistoryDB.position.x,
                SpellHistoryDB.position.y
            )

            -- Apply saved settings
            SpellHistory:UpdateLockState()
            SpellHistory:UpdateVisuals()
            SpellHistory:UpdateDisplay()

            print("|cFF00FF00Spell History|r " .. L.ADDON_LOADED)
        end

    elseif event == "UNIT_SPELLCAST_EMPOWER_START" then
        local unit, castGUID, spellID = ...
        if unit == "player" and spellID then
            -- Track that we're in an empowered cast
            activeEmpowerCast = { spellID = spellID, castGUID = castGUID }
        end

    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local unit, castGUID, spellID = ...
        if unit == "player" and SpellHistoryDB and spellID then
            -- Empowered cast completed - add to history
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                SpellHistory:AddSpell(spellID, spellInfo.name, spellInfo.iconID, false)
            end
            activeEmpowerCast = nil
        end

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        -- Only process player spells and ensure DB is initialized
        if unit == "player" and SpellHistoryDB and spellID then
            -- Skip if this is part of an active empowered cast (handled by EMPOWER_STOP)
            if activeEmpowerCast and activeEmpowerCast.spellID == spellID then
                return
            end
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                SpellHistory:AddSpell(spellID, spellInfo.name, spellInfo.iconID, false)
            end
        end

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        local unit, castGUID, spellID = ...
        -- Only process player spells and ensure DB is initialized
        if unit == "player" and SpellHistoryDB and SpellHistoryDB.showInterrupted and spellID then
            -- Clear empowered cast tracking if interrupted
            if activeEmpowerCast and activeEmpowerCast.spellID == spellID then
                activeEmpowerCast = nil
            end
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                SpellHistory:AddSpell(spellID, spellInfo.name, spellInfo.iconID, true)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_SPELLHISTORY1 = "/spellhistory"
SLASH_SPELLHISTORY2 = "/sh"
SlashCmdList["SPELLHISTORY"] = function(msg)
    if msg == "clear" then
        SpellHistory.history = {}
        SpellHistory:UpdateDisplay()
        print("|cFF00FF00Spell History|r: " .. L.HISTORY_CLEARED)
    elseif msg == "config" or msg == "" then
        if SpellHistory.settingsCategory then
            Settings.OpenToCategory(SpellHistory.settingsCategory:GetID())
        end
    else
        print("|cFF00FF00Spell History|r " .. L.CMD_HELP)
        print("/spellhistory - " .. L.CMD_CONFIG)
        print("/spellhistory clear - " .. L.CMD_CLEAR)
    end
end
