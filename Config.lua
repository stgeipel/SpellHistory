--[[
    Spell History - Configuration Panel
    Settings interface for WoW 12.0 Settings API
]]

local addonName = "Spell History"
local L = SpellHistory.L

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
        L.MAX_SPELLS,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, L.MAX_SPELLS_DESC)
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
        L.ICON_SIZE,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, L.ICON_SIZE_DESC)
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
        L.SPACING,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

    Settings.CreateSlider(category, setting, options, L.SPACING_DESC)
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
        L.LOCK_FRAME,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.LOCK_FRAME_DESC)
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
        L.SHOW_BORDER,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.SHOW_BORDER_DESC)
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
        L.BG_ALPHA,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage)

    Settings.CreateSlider(category, setting, options, L.BG_ALPHA_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Icon Alpha Slider
--------------------------------------------------------------------------------
do
    local minValue, maxValue, step = 0, 1, 0.05
    local defaultValue = 1.0

    local function GetValue()
        return SpellHistoryDB.iconAlpha or 1.0
    end

    local function SetValue(value)
        SpellHistoryDB.iconAlpha = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_ICON_ALPHA",
        Settings.VarType.Number,
        L.ICON_ALPHA,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage)

    Settings.CreateSlider(category, setting, options, L.ICON_ALPHA_DESC)
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
    local defaultValue = true

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
-- Setting: Show Tooltips Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = true

    local function GetValue()
        return SpellHistoryDB.showTooltips
    end

    local function SetValue(value)
        SpellHistoryDB.showTooltips = value
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_SHOW_TOOLTIPS",
        Settings.VarType.Boolean,
        L.SHOW_TOOLTIPS,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.SHOW_TOOLTIPS_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Vertical Orientation Checkbox
--------------------------------------------------------------------------------
do
    local defaultValue = false

    local function GetValue()
        return SpellHistoryDB.verticalOrientation
    end

    local function SetValue(value)
        SpellHistoryDB.verticalOrientation = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_VERTICAL_ORIENTATION",
        Settings.VarType.Boolean,
        L.VERTICAL_ORIENTATION,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.VERTICAL_ORIENTATION_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Grow Direction Dropdown
--------------------------------------------------------------------------------
do
    local function GetValue()
        return SpellHistoryDB.growDirection == "reverse" and 2 or 1
    end

    local function SetValue(value)
        SpellHistoryDB.growDirection = value == 2 and "reverse" or "normal"
        SpellHistory:UpdateDisplay()
    end

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        local isVertical = SpellHistoryDB and SpellHistoryDB.verticalOrientation
        if isVertical then
            container:Add(1, L.GROW_NORMAL, L.GROW_NORMAL_DESC_V)
            container:Add(2, L.GROW_REVERSE, L.GROW_REVERSE_DESC_V)
        else
            container:Add(1, L.GROW_NORMAL, L.GROW_NORMAL_DESC_H)
            container:Add(2, L.GROW_REVERSE, L.GROW_REVERSE_DESC_H)
        end
        return container:GetData()
    end

    local defaultValue = 1

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_GROW_DIRECTION",
        Settings.VarType.Number,
        L.GROW_DIRECTION,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateDropdown(category, setting, GetOptions, L.GROW_DIRECTION_DESC)
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
        buttonText = L.RESET_POSITION,
        buttonClick = OnButtonClick,
        tooltip = L.RESET_POSITION_DESC,
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
        buttonText = L.CLEAR_HISTORY,
        buttonClick = OnButtonClick,
        tooltip = L.CLEAR_HISTORY_DESC,
    })
    layout:AddInitializer(initializer)
end

--------------------------------------------------------------------------------
-- Register Category
--------------------------------------------------------------------------------
Settings.RegisterAddOnCategory(category)

-- Store category for slash command access
SpellHistory.settingsCategory = category
