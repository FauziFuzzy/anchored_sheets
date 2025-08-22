import 'package:anchored_sheets/anchored_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to properly show a sheet in tests
/// The overlay system needs extra pump cycles to be built correctly in tests
Future<void> showSheetInTest(WidgetTester tester, String buttonText) async {
  await tester.tap(find.text(buttonText));
  await tester.pump(); // Initial pump to trigger the callback

  // Add more pump cycles to ensure the overlay is built
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Basic anchored sheet shows and dismisses correctly',
      (WidgetTester tester) async {
    bool sheetShown = false;
    String? returnValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                sheetShown = true;
                returnValue = await anchoredSheet<String>(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Test Sheet'),
                        ElevatedButton(
                          onPressed: () => dismissAnchoredSheet('test_result'),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Show Sheet'),
            ),
          ),
        ),
      ),
    );

    // Show the sheet
    await showSheetInTest(tester, 'Show Sheet');

    expect(sheetShown, isTrue);

    // Verify sheet content is displayed
    expect(find.text('Test Sheet'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Tap close button
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify sheet is dismissed and return value is correct
    expect(find.text('Test Sheet'), findsNothing);
    expect(returnValue, equals('test_result'));
  });

  testWidgets('Anchored sheet with anchor key positions correctly',
      (WidgetTester tester) async {
    final GlobalKey anchorKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test App'),
            actions: [
              ElevatedButton(
                key: anchorKey,
                onPressed: () {},
                child: const Text('Anchor'),
              ),
            ],
          ),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                anchoredSheet(
                  context: context,
                  anchorKey: anchorKey,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text('Anchored Content'),
                  ),
                );
              },
              child: const Text('Show Anchored Sheet'),
            ),
          ),
        ),
      ),
    );

    // Show the anchored sheet
    await showSheetInTest(tester, 'Show Anchored Sheet');

    // Verify anchored content is displayed
    expect(find.text('Anchored Content'), findsOneWidget);

    // The sheet should be positioned below the anchor button
    final anchorFinder = find.byKey(anchorKey);
    final sheetFinder = find.text('Anchored Content');

    expect(anchorFinder, findsOneWidget);
    expect(sheetFinder, findsOneWidget);

    final anchorRect = tester.getRect(anchorFinder);
    final sheetRect = tester.getRect(sheetFinder);

    // Sheet should be below the anchor
    expect(sheetRect.top, greaterThan(anchorRect.bottom));
  });
}
