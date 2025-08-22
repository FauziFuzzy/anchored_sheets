/// # TopModalSheet
///
/// A Flutter widget that displays modal sheets sliding down from the top of the
/// screen, similar to `showModalBottomSheet` but positioned at the top. Ideal
/// for filter menus, notifications, or any content that should appear anchored
/// to the top of the screen.
///
/// ## Features
///
/// * 🎯 **Anchor positioning** - Attach to specific widgets using GlobalKeys
/// * 📏 **Height control** - Automatic sizing with overflow constraints like
///   showModalBottomSheet
/// * 🎨 **Customizable styling** - Full theming support with Material Design
///   integration
/// * 👆 **Drag to dismiss** - Optional drag handles and gesture support
/// * 🔄 **Return values** - Get data back when modal is dismissed
/// * 📱 **Safe area support** - Handles notches and device-specific layouts
/// * ⚡ **Context-free dismissal** - Close modals from anywhere in your code
/// * 🎭 **Animation control** - Customizable slide and fade animations
///
/// ## Quick Start
///
/// ```dart
/// import 'package:your_package/top_modal_sheet.dart';
///
/// // Basic usage
/// showModalTopSheet(
///   context: context,
///   builder: (context) => Container(
///     height: 200,
///     child: Center(child: Text('Hello from the top!')),
///   ),
/// );
/// ```
///
/// ## Common Use Cases
///
/// ### Filter Menu
/// ```dart
/// final GlobalKey filterButtonKey = GlobalKey();
///
/// ElevatedButton(
///   key: filterButtonKey,
///   onPressed: () async {
///     final result = await showModalTopSheet<Map<String, dynamic>>(
///       context: context,
///       anchorKey: filterButtonKey,
///       builder: (context) => FilterMenuWidget(),
///     );
///     if (result != null) {
///       applyFilters(result);
///     }
///   },
///   child: Text('Filters'),
/// );
/// ```
///
/// ### Notification Panel
/// ```dart
/// showModalTopSheet(
///   context: context,
///   isScrollControlled: true,
///   enableDrag: true,
///   builder: (context) => NotificationList(),
/// );
/// ```
///
/// ### Selection Menu
/// ```dart
/// final selection = await showModalTopSheet<String>(
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'src.dart';

/// Extension methods for BuildContext to provide
/// convenient anchored sheet operations
extension AnchoredSheetContext on BuildContext {
  /// Hide the current anchored sheet
  ///
  /// Usage:
  /// ```dart
  /// context.popSheet();
  /// context.popSheet('result');
  /// ```

  /// Alternative shorter name
  Future<void> popAnchoredSheet<T>([T? result]) async {
    await AnchoredSheetPop.of(this)?.pop(result);
  }
}

/// AnchoredSheetPop utility class for context-based dismissal
class AnchoredSheetPop {
  final BuildContext _context;

  AnchoredSheetPop._(this._context);

  /// Get AnchoredSheetPop instance from context
  static AnchoredSheetPop? of(BuildContext context) {
    return AnchoredSheetPop._(context);
  }

  /// Hide/dismiss the anchored sheet
  Future<void> pop<T>([T? result]) async {
    // Try to find the modal provider in the widget tree
    final provider = ModalDismissProvider.maybeOf(_context);
    if (provider != null) {
      provider.onDismiss(result);
    } else {
      // Fallback to the global dismissal mechanism
      await dismissAnchoredSheet(result);
    }
  }
}

/// Simplified TopModalSheet using mixins and reusable components
///
/// This demonstrates how the original TopModalSheet can be refactored
/// using mixins to reduce code duplication and improve maintainability.
class AnchoredSheet extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final BorderRadius? borderRadius;
  final Color overlayColor;
  final Duration animationDuration;
  final bool isDismissible;
  final bool isScrollControlled;
  final double scrollControlDisabledMaxHeightRatio;
  final bool enableDrag;
  final bool? showDragHandle;
  final Color? dragHandleColor;
  final Size? dragHandleSize;
  final GlobalKey? anchorKey;
  final double? topOffset;
  final GenericModalController<dynamic>? controller;
  final VoidCallback onClosing;
  final bool useSafeArea;

  const AnchoredSheet({
    super.key,
    required this.child,
    required this.onClosing,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.borderRadius,
    this.overlayColor = Colors.black54,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDismissible = true,
    this.isScrollControlled = false,
    this.scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
    this.enableDrag = false,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleSize,
    this.anchorKey,
    this.topOffset,
    this.controller,
    this.useSafeArea = false,
  });

  @override
  State<AnchoredSheet> createState() => _AnchoredSheetState();
}

class _AnchoredSheetState extends State<AnchoredSheet>
    with SingleTickerProviderStateMixin
    implements ModalAnimation, DragDismiss, AnchoredSheetModalManager {
  final GlobalKey _childKey = GlobalKey(
    debugLabel: 'AnchoredSheet child',
  );

  // ModalAnimationMixin implementation
  @override
  late AnimationController animationController;
  @override
  late Animation<double> slideAnimation;
  @override
  late Animation<double> fadeAnimation;

  @override
  Duration get enterDuration => const Duration(milliseconds: 250);
  @override
  Duration get exitDuration => const Duration(milliseconds: 200);
  @override
  Curve get animationCurve => Curves.easeOutCubic;

  @override
  bool get dismissUnderway =>
      animationController.status == AnimationStatus.reverse;

  // DragDismissMixin implementation
  @override
  double get minFlingVelocity => 700.0;
  @override
  double get closeThreshold => 0.5;
  @override
  Set<WidgetState> dragHandleStates = <WidgetState>{};

  @override
  AnimationController get dragAnimationController => animationController;
  @override
  double get dragTargetHeight => _childHeight;
  @override
  VoidCallback get onDragDismiss => widget.onClosing;
  @override
  void setStateCallback(VoidCallback callback) => setState(callback);

  @override
  void onDragStart(DragStartDetails details) {}
  @override
  void onDragEnd(DragEndDetails details, {required bool isClosing}) {}

  double get _childHeight {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size.height;
    }
    return 200.0;
  }

  @override
  void initState() {
    super.initState();
    setCurrentState(this);
    setupAnimations();
    showModal();
  }

  @override
  void dispose() {
    clearState();
    disposeAnimations();
    super.dispose();
  }

  // ModalAnimationMixin methods
  @override
  void setupAnimations() {
    animationController = AnimationController(
      duration: enterDuration,
      reverseDuration: exitDuration,
      debugLabel: 'ModalAnimation',
      vsync: this,
    );

    slideAnimation = Tween<double>(
      begin: -0.01, // Start above screen
      end: 0.0, // End at final position
    ).animate(
      CurvedAnimation(parent: animationController, curve: animationCurve),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
  }

  @override
  void showModal() {
    animationController.forward();
  }

  @override
  Future<void> dismissModal() async {
    await animationController.reverse();
  }

  @override
  void disposeAnimations() {
    animationController.dispose();
  }

  // DragDismissMixin methods
  @override
  void handleDragStart(DragStartDetails details) {
    setStateCallback(() {
      dragHandleStates.add(WidgetState.dragged);
    });
    onDragStart(details);
  }

  @override
  void handleDragUpdate(DragUpdateDetails details) {
    if (dragAnimationController.status == AnimationStatus.reverse) return;

    // For top modals, positive delta moves up (dismiss)
    final dragHeight = dragTargetHeight > 0 ? dragTargetHeight : 200.0;
    dragAnimationController.value += details.primaryDelta! / dragHeight;
  }

  @override
  void handleDragEnd(DragEndDetails details) {
    if (dragAnimationController.status == AnimationStatus.reverse) return;

    setStateCallback(() {
      dragHandleStates.remove(WidgetState.dragged);
    });

    var isClosing = false;

    // Check for fling velocity (negative = upward = dismiss for top modals)
    if (details.velocity.pixelsPerSecond.dy < -minFlingVelocity) {
      final flingVelocity =
          details.velocity.pixelsPerSecond.dy / dragTargetHeight;
      if (dragAnimationController.value < 1.0) {
        dragAnimationController.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (dragAnimationController.value > closeThreshold) {
      if (dragAnimationController.value < 1.0) {
        dragAnimationController.fling(velocity: 1.0);
      }
      isClosing = true;
    } else {
      dragAnimationController.reverse();
    }

    onDragEnd(details, isClosing: isClosing);

    if (isClosing) {
      onDragDismiss();
    }
  }

  @override
  void handleDragHandleHover({required bool hovering}) {
    if (hovering != dragHandleStates.contains(WidgetState.hovered)) {
      setStateCallback(() {
        if (hovering) {
          dragHandleStates.add(WidgetState.hovered);
        } else {
          dragHandleStates.remove(WidgetState.hovered);
        }
      });
    }
  }

  Future<void> _dismiss<T extends Object?>([T? result]) async {
    await dismissModal();
    widget.controller?.dismiss(result);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedTopOffset = calculateTopOffset(
      anchorKey: widget.anchorKey,
      topOffset: widget.topOffset,
      context: context,
      respectStatusBar: true,
    );
    final availableHeight = screenHeight - calculatedTopOffset;

    final explicitModalHeight = calculateModalHeight(
      availableHeight: availableHeight,
      isScrollControlled: widget.isScrollControlled,
      scrollControlDisabledMaxHeightRatio:
          widget.scrollControlDisabledMaxHeightRatio,
    );

    final theme = Theme.of(context).bottomSheetTheme;
    final modalContent = buildModalContent(
      child: widget.child,
      childKey: _childKey,
      theme: theme,
      backgroundColor: widget.backgroundColor,
      shadowColor: widget.shadowColor,
      elevation: widget.elevation,
      shape: widget.shape,
      borderRadius: widget.borderRadius,
      clipBehavior: widget.clipBehavior,
      constraints: widget.constraints,
      useSafeArea: widget.useSafeArea,
      showDragHandle: widget.showDragHandle ?? false,
      onDragHandleTap: widget.onClosing,
      onDragHandleHover: (hovering) =>
          handleDragHandleHover(hovering: hovering),
      dragHandleStates: dragHandleStates,
      dragHandleColor: widget.dragHandleColor,
      dragHandleSize: widget.dragHandleSize,
    );

    final gestureDetector = widget.enableDrag
        ? forAnchoredSheet(
            onDragStart: handleDragStart,
            onDragUpdate: handleDragUpdate,
            onDragEnd: handleDragEnd,
            child: modalContent,
          )
        : modalContent;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Stack(
        children: [
          buildClickThroughArea(calculatedTopOffset),
          if (widget.isDismissible)
            buildDismissibleOverlay(
              topOffset: calculatedTopOffset,
              fadeAnimation: fadeAnimation,
              onTap: _dismiss,
              overlayColor: widget.overlayColor,
            ),
          buildPositionedModal(
            topOffset: calculatedTopOffset,
            height: explicitModalHeight,
            child: gestureDetector,
            slideAnimation: slideAnimation,
            fadeAnimation: fadeAnimation,
            onDismiss: _dismiss,
            backgroundColor: widget.backgroundColor,
            shape: widget.shape,
          ),
        ],
      ),
    );
  }
}

/// Shows an anchored modal sheet that slides down from the top of the screen.
///
/// This function creates a modal overlay similar to [showModalBottomSheet] but
/// positioned at the top. The sheet can be anchored to specific widgets using
/// [GlobalKey]s for precise positioning.
///
/// ## Smart Features (v1.2.0+)
///
/// **Duplicate Prevention**: When the same [anchorKey] is used while a sheet
/// is already open, the existing sheet will be dismissed instead of creating
/// a duplicate. This prevents UI flickering and provides intuitive toggle behavior.
///
/// **Automatic Replacement**: By default ([replaceSheet] = true), showing a new
/// sheet while another is open will smoothly replace the existing one. This
/// creates a seamless user experience.
///
/// **Modal Management**: Use [dismissOtherModals] to automatically dismiss
/// other types of modals (bottom sheets, dialogs) before showing the anchored sheet.
///
/// ## Example Usage
///
/// ```dart
/// final GlobalKey buttonKey = GlobalKey();
///
/// // Basic usage
/// anchoredSheet(
///   context: context,
///   builder: (context) => YourSheetContent(),
/// );
///
/// // Anchored to a specific widget
/// anchoredSheet(
///   context: context,
///   anchorKey: buttonKey,
///   builder: (context) => MenuContent(),
/// );
///
/// // With smart replacement and modal management
/// anchoredSheet(
///   context: context,
///   anchorKey: buttonKey,
///   dismissOtherModals: true,
///   replaceSheet: true, // Default
///   builder: (context) => FilterContent(),
/// );
/// ```
///
/// ## Parameters
///
/// ### Required
/// * [context] - The build context for showing the modal
/// * [builder] - Function that builds the sheet content
///
/// ### Positioning
/// * [anchorKey] - GlobalKey to anchor the sheet to a specific widget
/// * [topOffset] - Manual offset from the top (overrides anchor positioning)
/// * [useSafeArea] - Whether to respect status bar and device notches
///
/// ### Smart Behavior (NEW in v1.2.0)
/// * [replaceSheet] - Auto-replace existing sheets (default: true)
/// * [dismissOtherModals] - Dismiss other modals first (default: false)
/// * [toggleOnDuplicate] - Enable smart duplicate prevention (default: true)
///
/// ### Styling
/// * [backgroundColor] - Background color of the sheet
/// * [elevation] - Material elevation and shadow
/// * [shape] - Custom shape for the sheet
/// * [borderRadius] - Corner radius (convenience for shape)
/// * [clipBehavior] - How to clip the sheet content
/// * [constraints] - Size constraints for the sheet
///
/// ### Interaction
/// * [isDismissible] - Allow tap-outside-to-dismiss (default: true)
/// * [enableDrag] - Enable drag-to-dismiss gestures (default: false)
/// * [showDragHandle] - Show a drag handle at the top
/// * [dragHandleColor] - Color of the drag handle
/// * [dragHandleSize] - Size of the drag handle
///
/// ### Animation
/// * [animationDuration] - Duration of slide animation (default: 300ms)
/// * [overlayColor] - Color of the background overlay
///
/// ### Scroll Behavior
/// * [isScrollControlled] - Allow sheet to take full height
/// * [scrollControlDisabledMaxHeightRatio] - Max height ratio when not scroll controlled
///
/// ## Returns
///
/// A [Future] that completes when the sheet is dismissed, returning the value
/// passed to [context.popAnchoredSheet] or null if dismissed without a value.
///
/// ## See Also
///
/// * [context.popAnchoredSheet] for dismissing sheets
/// * [AnchoredSheetModalManager] for advanced modal management
Future<T?> anchoredSheet<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? shadowColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  BorderRadius? borderRadius,
  Color overlayColor = Colors.black54,
  Duration animationDuration = const Duration(milliseconds: 300),
  bool isDismissible = true,
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
  bool enableDrag = false,
  bool? showDragHandle,
  Color? dragHandleColor,
  Size? dragHandleSize,
  GlobalKey? anchorKey,
  double? topOffset,
  bool toggleOnDuplicate = true,
  bool useSafeArea = false,
  bool dismissOtherModals = false,
  bool replaceSheet = true, // Default to true for automatic replacement
}) async {
  // Check if there's an existing sheet
  final currentController = getCurrentController<dynamic>();
  if (currentController != null) {
    final currentAnchorKey = getCurrentAnchorKey();

    // Check if this is the same anchor (prevent duplicate)
    if (anchorKey != null &&
        anchorKey == currentAnchorKey &&
        toggleOnDuplicate) {
      // Same anchor key - dismiss instead of replace
      await dismissAnchoredSheet();
      return null;
    }

    // For non-anchored sheets, check if calling from same context/button
    // This could be enhanced further with additional context tracking

    if (replaceSheet) {
      // Automatic replacement - dismiss current and open new
      await dismissAnchoredSheet();
      // Minimal delay only when needed for smooth transition
      await Future<void>.delayed(const Duration(milliseconds: 16)); // One frame
      // Check if context is still mounted after the delay
      if (!context.mounted) return null;
    } else {
      // Legacy behavior when replaceSheet = false
      if (toggleOnDuplicate) {
        await dismissAnchoredSheet();
      }
      return null;
    }
  }

  // Handle dismissing other modals first
  if (dismissOtherModals) {
    await AnchoredSheetModalManager.dismissOtherModals(context);
  }

  final controller = GenericModalController<T>();
  setCurrentController(controller, anchorKey);

  final overlayEntry = OverlayEntry(
    builder: (context) => AnchoredSheet(
      controller: controller,
      onClosing: () {
        if (!controller.isCompleted) {
          controller.dismiss();
        }
      },
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      borderRadius: borderRadius,
      overlayColor: overlayColor,
      animationDuration: animationDuration,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      dragHandleColor: dragHandleColor,
      dragHandleSize: dragHandleSize,
      anchorKey: anchorKey,
      topOffset: topOffset,
      useSafeArea: useSafeArea,
      child: builder(context),
    ),
  );

  if (context.mounted) {
    Overlay.of(context).insert(overlayEntry);
  } else {
    // Context is no longer mounted, clean up and return null
    clearController();
    return null;
  }

  final result = await controller.future;

  overlayEntry.remove();
  clearController();

  return result;
}

/// Dismisses the currently active TopModalSheet without requiring a
/// BuildContext.
///
/// This is the preferred method for dismissing modals as it can be called
/// from anywhere in your code, including utility functions, services, or
/// callbacks that don't have access to a BuildContext.
///
/// ## Basic Usage
///
/// ```dart
/// // Simple dismissal (no type needed)
/// context.popAnchoredSheet();
///
/// // Dismissal with return value (String)
/// context.popAnchoredSheet<String>('confirmed');
///
/// // Dismissal with return value (Map)
/// context.popAnchoredSheet<Map<String, dynamic>>({'status': 'completed'});
///
/// // The type can be inferred from the parameter
/// context.popAnchoredSheet('hello'); // T is inferred as String
/// ```
///
/// ## In Button Callbacks
///
/// ```dart
/// ElevatedButton(
///   onPressed: () => context.popAnchoredSheet('confirmed'), // Type inferred
///   child: Text('Confirm'),
/// ),
/// ```
///
/// ## In Utility Functions
///
/// ```dart
/// class AppUtils {
///   static void closeModal(BuildContext context) {
///     context.popAnchoredSheet(); // Works with context!
///   }
///
///   static void closeWithResult(BuildContext context, String result) {
///     context.popAnchoredSheet(result); // Type automatically inferred as String
///   }
/// }
/// ```
///
/// ## Parameters
///
/// * [result] - Optional value to return when the modal completes.
///   This value will be returned by the Future from [showModalTopSheet].
///
/// ## Returns
///
/// Returns a [Future<void>] that completes when the dismissal animation
/// finishes.
///
/// ## Limitations
///
/// * Only works with one modal at a time (uses static references)
/// * If no modal is currently showing, prints a debug warning
///
/// ## See Also
///
/// * [dismissAnchoredSheetWithContext] - Context-based dismissal for advanced
///   use cases
/// * [showModalTopSheet] - For showing modals
Future<void> dismissAnchoredSheet<T extends Object?>([T? result]) async {
  // Try context-based dismissal through InheritedWidget first
  try {
    // Use the global navigator context if available
    final context = WidgetsBinding.instance.rootElement;
    if (context != null && context.mounted) {
      final provider = ModalDismissProvider.maybeOf(context);
      if (provider != null) {
        provider.onDismiss(result);
        return;
      }
    }
  } catch (e) {
    debugPrint('Warning: Could not dismiss through context provider: $e');
  }

  // Fallback: Try animated dismiss through current state
  final state = getCurrentState<_AnchoredSheetState>();
  if (state != null) {
    try {
      if (state.mounted) {
        await state._dismiss(result);
        return;
      }
    } on Exception catch (e) {
      debugPrint('Warning: Could not dismiss through state: $e');
    }
  }

  // Final fallback: controller-based dismissal
  final controller = getCurrentController<dynamic>();
  if (controller != null && controller is GenericModalController) {
    try {
      controller.dismiss(result);
      return;
    } on Exception catch (e) {
      debugPrint('Warning: Could not dismiss through controller: $e');
    }
  }

  debugPrint('Warning: No active modal found to dismiss');
}

/// Dismisses the TopModalSheet using BuildContext for provider-based dismissal.
///
/// This method provides backwards compatibility and supports advanced use cases
/// where multiple modals might exist in different parts of the widget tree.
/// It first attempts to find the modal through the widget tree using an
/// InheritedWidget provider, then falls back to the static reference approach.
///
/// ## Usage
///
/// ```dart
/// Widget build(BuildContext context) {
///   return ElevatedButton(
///     onPressed: () => context.popAnchoredSheet('result'),
///     // Type inferred
///     child: Text('Close with Context'),
///   );
/// }
/// ```
///
/// ## When to Use
///
/// * When you need to support multiple modals simultaneously
/// * For backwards compatibility with existing code
/// * When working within Flutter's InheritedWidget patterns
///
/// ## Parameters
///
/// * [context] - BuildContext for finding the modal through widget tree
/// * [result] - Optional value to return when dismissed
///
/// ## See Also
///
/// * [context.popAnchoredSheet] - Simpler context-based dismissal (recommended)
Future<void> dismissAnchoredSheetWithContext<T extends Object?>(
  BuildContext context, [
  T? result,
]) async {
  // Use the new context-based method
  context.popAnchoredSheet(result);
}
