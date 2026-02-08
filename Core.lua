--[[
    Spell History Addon for WoW Midnight (12.0)
    Shows ONLY spells you actually pressed (player-initiated casts)
    by filtering via UNIT_SPELLCAST_SENT.

    Notes:
    - Trigger/proc spells (e.g. Living Flame fired by something else) are ignored,
      because they usually do NOT have a matching UNIT_SPELLCAST_SENT for the player.
]]

local addonName, addon = ...

--------------------------------------------------------------------------------
-- Namespace
--------------------------------------------------------------------------------
SpellHistory = SpellHistory or {}
SpellHistory.history = {}

-- Localization is loaded from locales/*.lua (enEN first, then deDE overwrites)
local L = SpellHistory.L

--------------------------------------------------------------------------------
-- Debugging
--------------------------------------------------------------------------------
local DEBUG = false
local function dbg(event, unit, castGUID, spellID, extra)
    if not DEBUG then return end
    local info = spellID and C_Spell.GetSpellInfo(spellID)
    local name = info and info.name or "nil"
    print(string.format(
        "[SpellHistory] %s | unit=%s | guid=%s | spellID=%s (%s)%s",
        tostring(event),
        tostring(unit),
        tostring(castGUID),
        tostring(spellID),
        tostring(name),
        extra and (" | " .. tostring(extra)) or ""
    ))
end

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
    iconAlpha = 1.0,
    showInterrupted = true,
    hideProfessions = true,
    showTooltips = true,
    verticalOrientation = false,
    growDirection = "normal",
    -- Animation settings
    animationEnabled = true,
    animationMode = "conveyor",   -- "none", "conveyor", "fade"
    -- Conveyor mode settings
    animationDuration = 8.0,      -- Total time for spell to travel across the bar
    animationFadeStart = 0.5,     -- Start fading at 50% of the journey (halfway point)
    -- Fade mode settings
    animationFadeIn = 0.3,        -- Seconds to fade in
    animationDisplayTime = 5.0,   -- Seconds to display at full opacity
    animationFadeOut = 0.5,       -- Seconds to fade out
    position = { point = "CENTER", x = 0, y = 0 }
}

--------------------------------------------------------------------------------
-- Database Initialization
--------------------------------------------------------------------------------
local function InitializeDB()
    if not SpellHistoryDB then
        SpellHistoryDB = CopyTable(defaults)
    else
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
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetClampedToScreen(true)

-- Background
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0.5)
mainFrame.bg = bg

-- Clip children to frame bounds (fixes icons sliding outside background)
-- Create a content frame to hold icons and clip them strictly
local contentFrame = CreateFrame("Frame", nil, mainFrame)
contentFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 2, -2)
contentFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -2, 2)
contentFrame:SetClipsChildren(true)
SpellHistory.contentFrame = contentFrame

-- Border
mainFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
mainFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

--------------------------------------------------------------------------------
-- Frame Update Functions
--------------------------------------------------------------------------------
function SpellHistory:UpdateLockState()
    if SpellHistoryDB.locked then
        mainFrame:EnableMouse(false)
        mainFrame:SetMovable(false)
    else
        mainFrame:EnableMouse(true)
        mainFrame:SetMovable(true)
    end
end

function SpellHistory:UpdateVisuals()
    mainFrame.bg:SetColorTexture(0, 0, 0, SpellHistoryDB.backgroundAlpha)

    if SpellHistoryDB.showBorder then
        mainFrame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        mainFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        SpellHistory.contentFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 2, -2)
        SpellHistory.contentFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -2, 2)
    else
        mainFrame:SetBackdrop(nil)
        SpellHistory.contentFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
        SpellHistory.contentFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
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
        local point, _, _, x, y = self:GetPoint()
        SpellHistoryDB.position.point = point
        SpellHistoryDB.position.x = x
        SpellHistoryDB.position.y = y
    end
end)

--------------------------------------------------------------------------------
-- Animation System (loaded from Animation.lua)
--------------------------------------------------------------------------------
-- Animation module is loaded from Animation.lua
-- Access via SpellHistory.Animation

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
local iconPool = {}

local function GetIcon(index)
    if iconPool[index] then return iconPool[index] end

    local icon = CreateFrame("Frame", nil, SpellHistory.contentFrame)

    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints(true)
    icon.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    icon.border = icon:CreateTexture(nil, "OVERLAY")
    icon.border:SetAllPoints(true)
    icon.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    icon.border:SetBlendMode("ADD")
    icon.border:Hide()

    icon.overlay = icon:CreateTexture(nil, "OVERLAY")
    icon.overlay:SetAllPoints(true)
    icon.overlay:SetColorTexture(1, 0, 0, 0.3)
    icon.overlay:Hide()

    icon:SetScript("OnEnter", function(self)
        if self.spellData and SpellHistoryDB.showTooltips then
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

    icon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    iconPool[index] = icon
    return icon
end

--------------------------------------------------------------------------------
-- Display Update
--------------------------------------------------------------------------------
function SpellHistory:UpdateDisplay()
    if not SpellHistoryDB then return end

    local iconSize = SpellHistoryDB.iconSize or 40
    local spacing = SpellHistoryDB.spacing or 5
    local maxSpells = SpellHistoryDB.maxSpells or 10
    local isVertical = SpellHistoryDB.verticalOrientation
    local isReversed = SpellHistoryDB.growDirection == "reverse"
    local iconAlpha = SpellHistoryDB.iconAlpha or 1.0

    -- Frame size
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
    for idx, icon in pairs(iconPool) do
        icon:Hide()
    end

    local now = GetTime()
    local displayIndex = 0
    local Animation = SpellHistory.Animation

    -- Check if Animation module is loaded
    if not Animation then
        -- Fallback: display without animation
        for i, spellData in ipairs(self.history) do
            if displayIndex >= maxSpells then break end
            displayIndex = displayIndex + 1

            local icon = GetIcon(displayIndex)
            icon:SetSize(iconSize, iconSize)
            icon:ClearAllPoints()

            local pos = (displayIndex - 1) * (iconSize + spacing)
            if isVertical then
                if isReversed then
                    icon:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8 + pos)
                else
                    icon:SetPoint("TOP", mainFrame, "TOP", 0, -8 - pos)
                end
            else
                if isReversed then
                    icon:SetPoint("RIGHT", mainFrame, "RIGHT", -8 - pos, 0)
                else
                    icon:SetPoint("LEFT", mainFrame, "LEFT", 8 + pos, 0)
                end
            end

            icon:SetAlpha(iconAlpha)
            icon.texture:SetTexture(spellData.icon)
            if spellData.interrupted then icon.overlay:Show() else icon.overlay:Hide() end
            icon.spellData = spellData
            icon:Show()
        end
        return
    end

    -- Process spells through animation system
    -- (Loop continues beyond maxSpells to allow smooth exit animation)
    for i, spellData in ipairs(self.history) do

        -- Calculate animation state
        local shouldShow, currentAlpha, animatedPos = Animation:Calculate(
            spellData,
            i,  -- Pass original index for overlap prevention
            now,
            SpellHistoryDB
        )

        if shouldShow then
            displayIndex = displayIndex + 1
            local icon = GetIcon(displayIndex)
            icon:SetSize(iconSize, iconSize)

            -- Position the icon based on animated position
            icon:ClearAllPoints()
            if isVertical then
                if isReversed then
                    -- Bottom to Top: start at bottom, move up
                    icon:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 8 + animatedPos)
                else
                    -- Top to Bottom: start at top, move down
                    icon:SetPoint("TOP", mainFrame, "TOP", 0, -8 - animatedPos)
                end
            else
                if isReversed then
                    -- Right to Left: start at right, move left
                    icon:SetPoint("RIGHT", mainFrame, "RIGHT", -8 - animatedPos, 0)
                else
                    -- Left to Right: start at left, move right
                    icon:SetPoint("LEFT", mainFrame, "LEFT", 8 + animatedPos, 0)
                end
            end

            icon:SetAlpha(currentAlpha)
            icon.texture:SetTexture(spellData.icon)
            if spellData.interrupted then icon.overlay:Show() else icon.overlay:Hide() end
            icon.spellData = spellData
            icon:Show()
        end
    end

    -- Start animation update loop if needed
    if Animation:HasActiveAnimations(self.history, now, SpellHistoryDB) then
        Animation:StartUpdate()
    end
end

--------------------------------------------------------------------------------
-- Profession Spell Detection
--------------------------------------------------------------------------------
local function IsProfessionSpell(spellID)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if not spellInfo or not spellInfo.name then return false end

    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(spellID)
    if recipeInfo and recipeInfo.learned then
        return true
    end

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
-- Tracking (ONLY pressed spells)
--------------------------------------------------------------------------------
local sentCasts = {}
local recentCasts = {}
local activeEmpowerGUID = nil

local DEDUP_TIME = 2.0
local CLEANUP_INTERVAL = 30
local MAX_TRACK_AGE = 10
local lastCleanupTime = 0

local function CleanupTracking()
    local now = GetTime()
    if now - lastCleanupTime < CLEANUP_INTERVAL then return end
    lastCleanupTime = now

    for guid, v in pairs(sentCasts) do
        if now - v.t > MAX_TRACK_AGE then
            sentCasts[guid] = nil
        end
    end

    for guid, t in pairs(recentCasts) do
        if now - t > MAX_TRACK_AGE then
            recentCasts[guid] = nil
        end
    end
end

local function MarkHandled(castGUID)
    if not castGUID then return end
    sentCasts[castGUID] = nil
end

--------------------------------------------------------------------------------
-- Spell History Management
--------------------------------------------------------------------------------
local BACK_TO_BACK_TIME = 0.6

function SpellHistory:AddSpell(spellID, spellName, icon, interrupted, castGUID)
    if not SpellHistoryDB or not spellID then return end

    if SpellHistoryDB.hideProfessions and IsProfessionSpell(spellID) then
        return
    end

    local now = GetTime()

    if castGUID then
        local last = recentCasts[castGUID]
        if last and (now - last) < DEDUP_TIME then
            return
        end
        recentCasts[castGUID] = now
    end

    local lastEntry = self.history[1]
    if lastEntry
        and lastEntry.spellID == spellID
        and lastEntry.interrupted == interrupted
        and (now - lastEntry.timestamp) < BACK_TO_BACK_TIME
    then
        return
    end

    CleanupTracking()

    table.insert(self.history, 1, {
        spellID = spellID,
        spellName = spellName,
        icon = icon,
        interrupted = interrupted,
        timestamp = now,
        castGUID = castGUID,
    })

    while #self.history > (SpellHistoryDB.maxSpells * 2) do
        table.remove(self.history)
    end

    self:UpdateDisplay()
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            InitializeDB()

            mainFrame:ClearAllPoints()
            mainFrame:SetPoint(
                SpellHistoryDB.position.point,
                UIParent,
                SpellHistoryDB.position.point,
                SpellHistoryDB.position.x,
                SpellHistoryDB.position.y
            )

            SpellHistory:UpdateLockState()
            SpellHistory:UpdateVisuals()
            SpellHistory:UpdateDisplay()

            print("|cFF00FF00Spell History|r " .. L.ADDON_LOADED)
        end
        return
    end

    if event == "UNIT_SPELLCAST_SENT" then
        local unit, target, castGUID, spellID = ...
        if unit ~= "player" or not castGUID or not spellID then return end

        sentCasts[castGUID] = { spellID = spellID, t = GetTime() }
        dbg(event, unit, castGUID, spellID, "SENT")
        CleanupTracking()
        return
    end

    local unit, castGUID, spellID = ...
    if unit ~= "player" or not SpellHistoryDB or not spellID then return end

    dbg(event, unit, castGUID, spellID)

    local sent = castGUID and sentCasts[castGUID]
    if not sent then
        return
    end

    if event == "UNIT_SPELLCAST_EMPOWER_START" then
        activeEmpowerGUID = castGUID
        return
    end

    if event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            SpellHistory:AddSpell(spellID, info.name, info.iconID, false, castGUID)
        end
        MarkHandled(castGUID)
        if activeEmpowerGUID == castGUID then activeEmpowerGUID = nil end
        return
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if activeEmpowerGUID == castGUID then
            return
        end

        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            SpellHistory:AddSpell(spellID, info.name, info.iconID, false, castGUID)
        end
        MarkHandled(castGUID)
        return
    end

    if event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        if not SpellHistoryDB.showInterrupted then
            MarkHandled(castGUID)
            if activeEmpowerGUID == castGUID then activeEmpowerGUID = nil end
            return
        end

        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            SpellHistory:AddSpell(spellID, info.name, info.iconID, true, castGUID)
        end
        MarkHandled(castGUID)
        if activeEmpowerGUID == castGUID then activeEmpowerGUID = nil end
        return
    end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_SPELLHISTORY1 = "/spellhistory"
SLASH_SPELLHISTORY2 = "/sh"

SlashCmdList["SPELLHISTORY"] = function(msg)
    msg = (msg or ""):lower()

    if msg == "clear" then
        SpellHistory.history = {}
        SpellHistory:UpdateDisplay()
        print("|cFF00FF00Spell History|r: " .. L.HISTORY_CLEARED)
        return
    end

    if msg == "config" or msg == "" then
        if SpellHistory.settingsCategory then
            Settings.OpenToCategory(SpellHistory.settingsCategory:GetID())
        else
            print("|cFF00FF00Spell History|r: (no settings panel registered)")
        end
        return
    end

    print("|cFF00FF00Spell History|r " .. L.CMD_HELP)
    print("/spellhistory - " .. L.CMD_CONFIG)
    print("/spellhistory clear - " .. L.CMD_CLEAR)
end
