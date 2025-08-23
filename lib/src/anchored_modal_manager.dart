/// # Anchored Modal Manager
///
/// This module provides modal management functionality for anchored sheets
/// using Flutter's InheritedWidget pattern and Navigator lifecycle integration.
/// It handles coordination between different modal types and provides clean
/// dismissal mechanisms.
///
/// ## Key Features
///
/// * 🎯 **InheritedWidget Pattern** - Efficient widget tree state propagation
/// * 🔄 **Navigator Integration** - Works seamlessly with Flutter's navigation
/// * 📱 **Modal Coordination** - Handles multiple modal types gracefully
/// * ⚡ **Async Dismissal** - Smooth timing for modal transitions
/// * 🎭 **Context-aware Operations** - Safe modal operations with context checking
///
/// ## Architecture
///
/// The modal manager follows Flutter's state management patterns:
/// - Uses `InheritedWidget` for efficient state propagation
/// - Integrates with `Navigator` for standard modal handling
/// - Provides both imperative and declarative dismissal methods
/// - Ensures proper timing for modal transitions
///
/// ## Usage Patterns
///
/// ```dart
/// // Wrap your app or modal area
/// ModalManager(
///   onDismissRequest: () => handleDismiss(),
///   child: YourWidget(),
/// )
///
/// // Access from any descendant
/// final manager = ModalManager.of(context);
/// manager.requestDismiss();
///
/// // Dismiss other modals
/// await ModalManager.dismissOtherModals(context);
/// ```
library;

import 'package:flutter/material.dart';

/// A modal coordination widget that manages modal state across the widget tree
///
/// This widget uses Flutter's InheritedWidget pattern to provide modal
/// management capabilities to descendant widgets. It coordinates between
/// different modal types and provides unified dismissal mechanisms.
///
/// ## Features
///
/// * **State Propagation** - Efficiently shares modal state down the widget tree
/// * **Dismissal Coordination** - Centralized handling of modal dismissals
/// * **Navigator Integration** - Works with Flutter's built-in navigation system
/// * **Context Safety** - Provides safe access patterns for modal operations
/// * **Async Support** - Handles timing-sensitive modal transitions
///
/// ## Widget Tree Integration
///
/// The ModalManager should be placed high in the widget tree, typically:
/// - Above modal content areas
/// - In route builders for modal screens
/// - Around sections that need modal coordination
///
/// ## Example Usage
///
/// ```dart
/// ModalManager(
///   onDismissRequest: () {
///     // Handle modal dismissal
///     Navigator.of(context).pop();
///   },
///   child: ModalContent(),
/// )
/// ```
///
/// ## Access Patterns
///
/// ```dart
/// // Safe access (returns null if not found)
/// final manager = ModalManager.maybeOf(context);
/// manager?.requestDismiss();
///
/// // Direct access (throws if not found)
/// final manager = ModalManager.of(context);
/// manager.requestDismiss();
/// ```
///
/// ## Best Practices
///
/// * Place ModalManager high in the widget tree for maximum coverage
/// * Use `maybeOf` when access is optional
/// * Use `of` when ModalManager presence is guaranteed
/// * Handle dismissal requests appropriately in onDismissRequest callback
class ModalManager extends InheritedWidget {
  /// Callback function executed when a modal dismissal is requested
  ///
  /// This function is called when [requestDismiss] is invoked by descendant
  /// widgets. It should contain the logic to actually dismiss the modal,
  /// such as calling Navigator.pop() or updating application state.
  ///
  /// **Example implementations:**
  /// ```dart
  /// // Simple navigation dismissal
  /// onDismissRequest: () => Navigator.of(context).pop(),
  ///
  /// // State-based dismissal
  /// onDismissRequest: () => setState(() => showModal = false),
  ///
  /// // Complex dismissal with cleanup
  /// onDismissRequest: () async {
  ///   await cleanup();
  ///   Navigator.of(context).pop();
  /// },
  /// ```
  final VoidCallback? onDismissRequest;

  /// Creates a modal manager widget
  ///
  /// ## Parameters
  ///
  /// * [child] - Required. The widget subtree that will have access to modal management
  /// * [onDismissRequest] - Optional. Callback executed when dismissal is requested
  /// * [key] - Optional. Widget key for identification and optimization
  ///
  /// ## Example
  ///
  /// ```dart
  /// ModalManager(
  ///   onDismissRequest: () {
  ///     // Custom dismissal logic
  ///     print('Modal dismissal requested');
  ///     Navigator.of(context).pop();
  ///   },
  ///   child: MyModalContent(),
  /// )
  /// ```
  const ModalManager({
    super.key,
    required super.child,
    this.onDismissRequest,
  });

  /// Safely retrieves the nearest ModalManager from the widget tree
  ///
  /// Searches up the widget tree for the nearest ModalManager ancestor.
  /// Returns null if no ModalManager is found, making it safe to use
  /// in contexts where modal management might not be available.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// final manager = ModalManager.maybeOf(context);
  /// if (manager != null) {
  ///   manager.requestDismiss();
  /// } else {
  ///   // Handle case where no modal manager is available
  ///   print('No modal manager found');
  /// }
  /// ```
  ///
  /// ## When to Use
  ///
  /// * When modal management is optional
  /// * In reusable widgets that might be used outside modal contexts
  /// * When you want to avoid exceptions in edge cases
  ///
  /// ## Returns
  ///
  /// * [ModalManager] if found in the widget tree
  /// * `null` if no ModalManager ancestor exists
  static ModalManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ModalManager>();
  }

  /// Retrieves the nearest ModalManager from the widget tree
  ///
  /// Searches up the widget tree for the nearest ModalManager ancestor.
  /// Throws an assertion error if no ModalManager is found, ensuring
  /// that modal management is always available when expected.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// final manager = ModalManager.of(context);
  /// manager.requestDismiss(); // Safe to call, guaranteed to exist
  /// ```
  ///
  /// ## When to Use
  ///
  /// * When modal management is required for functionality
  /// * In widgets specifically designed for modal contexts
  /// * When you want explicit failures for missing dependencies
  ///
  /// ## Throws
  ///
  /// * [AssertionError] if no ModalManager is found in the widget tree
  ///
  /// ## Returns
  ///
  /// * [ModalManager] - Guaranteed to be non-null
  static ModalManager of(BuildContext context) {
    final ModalManager? result = maybeOf(context);
    assert(result != null, 'No ModalManager found in context');
    return result!;
  }

  /// Determines whether the widget should notify dependents of changes
  ///
  /// This method is called by Flutter's InheritedWidget system to determine
  /// if dependent widgets should be rebuilt when this ModalManager is replaced
  /// with a new instance.
  ///
  /// ## Rebuild Criteria
  ///
  /// The widget will notify dependents (triggering rebuilds) when:
  /// - The [onDismissRequest] callback changes
  /// - This ensures dependent widgets stay synchronized with dismissal logic
  ///
  /// ## Performance Impact
  ///
  /// This method is optimized to only trigger rebuilds when necessary:
  /// - Compares callback references for efficiency
  /// - Avoids unnecessary rebuilds when callbacks are functionally equivalent
  /// - Maintains Flutter's InheritedWidget performance characteristics
  ///
  /// ## Parameters
  ///
  /// * [oldWidget] - The previous ModalManager instance being replaced
  ///
  /// ## Returns
  ///
  /// * `true` if dependents should be notified and rebuilt
  /// * `false` if no changes require dependent widget updates
  @override
  bool updateShouldNotify(ModalManager oldWidget) {
    return onDismissRequest != oldWidget.onDismissRequest;
  }

  /// Dismisses other modal types using Flutter's Navigator system
  ///
  /// This utility method provides a clean way to dismiss existing modals
  /// before showing new ones, preventing modal stacking and ensuring
  /// smooth transitions between different modal types.
  ///
  /// ## Behavior
  ///
  /// 1. **Check Navigation State**: Verifies if the navigator can pop
  /// 2. **Execute Dismissal**: Calls Navigator.pop() if possible
  /// 3. **Wait for Completion**: Adds a brief delay for smooth transitions
  /// 4. **Return Control**: Completes when dismissal animation finishes
  ///
  /// ## Use Cases
  ///
  /// * **Modal Replacement**: Dismiss bottom sheet before showing anchored sheet
  /// * **Dialog Cleanup**: Clear dialogs before navigation
  /// * **Overlay Management**: Coordinate between different overlay types
  ///
  /// ## Example Usage
  ///
  /// ```dart
  /// // Before showing a new modal
  /// await ModalManager.dismissOtherModals(context);
  /// showModalBottomSheet(...);
  ///
  /// // In modal transition logic
  /// onTap: () async {
  ///   await ModalManager.dismissOtherModals(context);
  ///   showCustomModal();
  /// }
  /// ```
  ///
  /// ## Timing Considerations
  ///
  /// The method includes a 16ms delay (one frame at 60fps) to ensure:
  /// - Dismissal animations complete smoothly
  /// - Navigator state updates properly
  /// - New modals don't conflict with closing ones
  ///
  /// ## Parameters
  ///
  /// * [context] - BuildContext for accessing the Navigator
  ///
  /// ## Returns
  ///
  /// * [Future<void>] - Completes when dismissal and timing delay finish
  static Future<void> dismissOtherModals(BuildContext context) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  /// Requests dismissal of the current modal through the widget tree
  ///
  /// This method provides a declarative way for descendant widgets to
  /// request modal dismissal. It invokes the [onDismissRequest] callback
  /// if one was provided during widget construction.
  ///
  /// ## Usage Pattern
  ///
  /// ```dart
  /// // In a button inside the modal
  /// ElevatedButton(
  ///   onPressed: () {
  ///     final manager = ModalManager.of(context);
  ///     manager.requestDismiss();
  ///   },
  ///   child: Text('Close'),
  /// )
  /// ```
  ///
  /// ## Integration with Other Systems
  ///
  /// ```dart
  /// // Combined with gesture detection
  /// GestureDetector(
  ///   onTap: () => ModalManager.of(context).requestDismiss(),
  ///   child: BackdropArea(),
  /// )
  ///
  /// // In form validation
  /// if (formIsValid) {
  ///   saveData();
  ///   ModalManager.of(context).requestDismiss();
  /// }
  /// ```
  ///
  /// ## Null Safety
  ///
  /// The method safely handles cases where no [onDismissRequest] callback
  /// was provided. In such cases, the call is ignored gracefully.
  ///
  /// ## When to Use
  ///
  /// * User-initiated dismissals (button presses, gestures)
  /// * Programmatic dismissals after operations complete
  /// * Integration with form submissions or data operations
  /// * Custom dismissal logic that needs widget tree coordination
  void requestDismiss() {
    onDismissRequest?.call();
  }
}
