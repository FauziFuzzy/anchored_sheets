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
///       context: capturedContext,
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

final AnchoredSheetRouteObserver anchoredObserver =
    AnchoredSheetRouteObserver();

/// Enhanced extension methods for BuildContext to provide
/// convenient anchored sheet operations with improved error handling
extension AnchoredSheetContext on BuildContext {
  /// Hide the current anchored sheet with enhanced error handling
  ///
  /// Returns `true` if a sheet was successfully dismissed, `false` otherwise.
  /// This method includes comprehensive error handling and logging.
  Future<bool> popAnchorSheet<T>([T? result]) async {
    if (!mounted) {
      AppLogger.w(
        'Cannot dismiss sheet: context not mounted',
        tag: 'AnchoredSheetContext',
      );
      return false;
    }

    try {
      final sheetPop = AnchoredSheetPop.of(this);
      if (sheetPop != null) {
        await sheetPop.pop(result);
        AppLogger.d(
          'Successfully dismissed anchored sheet',
          tag: 'AnchoredSheetContext',
        );
        return true;
      } else {
        AppLogger.d(
          'No active sheet found to dismiss',
          tag: 'AnchoredSheetContext',
        );
        return false;
      }
    } catch (error, stackTrace) {
      // Use Flutter's built-in error reporting
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'anchored_sheets',
          context: ErrorDescription('Failed to dismiss anchored sheet'),
        ),
      );
      AppLogger.e(
        'Failed to dismiss anchored sheet',
        error: error,
        stackTrace: stackTrace,
        tag: 'AnchoredSheetContext',
      );
      return false;
    }
  }

  /// Check if an anchored sheet is currently showing
  ///
  /// Returns `true` if there's an active anchored sheet, `false` otherwise.
  /// This method provides a way to check sheet status without
  /// attempting dismissal.
  bool get hasActiveAnchorSheet {
    // Use Flutter's built-in error handling with try-catch
    try {
      return AnchoredSheetPop.of(this) != null || ActiveSheetTracker.hasActive;
    } catch (error, stackTrace) {
      // Use Flutter's built-in error reporting
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'anchored_sheets',
          context: ErrorDescription('Error checking active sheet status'),
        ),
      );
      AppLogger.w(
        'Error checking active sheet status',
        error: error,
        stackTrace: stackTrace,
        tag: 'AnchoredSheetContext',
      );
      return false;
    }
  }

  /// Navigate to a screen and automatically
  /// reopen an anchored sheet with the result.
  ///
  /// This method provides a complete flow for selection patterns:
  /// 1. Shows initial anchored sheet with null data
  /// 2. Dismisses current anchored sheet when user proceeds
  /// 3. Navigates using the provided navigation function
  /// 4. Reopens the same anchored sheet with the navigation result
  /// 5. Returns the final result from the reopened sheet
  ///
  /// The sheet builder receives null initially, then the navigation result.
  /// Developers can handle both states in one builder function.
  ///
  /// **Back Button Behavior**: If the user presses back during navigation
  /// (returning null), the sheet will not reopen by default. Set
  /// `config.reopenOnlyIfResult = false` to always reopen the sheet.
  ///
  /// Example with standard Route:
  /// ```dart
  /// final result = await context.navigateAndReopenAnchor(
  ///   navigate: () => Navigator.push(
  ///     context,
  ///     MaterialPageRoute(builder: (context) => SelectionScreen()),
  ///   ),
  ///   sheetBuilder: (selectedValue) => selectedValue == null
  ///     ? InitialSheetContent()
  ///     : ResultSheetContent(value: selectedValue),
  ///   anchorKey: myButtonKey,
  /// );
  /// ```
  ///
  /// Example with auto_route:
  /// ```dart
  /// final result = await context.navigateAndReopenAnchor(
  ///   navigate: () => context.pushRoute(SelectionPageRoute()),
  ///   sheetBuilder: (data) => MySheet(navigationResult: data),
  ///   anchorKey: myButtonKey,
  /// );
  /// ```
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
    // Use active sheet tracker (preserves result)
    final topmostController = ActiveSheetTracker.topmostController;
    if (topmostController != null && !topmostController.isDisposed) {
      topmostController.dismiss(result);
      return;
    }

    // Try modal manager from widget tree
    final modalManager = ModalManager.maybeOf(_context);
    if (modalManager != null) {
      modalManager.requestDismiss();
      return;
    }

    // Try Navigator.pop for route-based modals
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

/// Enhanced AnchoredSheetState with RouteObserver auto-dismiss
class _AnchoredSheetState extends AnchoredSheetState<AnchoredSheet> {
  static const _childKeyDebugLabel = 'AnchoredSheet child';
  final GlobalKey _childKey = GlobalKey(debugLabel: _childKeyDebugLabel);

  double? _cachedTopOffset;
  double? _cachedModalHeight;

  @override
  void initState() {
    super.initState();
    // Use Flutter's built-in controller management
    widget.controller?.setStateCallback(_updateState);

    // Set up animated dismissal callback
    widget.controller?.setAnimatedDismissCallback(() async {
      await animateOut();
    });

    // Register controller with RouteObserver for auto-dismiss
    if (widget.controller != null) {
      anchoredObserver.registerController(widget.controller!);
    }

    // Start animation immediately to prevent glitches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        animateIn();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _recalculateOffsetAndHeight();
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

  @override
  void dispose() {
    // Unregister controller from RouteObserver
    if (widget.controller != null) {
      anchoredObserver.unregisterController(widget.controller!);
    }

    // Use Flutter's built-in cleanup pattern
    widget.controller?.setStateCallback(null);
    widget.controller?.setAnimatedDismissCallback(null);
    super.dispose();
  }

  void _updateState() {
    // Use Flutter's built-in state update pattern
    if (mounted) {
      setState(() {});
    }
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

  bool _shouldRecalculateOffset(AnchoredSheet oldWidget) {
    return oldWidget.anchorKey != widget.anchorKey ||
        oldWidget.topOffset != widget.topOffset;
  }

  bool _shouldUpdateCachedValues(AnchoredSheet oldWidget) {
    return oldWidget.isScrollControlled != widget.isScrollControlled ||
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

  void _updateCachedValues() {
    final topOffset = _cachedTopOffset;
    if (topOffset == null) return;

    final screenHeight =
        MediaQuery.sizeOf(context).height; // Use Flutter's built-in MediaQuery
    final availableHeight = screenHeight - topOffset;

    _cachedModalHeight = calculateModalHeight(
      availableHeight:
          widget.isScrollControlled ? screenHeight : availableHeight,
      isScrollControlled: widget.isScrollControlled,
      hasAnchorKey: widget.anchorKey != null,
    );
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
      constraints: widget.constraints,
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
              onTap: () {
                // First animate out, then dismiss the controller
                animateOut().then((_) {
                  if (!widget.controller!.isCompleted) {
                    widget.controller!.dismiss();
                  }
                });
              },
              overlayColor: widget.overlayColor,
            ),
          buildPositionedModal(
            topOffset: calculatedTopOffset,
            height: explicitModalHeight,
            child: gestureDetector,
            slideAnimation: slideAnimation,
            fadeAnimation: fadeAnimation,
            backgroundColor: widget.backgroundColor,
            shape: widget.shape,
            isScrollControlled: widget.isScrollControlled,
            hasAnchorKey: widget.anchorKey != null,
          ),
        ],
      ),
    );

    return result;
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
/// a duplicate. This prevents UI flickering
/// and provides intuitive toggle behavior.
///
/// **Automatic Replacement**: Showing a new sheet while another is open will
/// automatically replace the existing one.
/// This creates a seamless user experience
/// without requiring additional configuration.
///
/// **Built-in Intelligence**: All duplicate prevention and sheet replacement
/// behaviors are built into the library, requiring no additional parameters or
/// state management from the developer.
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
/// * [enableNested] - Enable nested stacking for same anchor key
/// (default: false)
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
///
/// ## Returns
///
/// A [Future] that completes when the sheet is dismissed, returning the value
/// passed to [context.popAnchorSheet] or null if dismissed without a value.
///
/// ## See Also
///
/// * [context.popAnchorSheet] for dismissing sheets
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
  bool enableDrag = false,
  bool? showDragHandle,
  Color? dragHandleColor,
  Size? dragHandleSize,
  GlobalKey? anchorKey,
  double? topOffset,
  bool useSafeArea = false,
  bool enableNested = false,
}) async {
  return anchoredSheetInternal<T>(
    context: context,
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
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    dragHandleColor: dragHandleColor,
    dragHandleSize: dragHandleSize,
    anchorKey: anchorKey,
    topOffset: topOffset,
    useSafeArea: useSafeArea,
    enableNested: enableNested,
  );
}

/// Internal implementation of anchoredSheet with nested logic
Future<T?> anchoredSheetInternal<T>({
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
  bool enableDrag = false,
  bool? showDragHandle,
  Color? dragHandleColor,
  Size? dragHandleSize,
  GlobalKey? anchorKey,
  double? topOffset,
  bool useSafeArea = false,
  bool enableNested = false,
}) async {
  // Capture context early to avoid async gap issues
  final capturedContext = context;

  // Handle nested stacking if enabled
  if (enableNested && anchorKey != null) {
    AppLogger.d(
      'Nested mode enabled for anchor key: $anchorKey - allowing stacking',
      tag: 'AnchoredSheet',
    );
    // Skip duplicate prevention - allow nesting on same anchor key
  }

  // Enhanced duplicate prevention - check immediately before any work
  // Skip duplicate prevention if nested mode is enabled
  if (ActiveSheetTracker.hasActive && !enableNested) {
    final currentController = ActiveSheetTracker.currentController;
    final currentAnchorKey = ActiveSheetTracker.currentAnchorKey;

    // Handle duplicate anchor keys with animated dismissal (built-in behavior)
    if (anchorKey != null && anchorKey == currentAnchorKey) {
      AppLogger.i(
        'Duplicate anchor key detected - '
        'triggering animated dismissal (key: $anchorKey)',
        tag: 'AnchoredSheet',
      );
      // Trigger animated dismissal using the new callback mechanism
      if (!currentController!.isCompleted) {
        currentController.dismissWithAnimation();
      }
      return null; // Immediate return - no further processing
    }

    // Handle sheet replacement logic if different anchor keys
    // (built-in behavior)
    // Allow nesting when new sheet has no anchor key (non-anchored sheets)
    if (anchorKey != null && anchorKey != currentAnchorKey) {
      AppLogger.i(
        'Different anchor key - replacing existing sheet',
        tag: 'AnchoredSheet',
      );
      currentController?.dismiss();
      // Small delay to allow dismissal to start
      await Future<void>.delayed(const Duration(milliseconds: 10));
    } else if (anchorKey == null) {
      AppLogger.d(
        'Non-anchored sheet - allowing nesting on top of existing',
        tag: 'AnchoredSheet',
      );
    }
  } else if (enableNested) {
    AppLogger.d(
      'Nested mode active - allowing multiple sheets on same anchor key',
      tag: 'AnchoredSheet',
    );
  }

  // Handle dismissing other modals first (built-in behavior disabled)
  // This behavior is commented out to avoid interfering with normal modal flows
  // if (capturedContext.mounted) {
  //   await ModalManager.dismissOtherModals(capturedContext);
  // }

  // Check context is still mounted after async operations
  if (!capturedContext.mounted) {
    AppLogger.w(
      'Context no longer mounted after async operations',
      tag: 'AnchoredSheet',
    );
    return null;
  }

  final controller = ModalController<T>();

  try {
    // Add ALL sheets to the stack for proper dismissal order
    // The stack handles both anchored and non-anchored sheets
    AppLogger.d(
      'Creating new anchored sheet with key: $anchorKey',
      tag: 'AnchoredSheet',
    );
    ActiveSheetTracker.setActive(controller, anchorKey);

    final overlayEntry = _createOverlayEntry<T>(
      originalContext: capturedContext,
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
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      dragHandleColor: dragHandleColor,
      dragHandleSize: dragHandleSize,
      anchorKey: anchorKey,
      topOffset: topOffset,
      useSafeArea: useSafeArea,
    );

    if (capturedContext.mounted) {
      Overlay.of(capturedContext).insert(overlayEntry);
    } else {
      // Context is no longer mounted, dispose controller and return null
      controller.dispose();
      return null;
    }

    final result = await controller.future;

    overlayEntry.remove();
    controller.dispose();

    return result;
  } catch (error, stackTrace) {
    // Use Flutter's built-in error reporting
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'anchored_sheets',
        context: ErrorDescription('Error creating anchored sheet'),
      ),
    );
    AppLogger.e(
      'Error creating anchored sheet',
      error: error,
      stackTrace: stackTrace,
      tag: 'AnchoredSheet',
    );
    controller.dispose();
    return null;
  }
}

/// Helper function to create overlay entry with context inheritance
///
/// Uses Flutter's built-in InheritedTheme.captureAll() to automatically
/// capture and preserve all inherited widgets (like Providers, Themes, etc.)
/// from the original context and make them available in the overlay.
OverlayEntry _createOverlayEntry<T extends Object?>({
  required BuildContext originalContext,
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
  required bool enableDrag,
  required bool? showDragHandle,
  required Color? dragHandleColor,
  required Size? dragHandleSize,
  required GlobalKey? anchorKey,
  required double? topOffset,
  required bool useSafeArea,
}) {
  return OverlayEntry(
    builder: (overlayContext) => InheritedTheme.captureAll(
      originalContext,
      ModalManager(
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
          enableDrag: enableDrag,
          showDragHandle: showDragHandle,
          dragHandleColor: dragHandleColor,
          dragHandleSize: dragHandleSize,
          anchorKey: anchorKey,
          topOffset: topOffset,
          useSafeArea: useSafeArea,
          child: builder(overlayContext),
        ),
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
/// context.popAnchorSheet();
///
/// // Dismissal with return value (String)
/// context.popAnchorSheet<String>('confirmed');
///
/// // Dismissal with return value (Map)
/// context.popAnchorSheet<Map<String, dynamic>>({'status': 'completed'});
///
/// // The type can be inferred from the parameter
/// context.popAnchorSheet('hello'); // T is inferred as String
/// ```
///
/// ## In Button Callbacks
///
/// ```dart
/// ElevatedButton(
///   onPressed: () => context.popAnchorSheet('confirmed'), // Type inferred
///   child: Text('Confirm'),
/// ),
/// ```
///
/// ## In Utility Functions
///
/// ```dart
/// class AppUtils {
///   static void closeModal(BuildContext context) {
///     context.popAnchorSheet(); // Works with context!
///   }
///
///   static void closeWithResult(BuildContext context, String result) {
///     context.popAnchorSheet(result); // Type automatically inferred as String
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
    AppLogger.w(
      'Could not dismiss through context',
      error: e,
      tag: 'DismissAnchoredSheet',
    );
  }

  AppLogger.w('No active modal found to dismiss', tag: 'DismissAnchoredSheet');
}
