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

    -- Conveyor belt easing (Linear for smooth flow)
    Conveyor = function(t)
        return t
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
    -- Fade in/out - icons fade in, stay, then fade out (static position)
    FADE = "fade",
    -- Slide in/out - icons slide in, stay, then slide out
    SLIDE = "slide",
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
    local iconSize = settings.iconSize or 40
    local spacing = settings.spacing or 5
    local maxSpells = settings.maxSpells or 10

    -- Total travel distance
    local totalDistance = (iconSize * maxSpells) + (spacing * (maxSpells - 1))
    local slotSize = iconSize + spacing

    -- (Run until icon is fully off screen)
    -- Calculate progress (0 to 1) based on duration
    local progress = age / duration
    
    -- Apply conveyor easing
    local easedProgress = self.Easing.Conveyor(progress)

    -- Base position from easing
    local basePos = easedProgress * totalDistance

    -- Use base position directly for smooth conveyor movement
    local animatedPos = basePos
    
    -- Check if icon has fully left the visible area
    -- (totalDistance + iconSize to ensure it clears the frame/padding)
    if animatedPos > (totalDistance + iconSize + 20) then
        return false, 0, 0
    end

    -- Calculate alpha:
    -- 1. Fade In: Thread in/fade in up to half the icon size (0 to 0.5*size)
    -- 2. "Drive out": Full opacity after that
    -- 3. No Fade Out at the end (User request: "remove fade in fade out")
    
    local currentAlpha = iconAlpha
    local fadeInDist = iconSize * 0.5
    
    if animatedPos < fadeInDist then
        -- Fade in (0 to 1) based on distance covered
        currentAlpha = (animatedPos / fadeInDist) * iconAlpha
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
    local iconSize = settings.iconSize or 40
    local spacing = settings.spacing or 5

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

-- Slide In/Out Animation (previously "Drive In/Out")
function Animation:CalculateSlide(spellData, spellIndex, now, settings)
    local age = spellData.timestamp and (now - spellData.timestamp) or 999
    local fadeInDuration = settings.animationFadeIn or 0.3
    local displayDuration = settings.animationDisplayTime or 5.0
    local fadeOutDuration = settings.animationFadeOut or 0.5
    local iconAlpha = settings.iconAlpha or 1.0
    local iconSize = settings.iconSize or 40
    local spacing = settings.spacing or 5

    local totalVisibleTime = fadeInDuration + displayDuration + fadeOutDuration

    -- Static position based on index (target position)
    local staticPos = (spellIndex - 1) * (iconSize + spacing)

    -- If animation complete, don't show
    if age >= totalVisibleTime then
        return false, 0, staticPos
    end
    
    -- Slide distance for "Drive In/Out" effect (percentage of icon size)
    local slideDist = (settings.animationSlideDist or 0.5) * iconSize
    
    local currentAlpha = iconAlpha
    local animatingPos = staticPos

    if age < fadeInDuration then
        -- Fade in + Drive In
        local progress = age / fadeInDuration
        local ease = self.Easing.EaseOutQuad(progress)
        
        currentAlpha = ease * iconAlpha
        -- Slide in from (staticPos - slideDist) to staticPos
        animatingPos = staticPos - ((1 - ease) * slideDist)
        
    elseif age < fadeInDuration + displayDuration then
        -- Display phase - full alpha, static position
        currentAlpha = iconAlpha
        animatingPos = staticPos
        
    else
        -- Fade out + Drive Out
        local fadeOutProgress = (age - fadeInDuration - displayDuration) / fadeOutDuration
        local ease = self.Easing.EaseInQuad(fadeOutProgress)
        
        currentAlpha = (1 - ease) * iconAlpha
        -- Slide out from staticPos to (staticPos + slideDist)
        animatingPos = staticPos + (ease * slideDist)
    end

    return true, currentAlpha, animatingPos
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
    if settings and settings.animationEnabled == false then
        return self:CalculateNone(spellData, spellIndex, now, settings)
    end

    local mode = settings.animationMode or "conveyor"

    if mode == "conveyor" then
        return self:CalculateConveyor(spellData, spellIndex, now, settings)
    elseif mode == "fade" then
        return self:CalculateFade(spellData, spellIndex, now, settings)
    elseif mode == "slide" then
        return self:CalculateSlide(spellData, spellIndex, now, settings)
    else
        return self:CalculateNone(spellData, spellIndex, now, settings)
    end
end

--------------------------------------------------------------------------------
-- Check if any animations are active
--------------------------------------------------------------------------------
function Animation:HasActiveAnimations(history, now, settings)
    if settings and settings.animationEnabled == false then
        return false
    end

    local mode = settings.animationMode or "conveyor"

    for _, spellData in ipairs(history) do
        if spellData.timestamp then
            local age = now - spellData.timestamp
            local maxAge

            if mode == "conveyor" then
                maxAge = settings.animationDuration or 8.0
            elseif mode == "fade" or mode == "slide" then
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
        if not SpellHistoryDB or SpellHistoryDB.animationEnabled == false then
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
