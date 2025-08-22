# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.3] - 2025-08-22

### Fixed
- **Type Safety**: Fixed `_TypeError` when casting between different `GenericModalController` types
  - Resolved issue where `GenericModalController<String>` could not be cast to `GenericModalController<bool>?`
  - Implemented type-safe checking in `getCurrentController()` and `getCurrentState()` methods
  - Made controller dismissal work regardless of generic type parameters
- **Context-based Dismissal**: Fixed `context.popAnchoredSheet()` not working properly
  - Re-enabled fallback to `dismissAnchoredSheet()` when `ModalDismissProvider` is not found
  - Improved dismissal reliability across different anchored sheet types
- **Provider Integration**: Enhanced state management with Provider pattern
  - Implemented real-time UI updates in anchored sheets
  - Added `AppState` provider for centralized state management
  - Filter sheet now updates UI immediately when selections change

### Added
- **Best Practices Example**: Comprehensive Provider-based state management implementation
  - Reactive UI updates without waiting for sheet dismissal
  - Proper separation of concerns between UI and business logic
  - Material Design 3 integration with proper theming

### Technical Improvements
- Type-safe controller storage and retrieval
- Dynamic type checking to prevent runtime casting errors
- Improved error handling and debugging messages
- Better fallback mechanisms for dismissal operations

## [1.1.2] - 2025-08-22

### Changed
- **BREAKING CHANGE**: Updated dismissal API to prioritize context-based approach
  - `context.popAnchoredSheet()` is now the primary recommended method for dismissing sheets
  - `dismissAnchoredSheet()` is kept for backward compatibility but no longer preferred
  - Updated all examples and documentation to use the new pattern
  - Improved fallback handling for dismissal methods

### Updated
- All example code now uses `context.popAnchoredSheet()`
- Documentation updated to reflect the preferred dismissal approach
- Test files updated to use the new API

## [1.0.0] - 2025-08-22

### Added
- 🎯 **Anchor positioning** - Attach modal sheets to specific widgets using GlobalKeys
- 📏 **Height control** - Automatic sizing with overflow constraints like showModalBottomSheet
- 🎨 **Customizable styling** - Full theming support with Material Design integration
- 👆 **Drag to dismiss** - Optional drag handles and gesture support with configurable thresholds
- 🔄 **Return values** - Get data back when modal is dismissed
- 📱 **Safe area support** - Intelligent status bar handling and device-specific layouts
- ⚡ **Context-free dismissal** - Close modals from anywhere in your code
- 🎭 **Animation control** - Customizable slide and fade animations with duration settings
- 🔧 **Constraint-based architecture** - Flexible sizing with BoxConstraints support
- 🌟 **Status bar intelligence** - Automatic background extension when sheets overlap system UI
- 🎪 **Multiple configuration options** - isDismissible, enableDrag, useSafeArea, and more

### Features
- **Core Functions:**
  - `anchoredSheet()` - Main function to show modal sheets
  - `context.popAnchoredSheet()` - Context-free dismissal function
  - `dismissAnchoredSheetWithContext()` - Context-aware dismissal function

- **Positioning Options:**
  - Anchor to specific widgets using GlobalKey
  - Custom top offset positioning
  - Automatic safe area detection and handling

- **Styling & Theming:**
  - Background color customization
  - Elevation and shadow control
  - Border radius and shape configuration
  - Drag handle styling and visibility

- **Interaction Features:**
  - Tap-to-dismiss on overlay
  - Drag-to-dismiss with velocity detection
  - Configurable dismissal behavior
  - Multiple sheet support with toggle options

- **Layout & Sizing:**
  - Constraint-based sizing system
  - MainAxisSize.min natural sizing
  - Custom BoxConstraints support
  - Status bar background extension

### Documentation
- Comprehensive README with examples and best practices
- API documentation with detailed parameter descriptions
- Migration guides and troubleshooting section
- Example app demonstrating all features

### Testing
- Complete widget test suite with 10+ test cases
- Coverage for all major functionality including:
  - Basic sheet display and dismissal
  - Anchor positioning
  - Drag gesture handling
  - Overlay tap dismissal
  - Custom styling application
  - Constraint handling
  - Safe area behavior

### Technical Implementation
- Built on Flutter's overlay system for optimal performance
- Constraint-based layout following Flutter's showModalBottomSheet pattern
- Automatic resource cleanup and memory management
- Comprehensive error handling and edge case coverage
