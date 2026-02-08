--[[
    Spell History - English Localization (Default)
]]

local _, addon = ...

-- Create localization table
SpellHistory = SpellHistory or {}
SpellHistory.L = SpellHistory.L or {}

local L = SpellHistory.L

-- Core strings
L.ADDON_LOADED = "Spell History loaded. Use /spellhistory for settings."
L.POSITION_RESET = "Position has been reset."
L.HISTORY_CLEARED = "History has been cleared."
L.INTERRUPTED = "Interrupted"
L.SUCCEEDED = "Succeeded"
L.CMD_HELP = "Commands:"
L.CMD_CONFIG = "Opens settings"
L.CMD_CLEAR = "Clears history"

-- Config strings
L.SECTION_GENERAL = "General & Appearance"
L.SECTION_BEHAVIOR = "Behavior & Filters"
L.SECTION_LAYOUT = "Layout"
L.SECTION_ANIMATION = "Animation"

L.MAX_SPELLS = "Number of Spells"
L.MAX_SPELLS_DESC = "Sets how many spells are displayed in the history"
L.ICON_SIZE = "Icon Size"
L.ICON_SIZE_DESC = "Sets the size of the spell icons"
L.SPACING = "Spacing between Icons"
L.SPACING_DESC = "Sets the spacing between icons"
L.LOCK_FRAME = "Lock Frame"
L.LOCK_FRAME_DESC = "Prevents moving the frame"
L.SHOW_BORDER = "Show Border"
L.SHOW_BORDER_DESC = "Shows a border around the frame"
L.BG_ALPHA = "Background Opacity"
L.BG_ALPHA_DESC = "Sets background opacity (0 = transparent, 1 = opaque)"
L.ICON_ALPHA = "Icon Opacity"
L.ICON_ALPHA_DESC = "Sets the opacity of spell icons (0 = transparent, 1 = opaque)"
L.SHOW_INTERRUPTED = "Show Interrupted Spells"
L.SHOW_INTERRUPTED_DESC = "Shows interrupted/failed spells in the history"
L.HIDE_PROFESSIONS = "Hide Profession Spells"
L.HIDE_PROFESSIONS_DESC = "Hides spells from professions (Blacksmithing, Alchemy, etc.)"
L.VERTICAL_ORIENTATION = "Vertical Orientation"
L.VERTICAL_ORIENTATION_DESC = "Displays icons vertically instead of horizontally"
L.GROW_DIRECTION = "Grow Direction"
L.GROW_DIRECTION_DESC = "Direction in which new icons are added"
L.GROW_NORMAL = "Normal"
L.GROW_NORMAL_DESC_H = "Left to Right (newest on left)"
L.GROW_NORMAL_DESC_V = "Top to Bottom (newest on top)"
L.GROW_REVERSE = "Reverse"
L.GROW_REVERSE_DESC_H = "Right to Left (newest on right)"
L.GROW_REVERSE_DESC_V = "Bottom to Top (newest on bottom)"
L.RESET_POSITION = "Reset Position"
L.RESET_POSITION_DESC = "Resets the frame position to screen center"
L.CLEAR_HISTORY = "Clear History"
L.CLEAR_HISTORY_DESC = "Clears all entries from spell history"
L.SHOW_TOOLTIPS = "Show Tooltips"
L.SHOW_TOOLTIPS_DESC = "Shows spell tooltips when hovering over icons"

-- Animation settings
L.ANIMATION_HEADER = "Animation"
L.ANIMATION_ENABLED = "Enable Animation"
L.ANIMATION_ENABLED_DESC = "Enable spell icon animations"
L.ANIMATION_MODE = "Animation Mode"
L.ANIMATION_MODE_DESC = "Choose the animation style"
L.ANIMATION_MODE_CONVEYOR = "Conveyor Belt"
L.ANIMATION_MODE_CONVEYOR_DESC = "Icons travel across the bar and fade out at the end"
L.ANIMATION_MODE_FADE = "Fade In/Out (Static)"
L.ANIMATION_MODE_FADE_DESC = "Icons fade in and out without moving"
L.ANIMATION_MODE_SLIDE = "Slide In/Out"
L.ANIMATION_MODE_SLIDE_DESC = "Icons slide in, stay visible, then slide out"

-- Conveyor mode settings
L.ANIMATION_CONVEYOR_HEADER = "Conveyor Belt Settings"
L.ANIMATION_DURATION = "Travel Duration"
L.ANIMATION_DURATION_DESC = "Time in seconds for icons to travel across the entire bar"
L.ANIMATION_FADE_START = "Fade Start Point"
L.ANIMATION_FADE_START_DESC = "Position along the bar where icons start fading out (50% = halfway)"

-- Fade mode settings
L.ANIMATION_FADE_HEADER = "Fade & Slide Settings"
L.ANIMATION_FADE_IN = "Fade In Duration"
L.ANIMATION_FADE_IN_DESC = "Time in seconds for icons to fade in"
L.ANIMATION_DISPLAY_TIME = "Display Duration"
L.ANIMATION_DISPLAY_TIME_DESC = "Time in seconds icons stay visible before fading out"
L.ANIMATION_FADE_OUT = "Fade Out Duration"
L.ANIMATION_FADE_OUT_DESC = "Time in seconds for icons to fade out"
L.ANIMATION_SLIDE_DIST = "Drive In/Out Distance"
L.ANIMATION_SLIDE_DIST_DESC = "Distance icons move during fade in/out (as % of icon size)"
