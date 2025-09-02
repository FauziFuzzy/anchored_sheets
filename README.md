# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## 🎨 Demo
![Anchored Sheets Demo](assets/gifdemo.gif)

## ✨ Features

- 🎯 **Anchor Positioning** - Attach sheets to specific widgets using GlobalKeys
- 🛡️ **Type Safe** - Full type safety with generic support
- 🧭 **Navigation Integration** - Seamless navigation flows with automatic sheet management
- 🔄 **Flow Control** - Built-in patterns for sheet → navigate → return workflows
- 📱 **Context Extensions** - Convenient methods for common navigation patterns

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

// Basic anchored sheet
void showBasicSheet() async {
  final result = await anchoredSheet<String>(
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
            onPressed: () => dismissAnchoredSheet(),
            child: Text('Close'),
          ),
        ],
      ),
    ),
  );
  
  if (result != null) {
    print('Result: $result');
  }
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
})
```

### `dismissTopModalSheet<T>`

Context-free dismissal function.

```dart
// Dismiss with result
context.popAnchorSheet('result_value');

// Dismiss without result
context.popAnchorSheet();

// From anywhere in your app
void someUtilityFunction() {
  // No BuildContext needed! 🎉
  context.popAnchorSheet('closed_from_utility');
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

### Advanced Flow with Automatic Reopening

For even more streamlined flows, use the `navigateAndReopenAnchor` method:

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

## 🔧 Context Extensions

Convenient extension methods for common operations:

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

// Complete flow with automatic sheet management
final result = await context.navigateAndReopenAnchor(
  route,
  sheetBuilder: (value) => MySheet(value: value),
  anchorKey: buttonKey,
);
```

<!-- ## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests. -->

## 🙏 Acknowledgments

- Inspired by Material Design guidelines
- Built on Flutter's robust animation and layout systems
- Thanks to the Flutter community for feedback and suggestions
- Special thanks to contributors helping improve performance, lifecycle management, and navigation patterns

## 📧 Support

- 📖 [Read the docs](https://pub.dev/packages/anchored_sheets)
- 🐛 [Report issues](https://github.com/FauziFuzzy/anchored_sheets/issues)

---

**Made with ❤️ for the Flutter community**

