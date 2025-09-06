# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## 🎨 Demo
![Anchored Sheets Demo](assets/gifdemo.gif)

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  anchored_sheets: ^1.2.12
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Add AnchoredObserver

add anchoredObserver on materialApp

```dart
   return MaterialApp(
      title: 'Anchored Sheets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorObservers: [anchoredObserver],
      home: const AnchoredSheetsDemo(),
    );
```

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
### `context.popAnchorShee<T>`

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

