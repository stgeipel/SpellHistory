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
    hideProfessions = false,
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

    -- Calculate and set frame width
    local frameWidth = (iconSize * maxSpells) + (spacing * (maxSpells - 1)) + 16
    mainFrame:SetSize(frameWidth, iconSize + 16)

    -- Hide all icons first
    for _, icon in pairs(iconPool) do
        icon:Hide()
    end

    -- Display spell icons
    local displayCount = math.min(#self.history, maxSpells)

    for i = 1, displayCount do
        local spellData = self.history[i]
        local icon = GetIcon(i)

        -- Position icon
        local xPos = 8 + ((i - 1) * (iconSize + spacing))
        icon:SetPoint("LEFT", mainFrame, "LEFT", xPos, 0)
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

    -- Check if spell is from a tradeskill
    local tradeskillLineID = C_Spell.GetSpellTradeSkillLine(spellID)
    if tradeskillLineID then
        return true
    end

    -- Additional check: Is it in a profession spell book?
    local professionInfo = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    if professionInfo then
        for _, profession in ipairs(professionInfo) do
            if C_Spell.IsSpellInRange(spellInfo.name, profession) then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Spell History Management
--------------------------------------------------------------------------------
function SpellHistory:AddSpell(spellID, spellName, icon, interrupted)
    -- Filter profession spells if enabled
    if SpellHistoryDB.hideProfessions and IsProfessionSpell(spellID) then
        return
    end

    -- Insert at beginning of history
    table.insert(self.history, 1, {
        spellID = spellID,
        spellName = spellName,
        icon = icon,
        interrupted = interrupted,
        timestamp = GetTime()
    })

    -- Trim history to max size
    while #self.history > SpellHistoryDB.maxSpells do
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
eventFrame:RegisterEvent("ADDON_LOADED")

-- Duplicate cast prevention
local processedCasts = {}
local CLEANUP_INTERVAL = 5
local lastCleanup = 0

local function HasProcessedCast(castGUID, spellID, interrupted)
    -- Use castGUID as unique key (WoW guarantees uniqueness)
    local key = castGUID or (spellID .. "_" .. tostring(interrupted) .. "_" .. GetTime())

    if processedCasts[key] then
        return true
    end

    processedCasts[key] = GetTime()

    -- Periodic cleanup to prevent memory leak
    local now = GetTime()
    if now - lastCleanup > CLEANUP_INTERVAL then
        for k, timestamp in pairs(processedCasts) do
            if now - timestamp > CLEANUP_INTERVAL then
                processedCasts[k] = nil
            end
        end
        lastCleanup = now
    end

    return false
end

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

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        if unit == "player" then
            if not HasProcessedCast(castGUID, spellID, false) then
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    SpellHistory:AddSpell(spellID, spellInfo.name, spellInfo.iconID, false)
                end
            end
        end

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        local unit, castGUID, spellID = ...
        if unit == "player" and SpellHistoryDB.showInterrupted then
            if not HasProcessedCast(castGUID, spellID, true) then
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    SpellHistory:AddSpell(spellID, spellInfo.name, spellInfo.iconID, true)
                end
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
        Settings.OpenToCategory("Spell History")
    else
        print("|cFF00FF00Spell History|r " .. L.CMD_HELP)
        print("/spellhistory - " .. L.CMD_CONFIG)
        print("/spellhistory clear - " .. L.CMD_CLEAR)
    end
end
