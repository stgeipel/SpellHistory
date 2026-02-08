--[[
    Spell History - Configuration Panel
    Settings interface for WoW 12.0 Settings API
]]

local addonName = "Spell History"
local L = SpellHistory.L

--------------------------------------------------------------------------------
-- Settings Category Registration (Main)
--------------------------------------------------------------------------------
local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

--------------------------------------------------------------------------------
-- Animation Subcategories (Approach A)
--------------------------------------------------------------------------------
local conveyorCategory, conveyorLayout = Settings.RegisterVerticalLayoutSubcategory(category, L.ANIMATION_CONVEYOR_HEADER)
local fadeCategory, fadeLayout         = Settings.RegisterVerticalLayoutSubcategory(category, L.ANIMATION_FADE_HEADER)

-- Store categories for optional external access
SpellHistory.settingsCategory = category
SpellHistory.animationCategories = {
    conveyor = conveyorCategory,
    fade = fadeCategory,
}

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
            container:Add(1, L.GROW_NORMAL,  L.GROW_NORMAL_DESC_V)
            container:Add(2, L.GROW_REVERSE, L.GROW_REVERSE_DESC_V)
        else
            container:Add(1, L.GROW_NORMAL,  L.GROW_NORMAL_DESC_H)
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
-- Animation Header (Main Category)
--------------------------------------------------------------------------------
layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.ANIMATION_HEADER))

--------------------------------------------------------------------------------
-- Setting: Animation Enabled Checkbox (Main Category)
--------------------------------------------------------------------------------
do
    local defaultValue = true

    local function GetValue()
        return SpellHistoryDB.animationEnabled
    end

    local function SetValue(value)
        SpellHistoryDB.animationEnabled = value
        SpellHistory:UpdateDisplay()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_ANIMATION_ENABLED",
        Settings.VarType.Boolean,
        L.ANIMATION_ENABLED,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateCheckbox(category, setting, L.ANIMATION_ENABLED_DESC)
end

--------------------------------------------------------------------------------
-- Setting: Animation Mode Dropdown (Main Category)
--------------------------------------------------------------------------------
do
    local function GetValue()
        local mode = SpellHistoryDB.animationMode or "conveyor"
        if mode == "conveyor" then return 1
        elseif mode == "fade" then return 2
        elseif mode == "slide" then return 3
        else return 1 end
    end

    local function OpenModeSubcategory(mode)
        if mode == "conveyor" and conveyorCategory then
            Settings.OpenToCategory(conveyorCategory.ID)
        elseif mode == "fade" and fadeCategory then
            Settings.OpenToCategory(fadeCategory.ID)
        elseif mode == "slide" and fadeCategory then
            Settings.OpenToCategory(fadeCategory.ID)
        end
    end

    local function SetValue(value)
        if value == 1 then
            SpellHistoryDB.animationMode = "conveyor"
            OpenModeSubcategory("conveyor")
        elseif value == 2 then
            SpellHistoryDB.animationMode = "fade"
            OpenModeSubcategory("fade")
        elseif value == 3 then
            SpellHistoryDB.animationMode = "slide"
            OpenModeSubcategory("slide")
        end

        SpellHistory:UpdateDisplay()
    end

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, L.ANIMATION_MODE_CONVEYOR, L.ANIMATION_MODE_CONVEYOR_DESC)
        container:Add(2, L.ANIMATION_MODE_FADE,     L.ANIMATION_MODE_FADE_DESC)
        container:Add(3, L.ANIMATION_MODE_SLIDE,    L.ANIMATION_MODE_SLIDE_DESC)
        return container:GetData()
    end

    local defaultValue = 1

    local setting = Settings.RegisterProxySetting(
        category,
        "SPELL_HISTORY_ANIMATION_MODE",
        Settings.VarType.Number,
        L.ANIMATION_MODE,
        defaultValue,
        GetValue,
        SetValue
    )

    Settings.CreateDropdown(category, setting, GetOptions, L.ANIMATION_MODE_DESC)
end

--------------------------------------------------------------------------------
-- Conveyor Subcategory Settings
--------------------------------------------------------------------------------

-- Setting: Animation Duration Slider (Conveyor Belt)
do
    local minValue, maxValue, step = 2, 20, 0.5
    local defaultValue = 8.0

    local function GetValue()
        return SpellHistoryDB.animationDuration or defaultValue
    end

    local function SetValue(value)
        SpellHistoryDB.animationDuration = value
    end

    local setting = Settings.RegisterProxySetting(
        conveyorCategory,
        "SPELL_HISTORY_ANIMATION_DURATION",
        Settings.VarType.Number,
        L.ANIMATION_DURATION,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.1fs", value)
    end)

    Settings.CreateSlider(conveyorCategory, setting, options, L.ANIMATION_DURATION_DESC)
end


--------------------------------------------------------------------------------
-- Fade Subcategory Settings
--------------------------------------------------------------------------------

-- Setting: Fade In Duration Slider
do
    local minValue, maxValue, step = 0, 2, 0.1
    local defaultValue = 0.3

    local function GetValue()
        return SpellHistoryDB.animationFadeIn or defaultValue
    end

    local function SetValue(value)
        SpellHistoryDB.animationFadeIn = value
    end

    local setting = Settings.RegisterProxySetting(
        fadeCategory,
        "SPELL_HISTORY_ANIMATION_FADE_IN",
        Settings.VarType.Number,
        L.ANIMATION_FADE_IN,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.1fs", value)
    end)

    Settings.CreateSlider(fadeCategory, setting, options, L.ANIMATION_FADE_IN_DESC)
end

-- Setting: Display Duration Slider
do
    local minValue, maxValue, step = 1, 30, 0.5
    local defaultValue = 5.0

    local function GetValue()
        return SpellHistoryDB.animationDisplayTime or defaultValue
    end

    local function SetValue(value)
        SpellHistoryDB.animationDisplayTime = value
    end

    local setting = Settings.RegisterProxySetting(
        fadeCategory,
        "SPELL_HISTORY_ANIMATION_DISPLAY_TIME",
        Settings.VarType.Number,
        L.ANIMATION_DISPLAY_TIME,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.1fs", value)
    end)

    Settings.CreateSlider(fadeCategory, setting, options, L.ANIMATION_DISPLAY_TIME_DESC)
end

-- Setting: Fade Out Duration Slider
do
    local minValue, maxValue, step = 0, 3, 0.1
    local defaultValue = 0.5

    local function GetValue()
        return SpellHistoryDB.animationFadeOut or defaultValue
    end

    local function SetValue(value)
        SpellHistoryDB.animationFadeOut = value
    end

    local setting = Settings.RegisterProxySetting(
        fadeCategory,
        "SPELL_HISTORY_ANIMATION_FADE_OUT",
        Settings.VarType.Number,
        L.ANIMATION_FADE_OUT,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.1fs", value)
    end)

    Settings.CreateSlider(fadeCategory, setting, options, L.ANIMATION_FADE_OUT_DESC)
end

--------------------------------------------------------------------------------
-- Slide Subcategory Settings
--------------------------------------------------------------------------------

-- Setting: Drive In/Out Distance Slider
do
    local minValue, maxValue, step = 0, 2.0, 0.1
    local defaultValue = 0.5

    local function GetValue()
        return SpellHistoryDB.animationSlideDist or defaultValue
    end

    local function SetValue(value)
        SpellHistoryDB.animationSlideDist = value
    end

    local setting = Settings.RegisterProxySetting(
        fadeCategory,
        "SPELL_HISTORY_ANIMATION_SLIDE_DIST",
        Settings.VarType.Number,
        L.ANIMATION_SLIDE_DIST,
        defaultValue,
        GetValue,
        SetValue
    )

    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage)

    Settings.CreateSlider(fadeCategory, setting, options, L.ANIMATION_SLIDE_DIST_DESC)
end

--------------------------------------------------------------------------------
-- Button: Reset Position (Main Category)
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
-- Button: Clear History (Main Category)
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
-- Register Category (Main + Subcategories are included automatically)
--------------------------------------------------------------------------------
Settings.RegisterAddOnCategory(category)