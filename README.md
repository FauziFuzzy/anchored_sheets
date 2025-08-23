# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## 🎨 Demo
![Demo](https://imgur.com/a/lorem-5YedApP)

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

// Simple sheet from top
void showBasicSheet() {
  anchoredSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Automatically sized!
        children: [
          Icon(Icons.info, size: 48),
          SizedBox(height: 16),
          Text('Hello from top sheet!'),
          ElevatedButton(
            onPressed: () => context.popAnchoredSheet(),
            child: Text('Close'),
          ),
        ],
      ),
    ),
  );
}
```

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

### `context.popAnchoredSheet<T>`

Context-based dismissal function (preferred).

```dart
// Dismiss with result
context.popAnchoredSheet('result_value');

// Dismiss without result
context.popAnchoredSheet();

// From BuildContext extension
void someFunction(BuildContext context) {
  context.popAnchoredSheet('closed_from_context');
}
```

## 🎨 Examples

### Styled Sheet

```dart
anchoredSheet(
  context: context,
  backgroundColor: Colors.purple.shade50,
  elevation: 10,
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(24),
  ),
  builder: (context) => Container(
    padding: EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.palette, size: 48, color: Colors.purple),
        SizedBox(height: 16),
        Text('Custom Styled Sheet'),
      ],
    ),
  ),
);
```

### Form Sheet with Return Value

```dart
void showFormSheet() async {
  final Map<String, dynamic>? result = await anchoredSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FormSheetWidget(),
  );
  
  if (result != null) {
    print('Form data: ${result['name']}, ${result['email']}');
  }
}

class FormSheetWidget extends StatefulWidget {
  @override
  _FormSheetWidgetState createState() => _FormSheetWidgetState();
}

class _FormSheetWidgetState extends State<FormSheetWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.popAnchoredSheet({
                'name': _nameController.text,
                'email': _emailController.text,
              });
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Smart Sheet Management (NEW!)

```dart
class SmartSheetDemo extends StatelessWidget {
  final GlobalKey menuKey = GlobalKey();
  final GlobalKey filterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Menu button with smart toggle
          IconButton(
            key: menuKey,
            icon: Icon(Icons.menu),
            onPressed: () => showMenuSheet(context),
          ),
          // Filter button with smart replacement
          IconButton(
            key: filterKey,
            icon: Icon(Icons.filter_list),
            onPressed: () => showFilterSheet(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showRegularSheet(context),
          child: Text('Show Regular Sheet'),
        ),
      ),
    );
  }

  void showMenuSheet(BuildContext context) {
    // Smart behavior:
    // 1st click: Shows menu
    // 2nd click: Dismisses menu (same anchor key)
    // After filter is open, clicking this replaces filter with menu
    anchoredSheet(
      context: context,
      anchorKey: menuKey, // Smart anchor-based detection
      builder: (context) => MenuContent(),
    );
  }

  void showFilterSheet(BuildContext context) {
    // Smart behavior:
    // Replaces any existing sheet (different anchor key)
    // Automatically dismisses other modals if needed
    anchoredSheet(
      context: context,
      anchorKey: filterKey,
      dismissOtherModals: true, // Clean slate approach
      builder: (context) => FilterContent(),
    );
  }

  void showRegularSheet(BuildContext context) {
    // Smart behavior:
    // Always replaces existing sheets (no anchor key)
    anchoredSheet(
      context: context,
      builder: (context) => RegularContent(),
    );
  }
}
```

### Filter Menu

```dart
final GlobalKey filterButtonKey = GlobalKey();
String selectedFilter = 'All';

Widget buildFilterButton() {
  return ElevatedButton.icon(
    key: filterButtonKey,
    onPressed: showFilterMenu,
    icon: Icon(Icons.filter_list),
    label: Text('Filter: $selectedFilter'),
  );
}

void showFilterMenu() async {
  final String? result = await anchoredSheet<String>(
    context: context,
    anchorKey: filterButtonKey,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        'All', 'Recent', 'Favorites', 'Archived'
      ].map((filter) => ListTile(
        title: Text(filter),
        trailing: selectedFilter == filter ? Icon(Icons.check) : null,
        onTap: () => context.popAnchoredSheet(filter),
      )).toList(),
    ),
  );
  
  if (result != null) {
    setState(() => selectedFilter = result);
  }
}
```



## 🔧 Migration Guide

### From showModalBottomSheet

```dart
// Before (showModalBottomSheet)
showModalBottomSheet(
  context: context,
  builder: (context) => YourContent(),
);

// After (anchored_sheets)
anchoredSheet(
  context: context,
  builder: (context) => YourContent(),
);
```

The API is intentionally similar to `showModalBottomSheet` for easy migration.

### From other top sheet packages

Most parameters map directly:

```dart
// Other packages
showTopSheet(
  context: context,
  child: YourContent(),
);

// anchored_sheets
anchoredSheet(
  context: context,
  builder: (context) => YourContent(),
);
```

## 🐛 Troubleshooting

### Sheet not sizing correctly

**Problem**: Sheet takes full height instead of sizing to content.

**Solution**: Use `MainAxisSize.min` in your Column:

```dart
// ❌ Don't do this
Column(
  children: [...], // Takes full height
)

// ✅ Do this instead
Column(
  mainAxisSize: MainAxisSize.min, // Sizes to content
  children: [...],
)
```

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
- **Dialog Compatibility**: Works with alert dialogs and custom dialogs
- **SnackBar Coexistence**: Smart handling of persistent UI elements

### 🏗️ Architecture Improvements
- **Anchor Key Tracking**: Intelligent storage and comparison of anchor keys
- **Controller Enhancement**: Better generic type handling and safety
- **Performance Optimization**: Reduced animation times and smoother transitions
- **Memory Management**: Automatic cleanup of tracking variables

### 🛠️ Developer Experience
- **Cleaner API**: Simplified sheet management without manual configuration
- **Example Updates**: Comprehensive demos showing all new features
- **Documentation**: Updated guides and best practices

## 🏆 Best Practices

### ✅ Do's
```dart
// ✅ Use context.popAnchoredSheet() for dismissal
ElevatedButton(
  onPressed: () => context.popAnchoredSheet('result'),
  child: Text('Close'),
)

// ✅ Use Provider for state management
Consumer<AppState>(
  builder: (context, state, child) => YourWidget(),
)

// ✅ Set useSafeArea for proper status bar handling
anchoredSheet(
  context: context,
  useSafeArea: true,
  builder: (context) => YourContent(),
)

// ✅ Use MainAxisSize.min for auto-sizing
Column(
  mainAxisSize: MainAxisSize.min,
  children: [...],
)
```

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
// Now has better memory optimization and SafeArea handling
```

**SafeArea Fix** (automatic):
```dart
// This now works correctly without any changes
anchoredSheet(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (context) => YourContent(),
);
```

### From v1.1.x to v1.2.x

**New Defaults** (automatically enabled):
```dart
// Before v1.2.0
anchoredSheet(
  context: context,
  replaceSheet: false, // Was default
  builder: (context) => YourContent(),
);

// After v1.2.0 (automatic improvement)
anchoredSheet(
  context: context,
  replaceSheet: true, // Now default - better UX
  builder: (context) => YourContent(),
);
```


### From v1.0.x to v1.2.x

The API is mostly backwards compatible, but we recommend these updates:

```dart
// Old (still works)
dismissAnchoredSheet('result');

// New (recommended)
context.popAnchoredSheet('result');
```

### Adding Provider Support

```dart
// 1. Add provider dependency
dependencies:
  provider: ^6.1.2

// 2. Update your main app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

// 3. Use Consumer in your sheets
Consumer<AppState>(
  builder: (context, appState, child) {
    return YourSheetContent(
      onChanged: (value) => appState.updateValue(value),
    );
  },
)
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

