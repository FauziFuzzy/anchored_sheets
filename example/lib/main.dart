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
                    // Menu button that will anchor a dropdown
                    ElevatedButton.icon(
                      key: _menuButtonKey,
                      onPressed: _showMenuSheet,
                      icon: const Icon(Icons.menu),
                      label: const Text('Menu'),
                    ),
                    // Filter button that will anchor a filter panel
                    ElevatedButton.icon(
                      key: _filterButtonKey,
                      onPressed: _showFilterSheet,
                      icon: const Icon(Icons.filter_list),
                      label: Text('Filter: ${appState.selectedFilter}'),
                    ),
                  ],
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
                        'Scrollable Sheet',
                        'Large content with scroll',
                        Icons.view_list,
                        () => _showScrollableSheet(),
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
                        'Context-Free',
                        'Dismiss without context',
                        Icons.close,
                        () => _showContextFreeSheet(),
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
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.drag_handle, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Draggable Sheet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can drag this sheet up to dismiss it!\n'
                  'Try dragging the handle or the content.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Icon(Icons.swipe_up, size: 32, color: Colors.grey),
                const SizedBox(height: 8),
                const Text(
                  'This sheet auto-sizes with MainAxisSize.min',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  // Scrollable sheet example
  void _showScrollableSheet() {
    anchoredSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => SizedBox(
            height: 400,
            child: Column(
              children: [
                const Text(
                  'Scrollable Content',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder:
                        (context, index) => ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text('Item ${index + 1}'),
                          subtitle: Text('This is item number ${index + 1}'),
                        ),
                  ),
                ),
              ],
            ),
          ),
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

  // Anchored menu sheet
  void _showMenuSheet() async {
    final result = await anchoredSheet<String>(
      context: context,
      anchorKey: _menuButtonKey,
      useSafeArea: true, // Ensure it doesn't overlap with system UI
      builder:
          (context) => Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildMenuItem(Icons.home, 'Home'),
                _buildMenuItem(Icons.settings, 'Settings'),
                _buildMenuItem(Icons.help, 'Help'),
                _buildMenuItem(Icons.info, 'About'),
              ],
            ),
          ),
    );

    if (result != null) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.updateOption(result);
      }
    }
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      onTap: () => context.popAnchoredSheet(title), // Use Navigator.pop instead
    );
  }

  // Anchored filter sheet
  void _showFilterSheet() async {
    await anchoredSheet<String>(
      context: context,
      anchorKey: _filterButtonKey,
      useSafeArea: true, // Ensure it doesn't overlap with system UI
      builder: (context) => _FilterSheetContent(),
    );
  }

  // Anchored search sheet
  void _showSearchSheet() async {
    final result = await anchoredSheet<String>(
      context: context,
      anchorKey: _searchButtonKey,
      enableDrag: true,
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(16),
            child: Column(
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
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Consumer<AppState>(
            builder: (context, appState, child) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.all(16),
                child: Column(
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
                ),
              );
            },
          ),
    );

    if (result != null) {
      // Handle profile actions - notifications already updated via Provider
      // No need to set state here since Provider handles it
    }
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
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
