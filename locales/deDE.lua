--[[
    Spell History - German Localization
]]

local _, addon = ...

-- Only load for German clients
if GetLocale() ~= "deDE" then return end

SpellHistory = SpellHistory or {}
SpellHistory.L = SpellHistory.L or {}

local L = SpellHistory.L

-- Core strings
L.ADDON_LOADED = "Spell History geladen. Nutze /spellhistory für Einstellungen."
L.POSITION_RESET = "Position wurde zurückgesetzt."
L.HISTORY_CLEARED = "Historie wurde gelöscht."
L.INTERRUPTED = "Abgebrochen"
L.SUCCEEDED = "Erfolgreich"
L.CMD_HELP = "Befehle:"
L.CMD_CONFIG = "Öffnet Einstellungen"
L.CMD_CLEAR = "Löscht Historie"

-- Config strings
L.SECTION_GENERAL = "Allgemein & Aussehen"
L.SECTION_BEHAVIOR = "Verhalten & Filter"
L.SECTION_LAYOUT = "Layout"
L.SECTION_ANIMATION = "Animation"

L.MAX_SPELLS = "Anzahl der Spells"
L.MAX_SPELLS_DESC = "Legt fest, wie viele Spells in der Historie angezeigt werden"
L.ICON_SIZE = "Icon-Größe"
L.ICON_SIZE_DESC = "Legt die Größe der Spell-Icons fest"
L.SPACING = "Abstand zwischen Icons"
L.SPACING_DESC = "Legt den Abstand zwischen den Icons fest"
L.LOCK_FRAME = "Fenster sperren"
L.LOCK_FRAME_DESC = "Verhindert das Verschieben des Fensters"
L.SHOW_BORDER = "Rahmen anzeigen"
L.SHOW_BORDER_DESC = "Zeigt einen Rahmen um das Fenster an"
L.BG_ALPHA = "Hintergrund-Deckkraft"
L.BG_ALPHA_DESC = "Legt die Deckkraft des Hintergrunds fest (0 = durchsichtig, 1 = undurchsichtig)"
L.ICON_ALPHA = "Icon-Deckkraft"
L.ICON_ALPHA_DESC = "Legt die Deckkraft der Spell-Icons fest (0 = durchsichtig, 1 = undurchsichtig)"
L.SHOW_INTERRUPTED = "Abgebrochene Zauber anzeigen"
L.SHOW_INTERRUPTED_DESC = "Zeigt abgebrochene/fehlgeschlagene Zauber in der Historie an"
L.HIDE_PROFESSIONS = "Berufe-Zauber ausblenden"
L.HIDE_PROFESSIONS_DESC = "Blendet Zauber von Berufen (Schmiedekunst, Alchemie, etc.) aus"
L.VERTICAL_ORIENTATION = "Vertikale Ausrichtung"
L.VERTICAL_ORIENTATION_DESC = "Zeigt die Icons vertikal statt horizontal an"
L.GROW_DIRECTION = "Wachstumsrichtung"
L.GROW_DIRECTION_DESC = "Richtung in die neue Icons hinzugefügt werden"
L.GROW_NORMAL = "Normal"
L.GROW_NORMAL_DESC_H = "Links nach Rechts (neueste links)"
L.GROW_NORMAL_DESC_V = "Oben nach Unten (neueste oben)"
L.GROW_REVERSE = "Umgekehrt"
L.GROW_REVERSE_DESC_H = "Rechts nach Links (neueste rechts)"
L.GROW_REVERSE_DESC_V = "Unten nach Oben (neueste unten)"
L.RESET_POSITION = "Position zurücksetzen"
L.RESET_POSITION_DESC = "Setzt die Position des Fensters auf die Bildschirmmitte zurück"
L.CLEAR_HISTORY = "Historie löschen"
L.CLEAR_HISTORY_DESC = "Löscht alle Einträge aus der Spell-Historie"
L.SHOW_TOOLTIPS = "Tooltips anzeigen"
L.SHOW_TOOLTIPS_DESC = "Zeigt Zauber-Tooltips beim Überfahren der Icons an"

-- Animation settings
L.ANIMATION_HEADER = "Animation"
L.ANIMATION_ENABLED = "Animation aktivieren"
L.ANIMATION_ENABLED_DESC = "Aktiviert Zauber-Icon Animationen"
L.ANIMATION_MODE = "Animations-Modus"
L.ANIMATION_MODE_DESC = "Wähle den Animations-Stil"
L.ANIMATION_MODE_CONVEYOR = "Förderband"
L.ANIMATION_MODE_CONVEYOR_DESC = "Icons wandern über die Leiste und blenden am Ende aus"
L.ANIMATION_MODE_FADE = "Ein-/Ausblenden (Statisch)"
L.ANIMATION_MODE_FADE_DESC = "Icons blenden ein und aus, ohne sich zu bewegen"
L.ANIMATION_MODE_SLIDE = "Einfahren (Slide)"
L.ANIMATION_MODE_SLIDE_DESC = "Icons fahren ein, bleiben sichtbar und fahren dann aus"

-- Förderband-Modus Einstellungen
L.ANIMATION_CONVEYOR_HEADER = "Förderband-Einstellungen"
L.ANIMATION_DURATION = "Laufzeit"
L.ANIMATION_DURATION_DESC = "Zeit in Sekunden, bis ein Icon die gesamte Leiste durchlaufen hat"
L.ANIMATION_FADE_START = "Ausblend-Startpunkt"
L.ANIMATION_FADE_START_DESC = "Position auf der Leiste, ab der Icons ausblenden (50% = Mitte)"

-- Fade-Modus Einstellungen
L.ANIMATION_FADE_HEADER = "Fade- & Slide-Einstellungen"
L.ANIMATION_FADE_IN = "Einblendzeit"
L.ANIMATION_FADE_IN_DESC = "Zeit in Sekunden für das Einblenden der Icons"
L.ANIMATION_DISPLAY_TIME = "Anzeigedauer"
L.ANIMATION_DISPLAY_TIME_DESC = "Zeit in Sekunden, die Icons sichtbar bleiben bevor sie ausblenden"
L.ANIMATION_FADE_OUT = "Ausblendzeit"
L.ANIMATION_FADE_OUT_DESC = "Zeit in Sekunden für das Ausblenden der Icons"
L.ANIMATION_SLIDE_DIST = "Drive In/Out Distanz"
L.ANIMATION_SLIDE_DIST_DESC = "Distanz, die Icons beim Ein-/Ausblenden zurücklegen (in % der Icon-Größe)"
