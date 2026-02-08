# Changelog

All notable changes to Spell History will be documented in this file.

## v1.3.0

### Added

- **Icon Opacity**: New slider to adjust the transparency of spell icons (0-100%)
- **Toggle Tooltips**: New option to enable/disable spell tooltips on hover

### Changed

- **Refactored Localization System**: All translations are now in separate locale files (`locales/enEN.lua`, `locales/deDE.lua`)
- Improved code organization and maintainability

---

## v1.2.0

### Improvements

- **Only player-initiated spells** are now tracked
  SpellHistory now displays only spells that were actively cast by the player.
  Internal trigger, proc, or follow-up spells (e.g. Living Flame triggered by Chrono Flames) are no longer recorded.

### Bug Fixes

Improved duplicate prevention system

- Resolved an issue where certain spells were incorrectly duplicated in the history
- Enhanced the deduplication logic to better handle edge cases

## v1.1.0

### Added

- **Vertical Orientation**: New option to display the spell bar vertically instead of horizontally
- **Grow Direction**: New setting to control which direction new spells are added
  - Horizontal: Left to Right or Right to Left
  - Vertical: Top to Bottom or Bottom to Top
- Full German and English localization for all new settings

### Changed

- Settings panel now includes orientation and grow direction options

---

## v1.0.0

### Added

- Initial release of Spell History addon
- Visual spell history display with customizable icon size and spacing
- Tracking of successful and interrupted/failed spell casts
- Red overlay indicator for interrupted spells
- Movable frame with drag-and-drop functionality
- Lock frame option to prevent accidental movement
- Customizable settings:
  - Number of spells displayed (5-30)
  - Icon size (20-80 pixels)
  - Spacing between icons (0-20 pixels)
  - Background transparency (0-100%)
  - Border visibility toggle
  - Option to hide interrupted spells
- Spell tooltips on hover showing spell details and cast status
- Slash commands: `/spellhistory` (or `/sh`) and `/spellhistory clear`
- Full German and English localization
- Settings panel integration with WoW 12.0 Settings API
- Automatic duplicate cast prevention
- Memory-efficient design with periodic cleanup
- Position saving across sessions

### Technical

- Built for WoW Midnight (12.0+)
- Uses modern WoW 12.0 APIs (C_Spell, Settings API)
- Optimized event handling with castGUID-based deduplication
- BackdropTemplate support for frame borders
- Efficient icon pooling system

### Known Issues

- None reported

---

## Future Plans

- Custom color options for interrupted spells
- Spell category filtering
- Sound alerts for interrupted casts
- Import/Export settings profiles
- Multiple frame support

---

**Note**: This addon is under active development. Feature requests and bug reports are welcome on [GitHub](https://github.com/stgeipel/SpellHistory/issues).
