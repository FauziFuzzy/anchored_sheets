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
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      key: _filterButtonKey,
                      onPressed: _showFilterSheet,
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
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Test how anchored sheets handle various modal types',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Modal test buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildModalTestButton(
                        'Bottom Sheet',
                        Icons.vertical_align_bottom,
                        Colors.blue,
                        _showBottomSheetFirst,
                      ),
                      const SizedBox(width: 8),
                      _buildModalTestButton(
                        'Alert Dialog',
                        Icons.warning,
                        Colors.orange,
                        _showAlertDialogFirst,
                      ),
                      const SizedBox(width: 8),
                      _buildModalTestButton(
                        'Custom Dialog',
                        Icons.chat_bubble,
                        Colors.purple,
                        _showCustomDialogFirst,
                      ),
                      const SizedBox(width: 8),
                      _buildModalTestButton(
                        'Snack Bar',
                        Icons.info,
                        Colors.green,
                        _showSnackBarFirst,
                      ),
                      const SizedBox(width: 8),
                      _buildModalTestButton(
                        'Material Banner',
                        Icons.announcement,
                        Colors.red,
                        _showMaterialBannerFirst,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Status section
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current State:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Selected Option: ${appState.selectedOption}'),
                        Text('Filter: ${appState.selectedFilter}'),
                        Text(
                          'Search: ${appState.searchQuery.isEmpty ? "None" : appState.searchQuery}',
                        ),
                        Text(
                          'Notifications: ${appState.notifications ? "On" : "Off"}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalTestButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Anchored filter sheet
  void _showFilterSheet() async {
    await anchoredSheet<String>(
      context: context,
      anchorKey: _filterButtonKey,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      builder: (context) => _FilterSheetContent(),
    );
  }

  // Nested sheet demo - anchored sheet with button that opens non-anchored sheet
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
      dismissOtherModals: false, // Keep the current anchored sheet open
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
      useSafeArea: true,
      builder:
          (context) => Column(
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

  /// Show a bottom sheet first, then allow testing anchored sheet dismissal
  void _showBottomSheetFirst() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              children: [
                const Icon(
                  Icons.vertical_align_bottom,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Modal Bottom Sheet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This bottom sheet is currently showing. Now try opening an anchored sheet to test dismissal.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // This will dismiss the bottom sheet and show anchored sheet
                    anchoredSheet(
                      context: context,
                      dismissOtherModals: true, // ← Key parameter!
                      useSafeArea: true,
                      builder:
                          (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Success!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Anchored sheet automatically dismissed the bottom sheet!',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.popAnchoredSheet(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                  child: const Text('Test Anchored Sheet Dismissal'),
                ),
              ],
            ),
          ),
    );
  }

  /// Show an alert dialog first, then test anchored sheet dismissal
  void _showAlertDialogFirst() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
            title: const Text('Alert Dialog'),
            content: const Text(
              'This is a standard alert dialog. Test how anchored sheets handle dialog dismissal.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  anchoredSheet(
                    context: context,
                    dismissOtherModals: true,
                    useSafeArea: true,
                    builder:
                        (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 48,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Dialog Dismissed!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Anchored sheet successfully dismissed the alert dialog.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.popAnchoredSheet(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: const Text('Test Dismissal'),
              ),
            ],
          ),
    );
  }

  /// Show a custom dialog first, then test anchored sheet dismissal
  void _showCustomDialogFirst() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble, color: Colors.purple, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Custom Dialog',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a custom styled dialog with rounded corners.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          anchoredSheet(
                            context: context,
                            dismissOtherModals: true,
                            useSafeArea: true,
                            backgroundColor: Colors.purple.shade50,
                            builder:
                                (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_fix_high,
                                        size: 48,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Custom Dialog Replaced!',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'The custom dialog was smoothly replaced with this anchored sheet.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed:
                                            () => context.popAnchoredSheet(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                        child: const Text('Replace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Show a snack bar first, then test if anchored sheet can coexist or dismiss it
  void _showSnackBarFirst() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'This is a SnackBar. It should remain while anchored sheet shows.',
        ),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Test Anchored Sheet',
          onPressed: () {
            // SnackBars don't usually need dismissal, they coexist nicely
            anchoredSheet(
              context: context,
              useSafeArea: true,
              builder:
                  (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, size: 48, color: Colors.green),
                        const SizedBox(height: 16),
                        const Text(
                          'Coexistence Test',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SnackBars and anchored sheets can coexist nicely! Notice the SnackBar is still visible.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.popAnchoredSheet();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                          child: const Text('Close Both'),
                        ),
                      ],
                    ),
                  ),
            );
          },
        ),
      ),
    );
  }

  /// Show a material banner first, then test anchored sheet interaction
  void _showMaterialBannerFirst() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text(
          'This is a Material Banner. Test anchored sheet interaction.',
        ),
        leading: const Icon(Icons.announcement, color: Colors.red),
        backgroundColor: Colors.red.shade50,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              anchoredSheet(
                context: context,
                useSafeArea: true,
                backgroundColor: Colors.red.shade50,
                builder:
                    (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.announcement,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Banner + Sheet Interaction',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Material banners and anchored sheets can work together. The banner remains visible.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => context.popAnchoredSheet(),
                                child: const Text('Close Sheet'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context.popAnchoredSheet();
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentMaterialBanner();
                                },
                                child: const Text('Close Both'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              );
            },
            child: const Text('Test Sheet'),
          ),
        ],
      ),
    );
  }

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

class _FilterSheetContent extends StatelessWidget {
  const _FilterSheetContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            TextButton(
              onPressed: () async {
                await anchoredSheet<String>(
                  context: context,
                  dismissOtherModals: false, // Don't dismiss the current sheet
                  isScrollControlled: true,
                  useSafeArea: true,
                  showDragHandle: true,
                  enableDrag: true,
                  builder: (context) {
                    // show list of items with radio
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Option 1'),
                          value: 'Option 1',
                          groupValue: appState.selectedOption,
                          onChanged: (value) => appState.updateOption(value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Option 2'),
                          value: 'Option 2',
                          groupValue: appState.selectedOption,
                          onChanged: (value) => appState.updateOption(value!),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Anchored Sheet on Top'),
            ),
            // Header
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Filter options
            ...['All', 'Recent', 'Favorites', 'Archived'].map(
              (filter) => _FilterOption(
                title: filter,
                isSelected: appState.selectedFilter == filter,
                onTap: () => appState.updateFilter(filter),
              ),
            ),

            // Action buttons
          ],
        );
      },
    );
  }
}

/// A reusable filter option widget following Flutter best practices
class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
