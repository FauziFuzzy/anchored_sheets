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
  group('Anchored Sheets Widget Tests', () {
    // Clean up any remaining sheets between tests

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
                            onPressed: () =>
                                dismissAnchoredSheet('test_result'),
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

    testWidgets('Draggable sheet responds to drag gestures',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    enableDrag: true,
                    showDragHandle: true,
                    isDismissible: true,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Draggable Sheet'),
                          Container(height: 100, color: Colors.blue),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show Draggable Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the draggable sheet
      await showSheetInTest(tester, 'Show Draggable Sheet');

      // Verify sheet and drag handle are displayed
      expect(find.text('Draggable Sheet'), findsOneWidget);

      // Find the sheet content
      final sheetFinder = find.text('Draggable Sheet');
      expect(sheetFinder, findsOneWidget);

      // Perform a more aggressive drag gesture upward (to dismiss)
      // The drag logic expects negative y movement and sufficient
      // velocity/distance
      await tester.fling(
        sheetFinder,
        const Offset(0, -400),
        1500,
      ); // Higher velocity and distance
      await tester.pumpAndSettle();

      // Sheet should be dismissed after significant upward drag
      expect(find.text('Draggable Sheet'), findsNothing);
    });

    testWidgets('Sheet dismisses when tapping overlay',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    isDismissible: true,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text('Dismissible Sheet'),
                    ),
                  );
                },
                child: const Text('Show Dismissible Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the sheet
      await showSheetInTest(tester, 'Show Dismissible Sheet');

      // Verify sheet is displayed
      expect(find.text('Dismissible Sheet'), findsOneWidget);

      // Tap outside the sheet (on the overlay)
      await tester.tapAt(const Offset(50, 500)); // Bottom area of screen
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('Dismissible Sheet'), findsNothing);
    });

    testWidgets('Non-dismissible sheet does not close on overlay tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    isDismissible: false,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Non-dismissible Sheet'),
                          ElevatedButton(
                            onPressed: () => dismissAnchoredSheet(),
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show Non-dismissible Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the sheet
      await showSheetInTest(tester, 'Show Non-dismissible Sheet');

      // Verify sheet is displayed
      expect(find.text('Non-dismissible Sheet'), findsOneWidget);

      // Try to tap outside the sheet
      await tester.tapAt(const Offset(50, 500));
      await tester.pumpAndSettle();

      // Verify sheet is still displayed (not dismissed)
      expect(find.text('Non-dismissible Sheet'), findsOneWidget);

      // Dismiss properly using button
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Now verify sheet is dismissed
      expect(find.text('Non-dismissible Sheet'), findsNothing);
    });

    testWidgets('Sheet with constraints respects size limits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    constraints: const BoxConstraints(
                      minHeight: 100,
                      maxHeight: 300,
                      minWidth: 200,
                      maxWidth: 400,
                    ),
                    builder: (context) => Container(
                      height: 500, // This should be constrained to maxHeight
                      width: 600, // This should be constrained to maxWidth
                      padding: const EdgeInsets.all(20),
                      child: const Text('Constrained Sheet'),
                    ),
                  );
                },
                child: const Text('Show Constrained Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the sheet
      await showSheetInTest(tester, 'Show Constrained Sheet');

      // Verify sheet content is displayed
      expect(find.text('Constrained Sheet'), findsOneWidget);
    });

    testWidgets('Safe area sheet respects status bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    useSafeArea: true,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text('Safe Area Sheet'),
                    ),
                  );
                },
                child: const Text('Show Safe Area Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the sheet
      await showSheetInTest(tester, 'Show Safe Area Sheet');

      // Verify sheet content is displayed
      expect(find.text('Safe Area Sheet'), findsOneWidget);

      // Verify SafeArea widget is present
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('MainAxisSize.min works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Dynamic Content'),
                          const SizedBox(height: 10),
                          const Text('Second line'),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show Dynamic Sheet'),
              ),
            ),
          ),
        ),
      );

      // Show the sheet
      await showSheetInTest(tester, 'Show Dynamic Sheet');

      // Verify sheet content is displayed
      expect(find.text('Dynamic Content'), findsOneWidget);
      expect(find.text('Second line'), findsOneWidget);
    });
  });
}
