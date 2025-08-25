# 🎯 Anchored Sheets

[![Pub Version](https://img.shields.io/pub/v/anchored_sheets?style=flat-square)](https://pub.dev/packages/anchored_sheets)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue?style=flat-square&logo=flutter)](https://flutter.dev)

A Flutter package for creating modal sheets that slide down from the top of the screen, similar to `showModalBottomSheet` but positioned at the top. Perfect for filter menus, notifications, dropdowns, and any content that should appear anchored to specific widgets or screen positions.

## 🎨 Demo
![Anchored Sheets Demo](assets/gifdemo.gif)

## ✨ Features

- 🎯 **Anchor Positioning** - Attach sheets to specific widgets using GlobalKeys
- 🛡️ **Type Safe** - Full type safety with generic support

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

