import 'package:anchored_sheets/anchored_sheets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

  String _selectedFilter = 'All';
  String _selectedOption = 'None';
  bool _notifications = true;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
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
                  label: Text('Filter: $_selectedFilter'),
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
                    Text('Selected Option: $_selectedOption'),
                    Text('Filter: $_selectedFilter'),
                    Text(
                      'Search: ${_searchQuery.isEmpty ? "None" : _searchQuery}',
                    ),
                    Text('Notifications: ${_notifications ? "On" : "Off"}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                  onPressed: () => dismissAnchoredSheet(),
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
      setState(() {
        _selectedOption = result['option'] ?? _selectedOption;
      });
      if (mounted) {
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

    // Demonstrate context-free dismissal
    Future.delayed(const Duration(seconds: 3), () {
      dismissAnchoredSheet('auto-dismissed'); // Type inferred as String
    });
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
      setState(() {
        _selectedOption = result;
      });
    }
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      onTap: () => dismissAnchoredSheet(title), // Type inferred as String
    );
  }

  // Anchored filter sheet
  void _showFilterSheet() async {
    final result = await anchoredSheet<String>(
      context: context,
      anchorKey: _filterButtonKey,
      useSafeArea: true, // Ensure it doesn't overlap with system UI
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterItem('All'),
              _buildFilterItem('Recent'),
              _buildFilterItem('Favorites'),
              _buildFilterItem('Archived'),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        _selectedFilter = result;
      });
    }
  }

  Widget _buildFilterItem(String filter) {
    return ListTile(
      dense: true,
      title: Text(filter),
      trailing: _selectedFilter == filter ? const Icon(Icons.check) : null,
      onTap: () => dismissAnchoredSheet(filter), // Type inferred as String
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
                      (value) => dismissAnchoredSheet(
                        value,
                      ), // Type inferred as String
                ),
              ],
            ),
          ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _searchQuery = result;
      });
    }
  }

  // Anchored profile sheet
  void _showProfileSheet() async {
    final result = await anchoredSheet<bool>(
      context: context,
      anchorKey: _userAvatarKey,
      useSafeArea: true, // Prevent overlap with status bar
      builder:
          (context) => Container(
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
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                    dismissAnchoredSheet(value); // Type inferred as bool
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap:
                      () =>
                          dismissAnchoredSheet(false), // Type inferred as bool
                ),
              ],
            ),
          ),
    );

    if (result != null) {
      // Handle profile actions if needed
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
                    onPressed:
                        () => dismissAnchoredSheet(
                          null,
                        ), // Type inferred from context
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
                        dismissAnchoredSheet({
                          // Type inferred as Map<String, dynamic>
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
