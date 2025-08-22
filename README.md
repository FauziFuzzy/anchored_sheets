# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## ✨ Features

- 🎯 **Anchor Positioning** - Attach sheets to specific widgets using GlobalKeys
- 📏 **Natural Sizing** - Automatic content-based height with `MainAxisSize.min` support
- 🎨 **Material Design** - Full theming integration with Material 3 support
- 📱 **Status Bar Smart** - Intelligent status bar overlap handling with background extension
- 🖱️ **Drag Support** - Optional drag-to-dismiss with customizable handles
- 🔄 **Context-Free Dismissal** - Dismiss from anywhere without BuildContext
- ♿ **Accessibility** - Full screen reader and semantic support
- 🌐 **Platform Aware** - Works seamlessly across iOS, Android, Web, and Desktop

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  anchored_sheets: ^1.0.0
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
            onPressed: () => dismissTopModalSheet(),
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
          onTap: () => dismissTopModalSheet('home'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => dismissTopModalSheet('settings'),
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
  
  // Animation
  Duration animationDuration = const Duration(milliseconds: 300),
  Color overlayColor = Colors.black54,
  
  // Scroll behavior
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
})
```

### `dismissTopModalSheet<T>`

Context-free dismissal function.

```dart
// Dismiss with result
dismissTopModalSheet('result_value');

// Dismiss without result
dismissTopModalSheet();

// From anywhere in your app
void someUtilityFunction() {
  // No BuildContext needed! 🎉
  dismissTopModalSheet('closed_from_utility');
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

### Draggable Sheet

```dart
anchoredSheet(
  context: context,
  enableDrag: true,           // 🖱️ Enable drag to dismiss
  showDragHandle: true,       // Show drag handle
  dragHandleColor: Colors.grey,
  builder: (context) => Container(
    padding: EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Drag me up to dismiss!'),
        SizedBox(height: 20),
        // Your content here
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
              dismissTopModalSheet({
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
        onTap: () => dismissTopModalSheet(filter),
      )).toList(),
    ),
  );
  
  if (result != null) {
    setState(() => selectedFilter = result);
  }
}
```

## 🎯 Advanced Features

### Status Bar Handling

The package automatically handles status bar overlap:

```dart
anchoredSheet(
  context: context,
  useSafeArea: true, // ✅ Respects status bar and notch
  builder: (context) => YourContent(),
);
```

When a sheet would overlap with the status bar, it automatically:
- Extends the background color to cover the status bar
- Maintains proper content positioning
- Preserves smooth animations

### MainAxisSize.min Support

Unlike many modal implementations, anchored_sheets naturally supports `MainAxisSize.min`:

```dart
// ✅ This works perfectly!
Column(
  mainAxisSize: MainAxisSize.min, // Automatically sizes to content
  children: [
    Text('Dynamic content'),
    if (showExtraContent) 
      Text('This appears conditionally'),
    ElevatedButton(
      onPressed: () => dismissTopModalSheet(),
      child: Text('Close'),
    ),
  ],
)
```

### Context-Free Dismissal

Dismiss sheets from anywhere in your app:

```dart
// In a utility class
class NotificationService {
  static void showNotification(String message) {
    anchoredSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => NotificationWidget(message),
    );
    
    // Auto-dismiss after 3 seconds
    Timer(Duration(seconds: 3), () {
      dismissTopModalSheet(); // No context needed! 🎉
    });
  }
}

// In a service class
class ApiService {
  static Future<void> logout() async {
    await _performLogout();
    
    // Dismiss any open sheets
    dismissTopModalSheet();
    
    // Navigate to login
    navigatorKey.currentState?.pushReplacementNamed('/login');
  }
}
```

## 🎨 Theming

### Material 3 Integration

```dart
// In your app theme
ThemeData(
  useMaterial3: true,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),
)

// Sheets automatically inherit theme
anchoredSheet(
  context: context,
  // backgroundColor, elevation, shape inherited from theme
  builder: (context) => YourContent(),
);
```

### Custom Theming

```dart
anchoredSheet(
  context: context,
  backgroundColor: Theme.of(context).colorScheme.surface,
  elevation: 12,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: 1,
    ),
  ),
  builder: (context) => YourContent(),
);
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

### Content getting cut off

**Problem**: Content appears truncated or overlaps status bar.

**Solution**: Use `useSafeArea: true`:

```dart
anchoredSheet(
  context: context,
  useSafeArea: true, // ✅ Respects status bar
  builder: (context) => YourContent(),
);
```

### Animations feel slow

**Problem**: Default animation duration is too long.

**Solution**: Customize animation duration:

```dart
anchoredSheet(
  context: context,
  animationDuration: Duration(milliseconds: 200), // Faster
  builder: (context) => YourContent(),
);
```

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Material Design guidelines
- Built on Flutter's robust animation and layout systems
- Thanks to the Flutter community for feedback and suggestions

## 📧 Support

- 🐛 [File an issue](https://github.com/FauziFuzzy/anchored_sheets/issues)
- 💬 [Start a discussion](https://github.com/FauziFuzzy/anchored_sheets/discussions)
- 📖 [Read the docs](https://pub.dev/packages/anchored_sheets)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/FauziFuzzy">FauziFuzzy</a>
</p>
