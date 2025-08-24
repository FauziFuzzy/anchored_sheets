# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## 🎨 Demo
![Anchored Sheets Demo](assets/gifdemo.gif)

## ✨ Features

- 🎯 **Anchor Positioning** - Attach sheets to specific widgets using GlobalKeys
- 🎨 **Material Design** - Full theming integration with Material 3 support
- 📱 **Status Bar Smart** - Intelligent status bar overlap handling with background extension
- 🖱️ **Drag Support** - Optional drag-to-dismiss with customizable handles
- 🔄 **Easy Dismissal** - Simple `context.popAnchoredSheet()` method for closing sheets
- 🚀 **Provider Ready** - Built-in support for state management patterns
- ♿ **Accessibility** - Full screen reader and semantic support
- 🛡️ **Type Safe** - Full type safety with generic support
- 🚫 **Duplicate Prevention** - Prevent re-rendering when clicking same button multiple times
- ⚡ **Memory Optimized** - Automatic lifecycle management with Flutter best practices

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  anchored_sheets: ^1.2.1
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:anchored_sheets/anchored_sheets.dart';


### Anchored to Widget

```dart
final GlobalKey buttonKey = GlobalKey();

// In your build method
ElevatedButton(
  key: buttonKey, // 🎯 Anchor point
  onPressed: showAnchoredMenu,
  child: Text('Menu'),
)

// Show anchored sheet
void showAnchoredMenu() async {
  final result = await anchoredSheet<String>(
    context: context,
    anchorKey: buttonKey, // Sheet appears below this button
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () => context.popAnchoredSheet('home'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => context.popAnchoredSheet('settings'),
        ),
      ],
    ),
  );
  
  if (result != null) {
    print('Selected: $result');
  }
}
```

## 📚 API Reference

### `anchoredSheet<T>`

The main function for displaying anchored sheets.

```dart
Future<T?> anchoredSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  
  // Positioning
  GlobalKey? anchorKey,           // Anchor to specific widget
  double? topOffset,              // Manual top offset
  bool useSafeArea = false,       // Respect status bar/notch
  
  // Styling
  Color? backgroundColor,         // Sheet background color
  double? elevation,              // Material elevation
  ShapeBorder? shape,            // Custom shape
  BorderRadius? borderRadius,     // Corner radius
  Clip? clipBehavior,            // Clipping behavior
  BoxConstraints? constraints,    // Size constraints
  
  // Interaction
  bool isDismissible = true,      // Tap outside to dismiss
  bool enableDrag = false,        // Drag to dismiss
  bool? showDragHandle,          // Show drag handle
  Color? dragHandleColor,        // Handle color
  Size? dragHandleSize,          // Handle size
  bool toggleOnDuplicate = true,  // Dismiss when same anchor is used
  
  // Sheet Management (NEW in v1.2.0)
  bool replaceSheet = true,       // Auto-replace existing sheets
  bool dismissOtherModals = false, // Dismiss other modals first
  
  // Animation
  Duration animationDuration = const Duration(milliseconds: 300),
  Color overlayColor = Colors.black54,
  
  // Scroll behavior
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
})
```

## 🆕 What's New in v1.2.3
- Added LIFO method where dismissed top anchoredsheet if stacked.

## 🆕 What's New in v1.2.2
- simplification

## 🆕 What's New in v1.2.1

### ⚡ Lifecycle Optimization
- **Automatic Controller Management**: Optimized lifecycle management for animation controllers
- **Memory Efficiency**: Enhanced memory optimization using Flutter lifecycle best practices
- **Performance Focus**: Streamlined to focus primarily on `anchoredSheet` for better performance
- **SafeArea Fix**: Fixed issue with SafeArea bottom padding not working correctly

### 🏗️ Architecture Improvements
- **Modal Manager Optimization**: Streamlined modal manager for better performance
- **Sheet State Management**: Improved sheet state lifecycle management
- **Resource Cleanup**: Enhanced automatic resource cleanup and disposal
- **Type Safety**: Fixed typos and improved type safety across the codebase

### 🔧 Bug Fixes
- **SafeArea Bottom**: Resolved issue where SafeArea bottom padding wasn't applied correctly
- **Memory Leaks**: Fixed potential memory leaks in animation controllers
- **State Management**: Improved state management consistency across different sheet types
- **Performance**: Reduced overhead in sheet creation and disposal

## 🆕 What's New in v1.2.0

### ⚡ Status Bar Animation Performance
- **Eliminated Delay**: Fixed visual delay between status bar background and sheet content
- **Unified Rendering**: Single Material container for synchronized rendering

### 🚫 Smart Duplicate Prevention
- **Anchor-based Intelligence**: Uses existing `anchorKey` to detect duplicate sheet requests
- **Toggle Behavior**: Same button click dismisses sheet, different source replaces it

### 🔄 Automatic Sheet Replacement
- **Default Replacement**: `replaceSheet = true` by default for seamless UX
- **Smooth Transitions**: 50ms optimized delay for perfect timing
- **Context Safety**: Automatic `context.mounted` checks prevent errors
- **Backward Compatible**: Existing code works without changes

### 🎛️ Enhanced Modal Management
- **Multi-Modal Support**: `dismissOtherModals` parameter for clean slate behavior
- **Bottom Sheet Integration**: Seamlessly handles existing bottom sheets

### 🏗️ Architecture Improvements
- **Anchor Key Tracking**: Intelligent storage and comparison of anchor keys
- **Controller Enhancement**: Better generic type handling and safety

### 🛠️ Developer Experience
- **Cleaner API**: Simplified sheet management without manual configuration
- **Example Updates**: Comprehensive demos showing all new features
- **Documentation**: Updated guides and best practices



### ❌ Don'ts
```dart
// ❌ Don't use Navigator.pop() directly
Navigator.of(context).pop(); // Can cause issues

// ❌ Don't manage state manually when using Provider
setState(() {
  // Let Provider handle state updates
});

// ❌ Don't forget to handle async gaps
// Use if (mounted) checks when needed
```

## 🔄 Migration Guide

### From v1.2.0 to v1.2.1

**Good News**: No breaking changes! All existing code continues to work with improved performance.

**Automatic Improvements** (no code changes needed):
```dart
// Your existing code now runs with optimized lifecycle management
anchoredSheet(
  context: context,
  builder: (context) => YourContent(),
);
```
<!-- ## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests. -->

## 🙏 Acknowledgments

- Inspired by Material Design guidelines
- Built on Flutter's robust animation and layout systems
- Thanks to the Flutter community for feedback and suggestions
- Special thanks to contributors helping improve performance and lifecycle management

## 📧 Support

- 📖 [Read the docs](https://pub.dev/packages/anchored_sheets)
- 🐛 [Report issues](https://github.com/FauziFuzzy/anchored_sheets/issues)

---

**Made with ❤️ for the Flutter community**

