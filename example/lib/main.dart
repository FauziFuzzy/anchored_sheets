import 'package:anchored_sheets/anchored_sheets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Application state model using Provider for state management
class AppState extends ChangeNotifier {
  String _selectedFilter = 'All';
  String _selectedOption = 'None';
  bool _notifications = true;
  String _searchQuery = '';

  // Getters
  String get selectedFilter => _selectedFilter;
  String get selectedOption => _selectedOption;
  bool get notifications => _notifications;
  String get searchQuery => _searchQuery;

  // Methods to update state
  void updateFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void updateOption(String option) {
    _selectedOption = option;
    notifyListeners();
  }

  void updateNotifications(bool enabled) {
    _notifications = enabled;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchored Sheets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AnchoredSheetsDemo(),
    );
  }
}

class AnchoredSheetsDemo extends StatefulWidget {
  const AnchoredSheetsDemo({super.key});

  @override
  State<AnchoredSheetsDemo> createState() => _AnchoredSheetsDemoState();
}

class _AnchoredSheetsDemoState extends State<AnchoredSheetsDemo> {
  // Global keys for anchoring sheets to specific widgets
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _nestedSheetDemoKey = GlobalKey();

  final GlobalKey _userAvatarKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber,
            title: const Text('Anchored Sheets Demo'),
            actions: [
              // Search button that will anchor a search sheet
              IconButton(
                key: _searchButtonKey,
                icon: const Icon(Icons.search),
                onPressed: _showSearchSheet,
              ),
              // User avatar that will anchor a profile sheet
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  key: _userAvatarKey,
                  onTap: _showProfileSheet,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with action buttons
                Wrap(
                  children: [
                    ElevatedButton.icon(
                      key: _filterButtonKey,
                      onPressed: () {
                        anchoredSheet(
                          isScrollControlled: true,
                          showDragHandle: true,
                          useSafeArea: true,
                          enableDrag: true,
                          context: context,
                          builder: (context) {
                            return Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: 20,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      'Itasdsadasdsadasdsadsadsadsadsadem $index',
                                    ),
                                    subtitle: Text(
                                      'aniqweoiweniweniweniwenwienwe $index',
                                    ),
                                    onTap: () {
                                      context.popAnchoredSheet();
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                      label: Text('Filter: ${appState.selectedFilter}'),
                    ),

                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      key: _nestedSheetDemoKey,
                      onPressed: _showNestedSheetDemo,
                      icon: const Icon(Icons.layers),
                      label: const Text('Nested Demo'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        anchoredSheet(
                          context: context,
                          builder: (context) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    'Itasdsadasdsadasdsadsadsadsadsadem $index',
                                  ),
                                  subtitle: Text(
                                    'aniqweoiweniweniweniwenwienwe $index',
                                  ),
                                  onTap: () {
                                    context.popAnchoredSheet();
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Text('hello'),
                    ),
                    TextButton(
                      onPressed: () async {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: true,
                          showDragHandle: true,
                          useSafeArea: true,
                          context: context,
                          builder: (context) {
                            return ListView.builder(
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    'Itasdsadasdsadasdsadsadsadsadsadem $index',
                                  ),
                                  subtitle: Text(
                                    'aniqweoiweniweniweniwenwienwe $index',
                                  ),
                                  onTap: () {
                                    context.popAnchoredSheet();
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Text('bottoms'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNestedSheetDemo() async {
    await anchoredSheet<String>(
      context: context,
      anchorKey: _nestedSheetDemoKey,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.blue.shade50,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Anchored Sheet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This sheet is anchored to the "Nested Demo" button.\nClick the button below to open a non-anchored sheet on top.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open a non-anchored sheet on top of this anchored sheet
                    // Using a simple function call instead of await to prevent context issues
                    _showNonAnchoredSheet();
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Non-Anchored Sheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.popAnchoredSheet(),
                  child: const Text('Close Anchored Sheet'),
                ),
              ],
            ),
          ),
    );
  }

  // Non-anchored sheet that opens on top of the anchored sheet
  void _showNonAnchoredSheet() {
    anchoredSheet<String>(
      context: context,
      // No anchorKey = center of screen positioning
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.green.shade50,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.center_focus_strong,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Non-Anchored Sheet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This sheet appears in the center of the screen (no anchor key).\nIt\'s stacked on top of the anchored sheet.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => context.popAnchoredSheet(),
                      child: const Text('Close This Sheet'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Close this sheet and go back to the anchored one
                        context.popAnchoredSheet();
                      },
                      child: const Text('Back to Anchored'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  // Anchored search sheet
  void _showSearchSheet() async {
    final result = await anchoredSheet<String>(
      context: context,
      anchorKey: _searchButtonKey,
      enableDrag: true,
      showDragHandle: true,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted:
                    (value) => context.popAnchoredSheet(
                      value,
                    ), // Use Navigator.pop instead
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.updateSearchQuery(result);
      }
    }
  }

  // Anchored profile sheet
  void _showProfileSheet() async {
    final result = await anchoredSheet<bool>(
      context: context,
      anchorKey: _userAvatarKey,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      builder:
          (context) => Consumer<AppState>(
            builder: (context, appState, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'John Doe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('john.doe@example.com'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    value: appState.notifications,
                    onChanged: (value) {
                      appState.updateNotifications(value);
                      context.popAnchoredSheet(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap:
                        () => context.popAnchoredSheet(
                          false,
                        ), // Use Navigator.pop instead
                  ),
                ],
              );
            },
          ),
    );

    if (result != null) {
      // Handle profile actions - notifications already updated via Provider
      // No need to set state here since Provider handles it
    }
  }

  // ========== Modal Conflict Testing Methods ==========
  void _showTestSheetA() {
    anchoredSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.blue.shade50,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.looks_one, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Test Sheet A',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click "Same Sheet A" button to test duplicate prevention.\n'
                  'Click "Replace with B" to test replacement.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => _showTestSheetA(), // Same ID - should dismiss
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Same Sheet A (Should Dismiss)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => _showTestSheetB(), // Different ID - should replace
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Replace with Sheet B'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.popAnchoredSheet(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

  void _showTestSheetB() {
    anchoredSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.green.shade50,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.looks_two, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Test Sheet B',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This sheet replaced Sheet A!\n'
                  'Click "Same Sheet B" to test duplicate prevention.\n'
                  'Click "Back to A" to test replacement.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => _showTestSheetB(), // Same ID - should dismiss
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Same Sheet B (Should Dismiss)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => _showTestSheetA(), // Different ID - should replace
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Back to Sheet A'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.popAnchoredSheet(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }
}

class _FormSheetContent extends StatefulWidget {
  @override
  _FormSheetContentState createState() => _FormSheetContentState();
}

class _FormSheetContentState extends State<_FormSheetContent> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOption = '';
  String _textInput = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Interactive Form',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Enter some text',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _textInput = value ?? '',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Select an option:'),
            RadioListTile<String>(
              title: const Text('Option A'),
              value: 'Option A',
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value!),
            ),
            RadioListTile<String>(
              title: const Text('Option B'),
              value: 'Option B',
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value!),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.popAnchoredSheet(null),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedOption.isNotEmpty) {
                        _formKey.currentState!.save();
                        context.popAnchoredSheet({
                          'option': _selectedOption,
                          'text': _textInput,
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable filter option widget following Flutter best practices
