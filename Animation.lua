--[[
    Spell History - Animation System
    Modular animation system supporting multiple animation modes
]]

local addonName, addon = ...

SpellHistory = SpellHistory or {}
SpellHistory.Animation = {}

local Animation = SpellHistory.Animation

--------------------------------------------------------------------------------
-- Easing Functions
--------------------------------------------------------------------------------
Animation.Easing = {
    -- Linear (no easing)
    Linear = function(t)
        return t
    end,

    -- Quadratic ease out (fast start, slow end)
    EaseOutQuad = function(t)
        return 1 - (1 - t) * (1 - t)
    end,

    -- Quadratic ease in (slow start, fast end)
    EaseInQuad = function(t)
        return t * t
    end,

    -- Cubic ease in (slower start, faster end)
    EaseInCubic = function(t)
        return t * t * t
    end,

    -- Conveyor belt easing (slow first half, accelerating second half)
    Conveyor = function(t)
        if t < 0.5 then
            -- First half: slower movement (cover 30% of distance)
            return t * 0.6
        else
            -- Second half: accelerating movement (cover remaining 70% of distance)
            local t2 = (t - 0.5) * 2  -- normalize to 0-1
            local easedT2 = t2 * t2   -- quadratic ease-in (accelerate)
            return 0.3 + (easedT2 * 0.7)
        end
    end,
}

--------------------------------------------------------------------------------
-- Animation Modes
--------------------------------------------------------------------------------
Animation.Modes = {
    -- No animation - static display
    NONE = "none",
    -- Conveyor belt - icons travel across the bar
    CONVEYOR = "conveyor",
    -- Fade in/out - icons fade in, stay, then fade out
    FADE = "fade",
}

--------------------------------------------------------------------------------
-- Animation State Calculator
-- Returns: shouldShow, alpha, positionOffset
--------------------------------------------------------------------------------

-- Conveyor Belt Animation
function Animation:CalculateConveyor(spellData, spellIndex, now, settings)
    local age = spellData.timestamp and (now - spellData.timestamp) or 999
    local duration = settings.animationDuration or 8.0
    local fadeStart = settings.animationFadeStart or 0.5
    local iconAlpha = settings.iconAlpha or 1.0
    local iconSize = settings.iconSize
    local spacing = settings.spacing
    local maxSpells = settings.maxSpells

    -- Total travel distance
    local totalDistance = (iconSize * maxSpells) + (spacing * (maxSpells - 1))
    local slotSize = iconSize + spacing

    -- If animation complete, don't show
    if age >= duration then
        return false, 0, 0
    end

    -- Calculate progress (0 to 1)
    local progress = age / duration

    -- Apply conveyor easing
    local easedProgress = self.Easing.Conveyor(progress)

    -- Base position from easing
    local basePos = easedProgress * totalDistance

    -- Calculate minimum position based on previous spells (prevent overlap)
    -- Each spell needs at least (spellIndex - 1) * slotSize space from start
    local minPos = (spellIndex - 1) * slotSize

    -- Use the maximum of base position and minimum position
    local animatedPos = math.max(basePos, minPos)

    -- Calculate alpha - start fading after fadeStart point
    local currentAlpha = iconAlpha
    if progress > fadeStart then
        local fadeProgress = (progress - fadeStart) / (1.0 - fadeStart)
        -- Smooth fade (quadratic)
        currentAlpha = (1 - (fadeProgress * fadeProgress)) * iconAlpha
    end

    return true, currentAlpha, animatedPos
end

-- Fade In/Out Animation
function Animation:CalculateFade(spellData, spellIndex, now, settings)
    local age = spellData.timestamp and (now - spellData.timestamp) or 999
    local fadeInDuration = settings.animationFadeIn or 0.3
    local displayDuration = settings.animationDisplayTime or 5.0
    local fadeOutDuration = settings.animationFadeOut or 0.5
    local iconAlpha = settings.iconAlpha or 1.0
    local iconSize = settings.iconSize
    local spacing = settings.spacing

    local totalVisibleTime = fadeInDuration + displayDuration + fadeOutDuration

    -- Static position based on index
    local staticPos = (spellIndex - 1) * (iconSize + spacing)

    -- If animation complete, don't show
    if age >= totalVisibleTime then
        return false, 0, staticPos
    end

    local currentAlpha = iconAlpha

    if age < fadeInDuration then
        -- Fade in phase
        local progress = age / fadeInDuration
        currentAlpha = self.Easing.EaseOutQuad(progress) * iconAlpha
    elseif age < fadeInDuration + displayDuration then
        -- Display phase - full alpha
        currentAlpha = iconAlpha
    else
        -- Fade out phase
        local fadeOutProgress = (age - fadeInDuration - displayDuration) / fadeOutDuration
        currentAlpha = (1 - self.Easing.EaseInQuad(fadeOutProgress)) * iconAlpha
    end

    return true, currentAlpha, staticPos
end

-- No Animation (Static)
function Animation:CalculateNone(spellData, spellIndex, now, settings)
    if not settings then
        return false, 0, 0
    end

    local iconAlpha = settings.iconAlpha or 1.0
    local iconSize = settings.iconSize or 40
    local spacing = settings.spacing or 5
    local maxSpells = settings.maxSpells or 10

    -- Only show up to maxSpells
    if spellIndex > maxSpells then
        return false, 0, 0
    end

    local staticPos = (spellIndex - 1) * (iconSize + spacing)
    return true, iconAlpha, staticPos
end

--------------------------------------------------------------------------------
-- Main Animation Calculator
--------------------------------------------------------------------------------
function Animation:Calculate(spellData, spellIndex, now, settings)
    if not settings or not settings.animationEnabled then
        return self:CalculateNone(spellData, spellIndex, now, settings)
    end

    local mode = settings.animationMode or "conveyor"

    if mode == "conveyor" then
        return self:CalculateConveyor(spellData, spellIndex, now, settings)
    elseif mode == "fade" then
        return self:CalculateFade(spellData, spellIndex, now, settings)
    else
        return self:CalculateNone(spellData, spellIndex, now, settings)
    end
end

--------------------------------------------------------------------------------
-- Check if any animations are active
--------------------------------------------------------------------------------
function Animation:HasActiveAnimations(history, now, settings)
    if not settings or not settings.animationEnabled then
        return false
    end

    local mode = settings.animationMode or "conveyor"

    for _, spellData in ipairs(history) do
        if spellData.timestamp then
            local age = now - spellData.timestamp
            local maxAge

            if mode == "conveyor" then
                maxAge = settings.animationDuration or 8.0
            elseif mode == "fade" then
                maxAge = (settings.animationFadeIn or 0.3) +
                         (settings.animationDisplayTime or 5.0) +
                         (settings.animationFadeOut or 0.5)
            else
                return false
            end

            if age < maxAge then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Animation Update Frame
--------------------------------------------------------------------------------
local animationFrame = CreateFrame("Frame")
local animationActive = false

function Animation:StartUpdate()
    if animationActive then return end
    animationActive = true

    animationFrame:SetScript("OnUpdate", function(self, elapsed)
        if not SpellHistoryDB or not SpellHistoryDB.animationEnabled then
            animationActive = false
            self:SetScript("OnUpdate", nil)
            return
        end

        local now = GetTime()
        if Animation:HasActiveAnimations(SpellHistory.history, now, SpellHistoryDB) then
            SpellHistory:UpdateDisplay()
        else
            animationActive = false
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function Animation:StopUpdate()
    animationActive = false
    animationFrame:SetScript("OnUpdate", nil)
end

function Animation:IsActive()
    return animationActive
end
