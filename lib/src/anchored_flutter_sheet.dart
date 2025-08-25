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
  Future<void> popAnchoredSheet<T>([T? result]) async {
    await AnchoredSheetPop.of(this)?.pop(result);
  }
}

/// AnchoredSheetPop utility class for context-based dismissal
class AnchoredSheetPop {
  const AnchoredSheetPop._(this._context);

  final BuildContext _context;

  /// Get AnchoredSheetPop instance from context
  static AnchoredSheetPop? of(BuildContext context) {
    return AnchoredSheetPop._(context);
  }

  /// Hide/dismiss the anchored sheet
  Future<void> pop<T>([T? result]) async {
    // Priority 1: Use active sheet tracker (preserves result)
    final topmostController = ActiveSheetTracker.topmostController;
    if (topmostController != null && !topmostController.isDisposed) {
      topmostController.dismiss(result);
      return;
    }

    // Priority 2: Try modal manager from widget tree
    final modalManager = ModalManager.maybeOf(_context);
    if (modalManager != null) {
      modalManager.requestDismiss();
      return;
    }

    // Priority 3: Try Navigator.pop for route-based modals
    if (Navigator.canPop(_context)) {
      Navigator.pop(_context, result);
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
  final ModalController<dynamic>? controller;
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

class _AnchoredSheetState extends AnchoredSheetState<AnchoredSheet> {
  static const _childKeyDebugLabel = 'AnchoredSheet child';
  final GlobalKey _childKey = GlobalKey(debugLabel: _childKeyDebugLabel);

  bool get dismissUnderway => controller.status == AnimationStatus.reverse;

  double? _cachedTopOffset;
  double? _cachedModalHeight;

  @override
  void initState() {
    super.initState();
    widget.controller?.setStateCallback(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculateOffsetAndHeight();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) animateIn();
    });
  }

  void _recalculateOffsetAndHeight() {
    _cachedTopOffset = calculateTopOffset(
      anchorKey: widget.anchorKey,
      topOffset: widget.topOffset,
      context: context,
      respectStatusBar: widget.isScrollControlled,
    );
    _updateCachedValues();
  }

  @override
  void didUpdateWidget(AnchoredSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldRecalculateOffset(oldWidget)) {
      _recalculateOffsetAndHeight();
    } else if (_shouldUpdateCachedValues(oldWidget)) {
      _updateCachedValues();
    }
  }

  bool _shouldRecalculateOffset(AnchoredSheet oldWidget) {
    return oldWidget.anchorKey != widget.anchorKey ||
        oldWidget.topOffset != widget.topOffset;
  }

  bool _shouldUpdateCachedValues(AnchoredSheet oldWidget) {
    return oldWidget.isScrollControlled != widget.isScrollControlled ||
        oldWidget.scrollControlDisabledMaxHeightRatio !=
            widget.scrollControlDisabledMaxHeightRatio ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.shadowColor != widget.shadowColor ||
        oldWidget.elevation != widget.elevation ||
        oldWidget.shape != widget.shape ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.clipBehavior != widget.clipBehavior ||
        oldWidget.constraints != widget.constraints ||
        oldWidget.useSafeArea != widget.useSafeArea ||
        oldWidget.showDragHandle != widget.showDragHandle ||
        oldWidget.dragHandleColor != widget.dragHandleColor ||
        oldWidget.dragHandleSize != widget.dragHandleSize ||
        oldWidget.enableDrag != widget.enableDrag;
  }

  @override
  void dispose() {
    widget.controller?.setStateCallback(null);
    super.dispose();
  }

  Future<void> dismissModal() => animateOut();

  void _updateCachedValues() {
    final topOffset = _cachedTopOffset;
    if (topOffset == null) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - topOffset;

    _cachedModalHeight = calculateModalHeight(
      availableHeight:
          widget.isScrollControlled ? screenHeight : availableHeight,
      isScrollControlled: widget.isScrollControlled,
      scrollControlDisabledMaxHeightRatio:
          widget.scrollControlDisabledMaxHeightRatio,
    );
  }

  Future<void> _dismiss<T extends Object?>([T? result]) async {
    await dismissModal();
    widget.controller?.dismiss(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final calculatedTopOffset = _cachedTopOffset ?? 0.0;
    final topPadding = MediaQuery.of(context).padding.top;

    // Use cached modal height for better performance
    final explicitModalHeight = _cachedModalHeight ?? 200.0;

    final removedSpacingTop = widget.useSafeArea &&
        (widget.isScrollControlled || calculatedTopOffset > topPadding);

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
      useSafeArea: removedSpacingTop,
      isScrollControlled: widget.isScrollControlled,
      hasAnchorKey: widget.anchorKey != null,
      showDragHandle: widget.showDragHandle ?? false,
      onDragHandleTap: widget.onClosing,
      onDragHandleHover: null,
      dragHandleStates: const <WidgetState>{},
      dragHandleColor: widget.dragHandleColor,
      dragHandleSize: widget.dragHandleSize,
    );

    final gestureDetector = widget.enableDrag
        ? DraggableDismissible(
            onDismiss: widget.onClosing,
            child: modalContent,
          )
        : modalContent;

    final result = AnimatedBuilder(
      animation: controller,
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
            isScrollControlled: widget.isScrollControlled,
          ),
        ],
      ),
    );

    return result;
  }
}

/// Helper function to handle sheet replacement logic
Future<bool?> _handleSheetReplacement({
  required bool dismissOtherModals,
  required GlobalKey? currentAnchorKey,
  required GlobalKey? anchorKey,
  required ModalController<dynamic>? currentController,
  required bool replaceSheet,
  required bool toggleOnDuplicate,
  required BuildContext context,
}) async {
  if (!dismissOtherModals) {
    if (currentAnchorKey != null &&
        anchorKey != null &&
        currentAnchorKey != anchorKey) {
      // Different anchor keys - replace the anchored sheet
      currentController?.dismiss();
      await Future<void>.delayed(const Duration(milliseconds: 16));
      return context.mounted;
    } else if (anchorKey == null) {
      // No anchor key on new sheet - allow stacking
      return true;
    } else if (replaceSheet) {
      currentController?.dismiss();
      await Future<void>.delayed(const Duration(milliseconds: 16));
      return context.mounted;
    }
  } else if (replaceSheet) {
    currentController?.dismiss();
    await Future<void>.delayed(const Duration(milliseconds: 16));
    return context.mounted;
  } else if (toggleOnDuplicate) {
    currentController?.dismiss();
    return false;
  }
  return true;
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
/// a duplicate. This prevents UI flickering
/// and provides intuitive toggle behavior.
///
/// **Automatic Replacement**: By default ([replaceSheet] = true), showing a new
/// sheet while another is open will smoothly replace the existing one. This
/// creates a seamless user experience.
///
/// **Modal Management**: Use [dismissOtherModals] to automatically dismiss
/// other types of modals (bottom sheets, dialogs)
/// before showing the anchored sheet.
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
/// * [scrollControlDisabledMaxHeightRatio]
/// - Max height ratio when not scroll controlled
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
Future<T?> anchoredSheet<T>({
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
  // Check if there's an existing sheet using the tracker
  if (ActiveSheetTracker.hasActive) {
    final currentController = ActiveSheetTracker.currentController;
    final currentAnchorKey = ActiveSheetTracker.currentAnchorKey;

    // Handle duplicate anchor keys
    if (anchorKey != null &&
        anchorKey == currentAnchorKey &&
        toggleOnDuplicate) {
      currentController?.dismiss();
      return null;
    }

    // Handle sheet replacement logic
    final shouldDismiss = await _handleSheetReplacement(
      dismissOtherModals: dismissOtherModals,
      currentAnchorKey: currentAnchorKey,
      anchorKey: anchorKey,
      currentController: currentController,
      replaceSheet: replaceSheet,
      toggleOnDuplicate: toggleOnDuplicate,
      context: context,
    );

    if (shouldDismiss == false) return null;
  }

  // Handle dismissing other modals first
  if (dismissOtherModals && context.mounted) {
    await ModalManager.dismissOtherModals(context);
  }

  final controller = ModalController<T>();
  // Add ALL sheets to the stack for proper dismissal order
  // The stack handles both anchored and non-anchored sheets
  ActiveSheetTracker.setActive(controller, anchorKey);

  final overlayEntry = _createOverlayEntry<T>(
    controller: controller,
    builder: builder,
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
  );

  if (context.mounted) {
    Overlay.of(context).insert(overlayEntry);
  } else {
    // Context is no longer mounted, dispose controller and return null
    controller.dispose();
    return null;
  }

  final result = await controller.future;

  overlayEntry.remove();
  controller.dispose();

  return result;
}

/// Helper function to create overlay entry
OverlayEntry _createOverlayEntry<T extends Object?>({
  required ModalController<T> controller,
  required WidgetBuilder builder,
  required Color? backgroundColor,
  required Color? shadowColor,
  required double? elevation,
  required ShapeBorder? shape,
  required Clip? clipBehavior,
  required BoxConstraints? constraints,
  required BorderRadius? borderRadius,
  required Color overlayColor,
  required Duration animationDuration,
  required bool isDismissible,
  required bool isScrollControlled,
  required double scrollControlDisabledMaxHeightRatio,
  required bool enableDrag,
  required bool? showDragHandle,
  required Color? dragHandleColor,
  required Size? dragHandleSize,
  required GlobalKey? anchorKey,
  required double? topOffset,
  required bool useSafeArea,
}) {
  return OverlayEntry(
    builder: (context) => ModalManager(
      onDismissRequest: () {
        if (!controller.isCompleted) {
          controller.dismiss();
        }
      },
      child: AnchoredSheet(
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
        scrollControlDisabledMaxHeightRatio:
            scrollControlDisabledMaxHeightRatio,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        dragHandleColor: dragHandleColor,
        dragHandleSize: dragHandleSize,
        anchorKey: anchorKey,
        topOffset: topOffset,
        useSafeArea: useSafeArea,
        child: builder(context),
      ),
    ),
  );
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
    final context = WidgetsBinding.instance.rootElement;
    if (context != null && context.mounted) {
      final modalManager = ModalManager.maybeOf(context);
      if (modalManager != null) {
        modalManager.requestDismiss();
        return;
      }

      // Try active sheet tracker
      if (ActiveSheetTracker.hasActive) {
        ActiveSheetTracker.currentController?.dismiss(result);
        return;
      }
    }
  } catch (e) {
    debugPrint('Warning: Could not dismiss through context: $e');
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
