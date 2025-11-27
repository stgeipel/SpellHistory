# Changelog

All notable changes to Spell History will be documented in this file.

## [1.0.0] - 2025-11-27

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
