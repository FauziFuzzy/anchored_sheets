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
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      key: _filterButtonKey,
                      onPressed: _showFilterSheet,
                      icon: const Icon(Icons.filter_list),
                      label: Text('Filter: ${appState.selectedFilter}'),
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

                // Content area
                const Text(
                  'Anchored Sheets Examples',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDemoCard(
                        'Basic Sheet',
                        'Simple top modal sheet',
                        Icons.article,
                        () => _showBasicSheet(),
                      ),
                      _buildDemoCard(
                        'Draggable Sheet',
                        'Sheet with drag to dismiss',
                        Icons.drag_handle,
                        () => _showDraggableSheet(),
                      ),

                      _buildDemoCard(
                        'Styled Sheet',
                        'Custom styling & shape',
                        Icons.palette,
                        () => _showStyledSheet(),
                      ),
                      _buildDemoCard(
                        'Form Sheet',
                        'Interactive form example',
                        Icons.edit,
                        () => _showFormSheet(),
                      ),

                      _buildDemoCard(
                        'Safe Modal',
                        'Handle modal conflicts',
                        Icons.safety_check,
                        () => _showSafeModalExample(),
                      ),
                      _buildDemoCard(
                        'Auto-Dismiss',
                        'Dismiss other modals first',
                        Icons.auto_fix_high,
                        () => _showAutoDismissExample(),
                      ),
                      _buildDemoCard(
                        'Replace Test',
                        'Test sheet replacement',
                        Icons.swap_horiz,
                        () => _showReplaceTest(),
                      ),
                    ],
                  ),
                ),

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

  Widget _buildDemoCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
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

  // Basic sheet example
  void _showBasicSheet() {
    anchoredSheet(
      context: context,
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.info, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Basic Top Modal Sheet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This sheet automatically sizes to fit its content using '
                  'MainAxisSize.min',
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
  }

  // Draggable sheet example
  void _showDraggableSheet() {
    anchoredSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      builder: (context) => _FilterSheetContent(),
    );
  }

  // Styled sheet example
  void _showStyledSheet() {
    anchoredSheet(
      context: context,
      backgroundColor: Colors.purple.shade50,
      elevation: 10,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      builder:
          (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Styled Sheet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Custom background, elevation, and border radius',
                textAlign: TextAlign.center,
              ),
            ],
          ),
    );
  }

  // Form sheet example
  void _showFormSheet() async {
    final result = await anchoredSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true, // Prevent overlap with status bar
      builder: (context) => _FormSheetContent(),
    );

    if (result != null) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.updateOption(result['option'] ?? appState.selectedOption);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted: ${result['option']}')),
        );
      }
    }
  }

  // Context-free dismissal example
  void _showContextFreeSheet() {
    anchoredSheet(
      context: context,
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Auto-Dismiss Sheet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This sheet will automatically close in 3 seconds using '
                  'context-free dismissal.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Auto-sized with MainAxisSize.min',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  // Safe modal handling example
  Future<void> _showSafeModalExample() {
    return anchoredSheet(
      context: context,
      useSafeArea: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.safety_check, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Safe Modal Handling',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This demonstrates how to safely handle multiple modal types.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.popAnchoredSheet(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

  // Auto-dismiss other modals example
  void _showAutoDismissExample() {
    // First show a bottom sheet
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            height: 200,
            child: Column(
              children: [
                const Text(
                  'Bottom Sheet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This will be auto-dismissed when you tap the button',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // This will automatically dismiss the bottom sheet first
                    anchoredSheet(
                      context: context,
                      dismissOtherModals: true, // ← New parameter!
                      useSafeArea: true,
                      builder:
                          (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_fix_high,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Auto-Dismiss Feature',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'This anchored sheet automatically dismissed the bottom sheet!',
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
                  child: const Text('Show Anchored Sheet'),
                ),
              ],
            ),
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

  // Replace Test Demo - Test sheet replacement vs duplicate prevention
  void _showReplaceTest() {
    _showTestSheetA();
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

  // Enhanced gesture sheet demo
  void _showGestureSheet() async {
    await anchoredSheet<String>(
      context: context,

      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯 Enhanced Gestures Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Try these gestures:'),
                const SizedBox(height: 12),
                _buildGestureInfo('📌', 'Long press to pin/unpin'),
                _buildGestureInfo('↕️', 'Drag edges to resize'),
                _buildGestureInfo('👆', 'Swipe up/down/left/right'),
                _buildGestureInfo('👆👆', 'Double tap for action'),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Interactive Area\nTry gestures here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.popAnchoredSheet('dismissed'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  // Performance optimized sheet demo
  void _showPerformanceSheet() async {
    await anchoredSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,

      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚀 Performance Optimized Sheet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('This sheet uses:'),
                const SizedBox(height: 12),
                _buildPerformanceFeature('💾', 'Cached animations'),
                _buildPerformanceFeature('🎨', 'RepaintBoundary widgets'),
                _buildPerformanceFeature('⚡', 'Lazy-loaded gestures'),
                _buildPerformanceFeature('📊', 'Performance metrics'),
                _buildPerformanceFeature('🔄', 'Optimized rebuilds'),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Benefits:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Faster animation startup'),
                      const Text('• Reduced memory usage'),
                      const Text('• Smoother interactions'),
                      const Text('• Better frame rates'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Animation cache cleanup is now handled automatically
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Animation cache cleaned up!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text('Cleanup Cache'),
                    ),
                    TextButton(
                      onPressed: () => context.popAnchoredSheet('dismissed'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPerformanceFeature(String icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildGestureInfo(String icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(description),
        ],
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
