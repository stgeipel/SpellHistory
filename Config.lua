--[[
    Spell History - Configuration Panel
    Settings interface for WoW 12.0 Settings API
]]

local addonName = "Spell History"
local L = SpellHistory.L

--------------------------------------------------------------------------------
-- Localization for Config
--------------------------------------------------------------------------------
local locale = GetLocale()
local CL = {} -- Config Localization

if locale == "deDE" then
    CL.MAX_SPELLS = "Anzahl der Spells"
    CL.MAX_SPELLS_DESC = "Legt fest, wie viele Spells in der Historie angezeigt werden"
    CL.ICON_SIZE = "Icon-Größe"
    CL.ICON_SIZE_DESC = "Legt die Größe der Spell-Icons fest"
    CL.SPACING = "Abstand zwischen Icons"
    CL.SPACING_DESC = "Legt den Abstand zwischen den Icons fest"
    CL.LOCK_FRAME = "Fenster sperren"
    CL.LOCK_FRAME_DESC = "Verhindert das Verschieben des Fensters"
    CL.SHOW_BORDER = "Rahmen anzeigen"
    CL.SHOW_BORDER_DESC = "Zeigt einen Rahmen um das Fenster an"
    CL.BG_ALPHA = "Hintergrund-Transparenz"
    CL.BG_ALPHA_DESC = "Legt die Transparenz des Hintergrunds fest (0 = durchsichtig, 1 = undurchsichtig)"
    CL.RESET_POSITION = "Position zurücksetzen"
    CL.RESET_POSITION_DESC = "Setzt die Position des Fensters auf die Bildschirmmitte zurück"
    CL.CLEAR_HISTORY = "Historie löschen"
    CL.CLEAR_HISTORY_DESC = "Löscht alle Einträge aus der Spell-Historie"
else -- English
    CL.MAX_SPELLS = "Number of Spells"
    CL.MAX_SPELLS_DESC = "Sets how many spells are displayed in the history"
    CL.ICON_SIZE = "Icon Size"
    CL.ICON_SIZE_DESC = "Sets the size of the spell icons"
    CL.SPACING = "Spacing between Icons"
    CL.SPACING_DESC = "Sets the spacing between icons"
    CL.LOCK_FRAME = "Lock Frame"
    CL.LOCK_FRAME_DESC = "Prevents moving the frame"
    CL.SHOW_BORDER = "Show Border"
    CL.SHOW_BORDER_DESC = "Shows a border around the frame"
    CL.BG_ALPHA = "Background Transparency"
    CL.BG_ALPHA_DESC = "Sets background transparency (0 = transparent, 1 = opaque)"
    CL.RESET_POSITION = "Reset Position"
    CL.RESET_POSITION_DESC = "Resets the frame position to screen center"
    CL.CLEAR_HISTORY = "Clear History"
    CL.CLEAR_HISTORY_DESC = "Clears all entries from spell history"
end

--------------------------------------------------------------------------------
-- Settings Category Registration
--------------------------------------------------------------------------------
local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

--------------------------------------------------------------------------------
-- Setting: Max Spells Slider
--------------------------------------------------------------------------------
do
    local minValue, maxValue, step = 5, 30, 1
    local defaultValue = 10

    local function GetValue()
        return SpellHistoryDB.maxSpells
    end

    local function SetValue(value)
        SpellHistoryDB.maxSpells = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_MAX_SPELLS",
        Settings.VarType.Number,
        CL.MAX_SPELLS,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, CL.MAX_SPELLS_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Icon Size Slider
--------------------------------------------------------------------------------
do
    local minValue, maxValue, step = 20, 80, 5
    local defaultValue = 40

    local function GetValue()
        return SpellHistoryDB.iconSize
    end

    local function SetValue(value)
        SpellHistoryDB.iconSize = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_ICON_SIZE",
        Settings.VarType.Number,
        CL.ICON_SIZE,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, CL.ICON_SIZE_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Spacing Slider
--------------------------------------------------------------------------------
do
    local minValue, maxValue, step = 0, 20, 1
    local defaultValue = 5

    local function GetValue()
        return SpellHistoryDB.spacing
    end

    local function SetValue(value)
        SpellHistoryDB.spacing = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_SPACING",
        Settings.VarType.Number,
        CL.SPACING,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, CL.SPACING_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Lock Frame Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = false

    local function GetValue()
        return SpellHistoryDB.locked
    end

    local function SetValue(value)
        SpellHistoryDB.locked = value
        SpellHistory:UpdateLockState()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_LOCKED",
        Settings.VarType.Boolean,
        CL.LOCK_FRAME,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, CL.LOCK_FRAME_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Show Border Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = true

    local function GetValue()
        return SpellHistoryDB.showBorder
    end

    local function SetValue(value)
        SpellHistoryDB.showBorder = value
        SpellHistory:UpdateVisuals()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_BORDER",
        Settings.VarType.Boolean,
        CL.SHOW_BORDER,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, CL.SHOW_BORDER_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Background Alpha Slider
--------------------------------------------------------------------------------
do
    local minValue, maxValue, step = 0, 1, 0.05
    local defaultValue = 0.5

    local function GetValue()
        return SpellHistoryDB.backgroundAlpha
    end

    local function SetValue(value)
        SpellHistoryDB.backgroundAlpha = value
        SpellHistory:UpdateVisuals()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_BG_ALPHA",
        Settings.VarType.Number,
        CL.BG_ALPHA,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage)

    Settings.CreateSlider(category, setting, options, CL.BG_ALPHA_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Show Interrupted Spells Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = true

    local function GetValue()
        return SpellHistoryDB.showInterrupted
    end

    local function SetValue(value)
        SpellHistoryDB.showInterrupted = value
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_SHOW_INTERRUPTED",
        Settings.VarType.Boolean,
        L.SHOW_INTERRUPTED,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.SHOW_INTERRUPTED_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Hide Profession Spells Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = false

    local function GetValue()
        return SpellHistoryDB.hideProfessions
    end

    local function SetValue(value)
        SpellHistoryDB.hideProfessions = value
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_HIDE_PROFESSIONS",
        Settings.VarType.Boolean,
        L.HIDE_PROFESSIONS,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.HIDE_PROFESSIONS_DESC)
end

--------------------------------------------------------------------------------
-- Button: Reset Position
--------------------------------------------------------------------------------
do
    local function OnButtonClick()
        SpellHistoryDB.position = {
            point = "CENTER",
            x = 0,
            y = 0
        }
        SpellHistoryFrame:ClearAllPoints()
        SpellHistoryFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        print("|cFF00FF00Spell History|r: " .. L.POSITION_RESET)
    end

    local initializer = Settings.CreateElementInitializer("SettingButtonControlTemplate", {
        buttonText = CL.RESET_POSITION,
        buttonClick = OnButtonClick,
        tooltip = CL.RESET_POSITION_DESC,
    })
    layout:AddInitializer(initializer)
end

--------------------------------------------------------------------------------
-- Button: Clear History
--------------------------------------------------------------------------------
do
    local function OnButtonClick()
        SpellHistory.history = {}
        SpellHistory:UpdateDisplay()
        print("|cFF00FF00Spell History|r: " .. L.HISTORY_CLEARED)
    end

    local initializer = Settings.CreateElementInitializer("SettingButtonControlTemplate", {
        buttonText = CL.CLEAR_HISTORY,
        buttonClick = OnButtonClick,
        tooltip = CL.CLEAR_HISTORY_DESC,
    })
    layout:AddInitializer(initializer)
end

--------------------------------------------------------------------------------
-- Register Category
--------------------------------------------------------------------------------
Settings.RegisterAddOnCategory(category)
