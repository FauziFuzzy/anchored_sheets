# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-08-22

### Added
- 📝 **Comprehensive documentation** - Detailed README with examples and API reference
- 🧪 **Widget testing support** - Complete test suite with helper functions
- 🔧 **GitHub Actions CI/CD** - Automated testing and code quality checks
- 📐 **Code formatting compliance** - 80-character line length standards

### Improved
- 🎨 **Documentation clarity** - Enhanced code examples and usage patterns
- 🏗️ **Project structure** - Better organized codebase with comprehensive comments

## [1.0.0] - 2025-08-22

### Added
- 🎯 **Anchor positioning** - Attach modal sheets to specific widgets using GlobalKeys
- 📏 **Height control** - Automatic sizing with overflow constraints like showModalBottomSheet
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
  - `dismissAnchoredSheet()` - Context-free dismissal function
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
