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
      height: 200,
      child: Center(
        child: Text('Hello from anchored sheet!'),
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
          onTap: () => context.popAnchorSheet('home'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => context.popAnchorSheet('settings'),
        ),
      ],
    ),
  );
  
  if (result != null) {
    print('Selected: $result');
  }
}
```

## 🧭 Navigation Integration

### Sheet → Navigate → Return Pattern

Perfect for selection flows where you need to navigate from a sheet to another screen and return with a value:

```dart
void showSelectionSheet() async {
  final result = await anchoredSheet<String>(
    context: context,
    anchorKey: buttonKey,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Current selection: ${selectedValue ?? 'None'}'),
        ElevatedButton(
          onPressed: () async {
            // Navigate and automatically reopen sheet with result
            final newValue = await context.popAnchorAndNavigate(
              MaterialPageRoute(
                builder: (context) => SelectionScreen(current: selectedValue),
              ),
            );
            
            if (newValue != null) {
              // Manually reopen with new value
              showSelectionSheet(initialValue: newValue);
            }
          },
          child: Text('Select Value'),
        ),
      ],
    ),
  );
}
```

### Advanced Flow with Automatic Reopening

For even more streamlined flows, use the `navigateAndReopenAnchor` method:

```dart
void showAdvancedFlow() async {
  final result = await context.navigateAndReopenAnchor<String>(
    MaterialPageRoute(builder: (context) => SelectionScreen()),
    sheetBuilder: (selectedValue) => MyCustomSheet(
      value: selectedValue,
      onNavigate: () => _handleNavigation(selectedValue),
    ),
    anchorKey: myButtonKey,
    reopenOnlyIfResult: true, // Only reopen if navigation returned a value
  );
  
  print('Final result: $result');
}
```

## 🔧 Context Extensions

Convenient extension methods for common operations:

```dart
// Close current anchored sheet
context.popAnchorSheet('result');

// Navigate after dismissing sheet
final result = await context.popAnchorAndNavigate(
  MaterialPageRoute(builder: (context) => NextScreen()),
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

