# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.2.9] - 2025-08-27
- Fixed scrolling content for overflowed.

## [1.2.8] - 2025-08-27
- Added InheritedTheme.captureAll() to bridge context
- Remove toggleduplicate, dismissothermodal and replacesheet optional and make it automatically.

## [1.2.7] - 2025-08-27
- Added new navigation context.popAnchorAndNavigate()
- Added new navigation context.navigateAndReopenAnchor()
- Update readme.md

## [1.2.6] - 2025-08-25
- Fixed pop with values

## [1.2.5] - 2025-08-25
- Fixed extra space on drag handle
- Removed gap anchoredsheet with statusbar.

## [1.2.4] - 2025-08-25
- Simplify readme.md

## [1.2.3] - 2025-08-25
- Checks if stacked anchoredsheet
- Added LIFO method to dismissed top stacked anchored.

## [1.2.2] - 2025-08-24
- Remove default documentation

## [1.2.1] - 2025-08-24
- Optimize lifecycle automatically controller, modal_manager, sheet_state.
- Use flutter lifecycle for memory optimization.
- Mainly focus on anchoredSheet instead of others.
- Fixed issue where safeArea bottom.
- Fixed typo

## [1.2.0] - 2025-08-23

### 🚫 Added - Smart Duplicate Prevention
- **Anchor-based Intelligence**: Automatically prevents duplicate sheets using existing `anchorKey` parameter
- **Zero Configuration**: Works without requiring manual sheet IDs or additional setup
- **Smart Toggle Behavior**: Same anchor key dismisses current sheet, different anchor key replaces it
- **Backward Compatible**: Existing code works unchanged with new intelligent behavior

### 🔄 Added - Automatic Sheet Replacement
- **Default Replacement**: `replaceSheet = true` by default for seamless user experience
- **Optimized Timing**: Reduced transition delay to 16ms for smoother animations
- **Context Safety**: Added automatic `context.mounted` checks to prevent memory leaks
- **Graceful Transitions**: Smooth dismissal and re-opening with proper state management

### 🎛️ Added - Enhanced Modal Management  
- **Multi-Modal Support**: New `dismissOtherModals` parameter for comprehensive modal handling
- **Bottom Sheet Integration**: Seamlessly dismisses existing bottom sheets before showing anchored sheets
- **Dialog Compatibility**: Properly handles alert dialogs and custom dialogs
- **Smart Coexistence**: SnackBars and material banners can coexist when appropriate

### 🚀 Fixed - Status Bar Animation Performance
- **Eliminated Delay**: Fixed visual delay between status bar background and sheet content during animations
- **Unified Rendering**: Implemented single Material container for synchronized status bar and content rendering
- **Optimized Timing**: Reduced all animation delays from 50-200ms to 16ms (single frame timing at 60fps)
- **Smooth Transitions**: Enhanced animation responsiveness from 250ms/200ms to 220ms/180ms for enter/exit
- **Better Performance**: Eliminated multiple small delays that accumulated to create noticeable lag

### 🏗️ Enhanced - Architecture Improvements
- **Anchor Key Tracking**: New controller system tracks current anchor keys for intelligent comparison
- **Enhanced Controller Management**: Added `getCurrentAnchorKey()` and improved `setCurrentController()` with anchor tracking
- **Memory Optimization**: Automatic cleanup of anchor key references when sheets are dismissed
- **Type Safety**: Improved generic type handling for better compile-time safety

### 🔧 Enhanced - Developer Experience
- **Cleaner API**: New features work automatically without requiring API changes
- **Better Error Handling**: Enhanced debugging information for development
- **Performance Optimized**: Faster sheet transitions and reduced memory footprint
- **Example App**: Updated comprehensive demo showcasing all new features

### Technical Details
- Added `_currentAnchorKey` tracking in `anchored_controller.dart`
- Enhanced `setCurrentController()` to accept optional `GlobalKey` parameter
- Implemented intelligent duplicate detection based on anchor key comparison
- Optimized animation timing for better perceived performance
- Added comprehensive modal dismissal management via `AnchoredSheetModalManager`

### Migration Guide
No breaking changes - existing code continues to work. New features are enabled by default:
- `replaceSheet: true` - Automatic sheet replacement (was default false)
- Smart duplicate prevention works automatically with existing `anchorKey` usage
- `dismissOtherModals: false` - Opt-in modal management when needed

## [1.1.3] - 2025-08-22

### Fixed
- **Type Safety**: Fixed `_TypeError` when casting between different `GenericModalController` types
  - Resolved issue where `GenericModalController<String>` could not be cast to `GenericModalController<bool>?`
  - Implemented type-safe checking in `getCurrentController()` and `getCurrentState()` methods
  - Made controller dismissal work regardless of generic type parameters
- **Context-based Dismissal**: Fixed `context.popAnchorSheet()` not working properly
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
  - `context.popAnchorSheet()` is now the primary recommended method for dismissing sheets
  - `dismissAnchoredSheet()` is kept for backward compatibility but no longer preferred
  - Updated all examples and documentation to use the new pattern
  - Improved fallback handling for dismissal methods

### Updated
- All example code now uses `context.popAnchorSheet()`
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
  - `context.popAnchorSheet()` - Context-free dismissal function
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
