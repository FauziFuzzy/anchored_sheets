/// # Anchored Layout Builder
///
/// This module provides layout utilities for building anchored modal sheets
/// that slide down from the top of the screen. It handles Material Design
/// theming, safe area considerations, status bar overlap prevention, and
/// automatic sizing based on content.
///
/// ## Key Features
///
/// * 🎯 **Smart Positioning** - Automatic anchoring to widgets with status
///   bar awareness
/// * 📏 **Natural Sizing** - Supports MainAxisSize.min for content-based height
/// * 🎨 **Material Theming** - Full Material Design integration with
///   theming support
/// * 📱 **Status Bar Handling** - Seamless status bar background extension
///   and safe area
/// * 🎬 **Smooth Animations** - Coordinated slide and fade animations
/// * 🖱️ **Drag Support** - Optional drag handles with hover states
///
/// ## Architecture
///
/// The layout system follows Flutter's constraint-based approach, similar to
/// showModalBottomSheet:
/// - Uses `ConstrainedBox` with `maxHeight` instead of fixed `SizedBox` heights
/// - Automatically detects and supports `MainAxisSize.min` behavior
/// - Extends status bar background when sheets overlap with system UI
/// - Provides proper width constraints to prevent horizontal truncation
///
/// ## Status Bar Handling
///
/// When a sheet would overlap with the status bar
/// (`topOffset <= statusBarHeight`):
/// 1. Creates a background extension that matches the sheet's styling
/// 2. Maintains proper slide animations for the entire container
/// 3. Ensures content takes full width to prevent truncation
/// 4. Respects safe area constraints for content positioning
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Builds a positioned modal content with Material theming
///
/// This is the core content builder that wraps child widgets in Material Design
/// components with proper theming, elevation, and shape support.
///
/// ## Features
///
/// * **Material Theming** - Integrates with app theme and BottomSheetThemeData
/// * **Drag Handle Support** - Optional drag handle with hover states and
///   semantics
/// * **Safe Area Integration** - Respects system UI when `useSafeArea` is
///   enabled
/// * **Shape & Clipping** - Full shape border and clipping behavior support
/// * **Constraints** - Optional size constraints with proper alignment
///
/// ## Parameters
///
/// * `child` - The main content widget to be wrapped
/// * `childKey` - Global key for accessing the rendered size and position
/// * `theme` - Optional bottom sheet theme data for styling
/// * `useSafeArea` - Whether to apply safe area insets (bottom only by default)
/// * `showDragHandle` - Whether to show a drag handle at the bottom
/// * `constraints` - Optional size constraints for the content
///
/// ## Theme Resolution
///
/// The function follows Flutter's theme resolution pattern:
/// 1. Explicit parameters (backgroundColor, elevation, etc.)
/// 2. Provided BottomSheetThemeData
/// 3. Default Material Design values
///
/// ## Example
///
/// ```dart
/// buildModalContent(
///   child: MySheetContent(),
///   childKey: globalKey,
///   backgroundColor: Colors.white,
///   elevation: 8,
///   showDragHandle: true,
///   useSafeArea: true,
/// )
/// ```
Widget buildModalContent({
  required Widget child,
  required GlobalKey childKey,
  BottomSheetThemeData? theme,
  Color? backgroundColor,
  Color? shadowColor,
  double? elevation,
  ShapeBorder? shape,
  BorderRadius? borderRadius,
  Clip? clipBehavior,
  bool useSafeArea = false,
  bool showDragHandle = false,
  bool isScrollControlled = false,
  bool hasAnchorKey = false,
  VoidCallback? onDragHandleTap,
  ValueChanged<bool>? onDragHandleHover,
  Set<WidgetState>? dragHandleStates,
  Color? dragHandleColor,
  Size? dragHandleSize,
}) {
  final effectiveTheme = theme ?? const BottomSheetThemeData();
  final effectiveBackgroundColor =
      backgroundColor ?? effectiveTheme.backgroundColor;
  final effectiveShadowColor = shadowColor ?? effectiveTheme.shadowColor;
  final effectiveElevation = elevation ?? effectiveTheme.elevation ?? 0;
  final effectiveShape = shape ??
      (borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius)
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ));
  final effectiveClipBehavior =
      clipBehavior ?? effectiveTheme.clipBehavior ?? Clip.none;

  Widget content = Material(
    key: childKey,
    color: effectiveBackgroundColor,
    elevation: effectiveElevation,
    shadowColor: effectiveShadowColor,
    shape: effectiveShape,
    clipBehavior: effectiveClipBehavior,
    child: showDragHandle
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: child),
              DragHandle(
                onSemanticsTap: onDragHandleTap,
                onHover: onDragHandleHover ?? (_) {},
                states: dragHandleStates ?? <WidgetState>{},
                color: dragHandleColor,
                size: dragHandleSize,
              ),
            ],
          )
        : child,
  );

  if (useSafeArea) {
    content = SafeArea(
      // Smart SafeArea logic:
      top: !hasAnchorKey && !isScrollControlled,
      left: false,
      right: false,
      bottom: isScrollControlled,
      child: content,
    );
  }

  return content;
}

/// Builds a click-through area above the modal
///
/// Creates a transparent, non-interactive area above the modal that allows
/// touch events to pass through to underlying widgets. This is used to
/// maintain proper touch behavior for areas above the modal sheet.
///
/// ## Parameters
///
/// * `topOffset` - The height of the click-through area
/// (typically the modal's top position)
///
/// ## Usage
///
/// This is automatically used in modal stacks to ensure that areas above
/// the modal don't interfere with touch events while still maintaining
/// proper positioning and layout.
///
/// ```dart
/// Stack(
///   children: [
///     buildClickThroughArea(calculatedTopOffset),
///     // ... other modal components
///   ],
/// )
/// ```
Widget buildClickThroughArea(double topOffset) {
  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    height: topOffset,
    child: IgnorePointer(child: Container(color: Colors.transparent)),
  );
}

/// Builds a dismissible overlay behind the modal
///
/// Creates an animated overlay that covers the area behind the modal sheet,
/// providing visual feedback and tap-to-dismiss functionality.
///
/// ## Features
///
/// * **Animated Appearance** - Fades in/out with the modal using provided
///   animation
/// * **Tap to Dismiss** - Handles tap events to close the modal
/// * **Customizable Color** - Supports custom overlay colors with alpha
///   blending
/// * **Proper Positioning** - Covers area from modal top to screen bottom
///
/// ## Parameters
///
/// * `topOffset` - Starting position of the overlay (where modal begins)
/// * `fadeAnimation` - Animation controller for fade in/out effects
/// * `onTap` - Callback function when overlay is tapped (typically dismisses
///   modal)
/// * `overlayColor` - Background color with alpha for the overlay effect
///
/// ## Implementation Details
///
/// The overlay uses `AnimatedBuilder` to smoothly transition the alpha value
/// of the background color, creating a professional fade effect that matches
/// Material Design specifications.
///
/// ```dart
/// buildDismissibleOverlay(
///   topOffset: calculatedTopOffset,
///   fadeAnimation: fadeAnimation,
///   onTap: () => Navigator.pop(context),
///   overlayColor: Colors.black54,
/// )
/// ```
Widget buildDismissibleOverlay({
  required double topOffset,
  required Animation<double> fadeAnimation,
  required VoidCallback onTap,
  Color overlayColor = Colors.black54,
}) {
  return Positioned(
    top: topOffset,
    left: 0,
    right: 0,
    bottom: 0,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: fadeAnimation,
        builder: (context, child) => Container(
          color: overlayColor.withValues(alpha: fadeAnimation.value * 0.5),
        ),
      ),
    ),
  );
}

/// Builds the main positioned modal with animations and status bar handling
///
/// This is the core layout function that positions modal content with proper
/// animations, constraint-based sizing, and status bar intelligence.
/// automatic sizing support, and intelligent status bar overlap handling.
///
/// ## Key Features
///
/// * **MainAxisSize.min Support** - Automatically sizes based on content
///   using constraint-based layout
/// * **Status Bar Intelligence** - Detects and handles status bar overlap
///   with background extension
/// * **Smooth Animations** - Coordinated slide and fade animations for
///   professional appearance
/// * **Width Preservation** - Prevents horizontal truncation when extending
///   to status bar
/// * **Flexible Positioning** - Supports both anchored and absolute positioning
///
/// ## Status Bar Handling Logic
///
/// When `topOffset <= statusBarHeight`, the function automatically:
/// 1. **Extends Background** - Creates a status bar background matching the
///    sheet color
/// 2. **Maintains Animation** - Applies slide animation to the entire
///    extended container
/// 3. **Preserves Width** - Ensures content takes full width to prevent
///    truncation
/// 4. **Seamless Appearance** - Creates visual continuity between status bar
///    and modal
///
/// ## MainAxisSize.min Support
///
/// Unlike traditional fixed-height approaches, this function uses
/// `ConstrainedBox` with `maxHeight` constraints, allowing content with
/// `MainAxisSize.min` to size naturally:
///
/// ```dart
/// Column(
///   mainAxisSize: MainAxisSize.min, // ✅ Works perfectly
///   children: [...],
/// )
/// ```
///
/// ## Parameters
///
/// * `topOffset` - Initial position offset from top of screen
/// * `height` - Maximum height constraint for the modal
/// * `child` - The modal content widget
/// * `slideAnimation` - Animation for slide down/up movement
/// * `fadeAnimation` - Animation for fade in/out effects
/// * `onDismiss` - Optional callback for dismissal events
/// * `backgroundColor` - Background color for status bar extension
/// * `shape` - Shape border for styling (currently used for color matching)
///
/// ## Animation Behavior
///
/// * **Normal Position**: `top = topOffset - (slideAnimation.value * height)`
/// * **Status Bar Extension**: `top = -slideAnimation.value * height`
///   (starts from -height, ends at 0)
///
/// This ensures smooth animations regardless of status bar interaction.
///
/// ## Example Usage
///
/// ```dart
/// buildPositionedModal(
///   topOffset: 100,
///   height: 400,
///   child: MyModalContent(),
///   slideAnimation: slideController,
///   fadeAnimation: fadeController,
///   backgroundColor: Colors.white,
/// )
/// ```
Widget buildPositionedModal({
  required double topOffset,
  required double height,
  required Widget child,
  required Animation<double> slideAnimation,
  required Animation<double> fadeAnimation,
  void Function(dynamic)? onDismiss,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool hasAnchorKey = false,
  bool isScrollControlled = false,
}) {
  return Builder(
    builder: (context) {
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final shouldExtendToStatusBar =
          isScrollControlled && topOffset <= statusBarHeight;
      final screenHeight = MediaQuery.sizeOf(context).height;

      // Create the base content with proper scroll constraints
      Widget content = FadeTransition(
        opacity: fadeAnimation,
        child: onDismiss != null
            ? _ModalProvider(onDismiss: onDismiss, child: child)
            : child,
      );

      // Apply consistent constraint strategy for both scroll controlled and
      // non-scroll controlled sheets to support MainAxisSize.min
      final maxHeight = isScrollControlled
          ? (shouldExtendToStatusBar
              ? screenHeight
              : (screenHeight - topOffset))
          : height;

      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          // Don't set minHeight - let the child determine its natural height
          // This enables MainAxisSize.min to work properly
        ),
        child: ClipRect(child: content),
      );

      // If sheet overlaps with status bar, extend background and respect
      // safe area
      if (shouldExtendToStatusBar) {
        // Use a single Material container for unified rendering
        return Positioned(
          top: slideAnimation.value * height,
          left: 0,
          right: 0,
          child: content,
        );
      } else {
        // Calculate animation start position based on whether we have an anchor
        return Positioned(
          top: topOffset + (slideAnimation.value * height),
          left: 0,
          right: 0,
          child: content,
        );
      }
    },
  );
}

/// Calculates the appropriate top offset for anchored modals
///
/// This function determines where to position a modal sheet based on anchor
/// points, safe area constraints, and status bar considerations.
/// explicit offsets, and status bar considerations.
///
/// ## Calculation Priority
///
/// 1. **Anchor Key** - If provided, positions below the anchored widget
/// 2. **Explicit Offset** - Falls back to provided topOffset value
/// 3. **Status Bar Respect** - Optionally ensures minimum distance from
///    status bar
///
/// ## Anchor Key Positioning
///
/// When an anchor key is provided:
/// ```dart
/// final position = renderBox.localToGlobal(Offset.zero);
/// return position.dy + renderBox.size.height; // Bottom of anchor widget
/// ```
///
/// ## Status Bar Intelligence
///
/// When `respectStatusBar` is true and calculated offset is very small
/// (< 50px):
/// - Ensures the modal doesn't appear too close to or under the status bar
/// - Uses `math.max(calculatedOffset, statusBarHeight)` for safe positioning
///
/// ## Parameters
///
/// * `anchorKey` - Optional GlobalKey to anchor the modal below a specific
///   widget
/// * `topOffset` - Fallback offset when no anchor key is provided
/// * `context` - BuildContext for accessing MediaQuery (status bar height)
/// * `respectStatusBar` - Whether to enforce minimum distance from status bar
///
/// ## Example
///
/// ```dart
/// // Anchor to a button
/// final offset = calculateTopOffset(
///   anchorKey: buttonKey,
///   context: context,
///   respectStatusBar: true,
/// );
///
/// // Use explicit offset
/// final offset = calculateTopOffset(
///   topOffset: 100,
///   respectStatusBar: false,
/// );
/// ```
double calculateTopOffset({
  GlobalKey? anchorKey,
  double? topOffset,
  BuildContext? context,
  bool respectStatusBar = true,
}) {
  if (anchorKey != null) {
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox?.hasSize == true) {
      final position = renderBox!.localToGlobal(Offset.zero);
      final calculatedOffset = position.dy + renderBox.size.height;

      if (respectStatusBar && context != null && calculatedOffset < 50) {
        final statusBarHeight = MediaQuery.of(context).padding.top;
        return math.max(calculatedOffset, statusBarHeight);
      }

      return calculatedOffset;
    }
  }

  final calculatedOffset = topOffset ?? 0.0;

  if (respectStatusBar && context != null && calculatedOffset < 50) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return math.max(calculatedOffset, statusBarHeight);
  }

  return calculatedOffset;
}

/// Calculates modal height based on scroll control settings
///
/// For anchored sheets, height calculation follows showModalBottomSheet
/// behavior:
/// - **Default height**: Uses 9/16 of screen height
///   (like showModalBottomSheet) for both anchored and non-anchored sheets
///   when not scroll controlled
/// - **Scroll Controlled**: Returns full available height for sheets with
///   internal scrolling
///
/// ## Parameters
///
/// * `availableHeight` - Total screen height available for the modal
/// * `isScrollControlled` - Whether the modal should use full height
///   constraints
/// * `hasAnchorKey` - Whether this sheet is anchored to a specific widget
///   (currently not used in height calculation)
///
/// ## Example
///
/// ```dart
/// // Both anchored and non-anchored sheets use default height
/// final height = calculateModalHeight(
///   availableHeight: screenHeight,
///   isScrollControlled: false,
///   hasAnchorKey: true, // Returns ~56% of screen height
/// );
///
/// final height = calculateModalHeight(
///   availableHeight: screenHeight,
///   isScrollControlled: false,
///   hasAnchorKey: false, // Also returns ~56% of screen height
/// );
///
/// // Scroll controlled - uses full height
/// final height = calculateModalHeight(
///   availableHeight: screenHeight,
///   isScrollControlled: true,
///   hasAnchorKey: false, // Returns full screen height
/// );
/// ```
double calculateModalHeight({
  required double availableHeight,
  bool isScrollControlled = false,
  bool hasAnchorKey = false,
}) {
  // For scroll controlled sheets, provide full available height as the maximum
  // constraint, but let content size naturally (MainAxisSize.min support)
  if (isScrollControlled) {
    return availableHeight;
  }

  // For non-scroll controlled sheets, use default fraction
  // like showModalBottomSheet to provide consistent behavior
  return availableHeight * 9.0 / 16.0; // ~56% of screen height
}

/// Reusable drag handle widget for modal sheets
///
/// A Material Design compliant drag handle that provides visual feedback
/// and accessibility support for draggable modal sheets.
///
/// ## Features
///
/// * **Material Design** - Follows Material 3 specifications for drag handles
/// * **Hover Effects** - Visual feedback on mouse hover (desktop/web)
/// * **Accessibility** - Proper semantics and minimum touch target size
/// * **Customizable** - Supports custom colors and sizes
/// * **State Management** - Tracks hover and drag states for visual feedback
///
/// ## Default Specifications
///
/// * **Size**: 32x4 dp (Material Design standard)
/// * **Color**: onSurfaceVariant with 40% opacity
/// * **Shape**: Rounded rectangle (pill shape)
/// * **Minimum Touch Target**: 48x48 dp for accessibility
///
/// ## Accessibility
///
/// The handle includes:
/// - Semantic label using `modalBarrierDismissLabel`
/// - Minimum interactive area (48x48 dp)
/// - Tap semantics for screen readers
///
/// ## State Indicators
///
/// * `WidgetState.hovered` - When mouse is over the handle
/// * `WidgetState.dragged` - When being actively dragged
///
/// ## Parameters
///
/// * `onSemanticsTap` - Callback for accessibility tap events
/// * `onHover` - Callback for hover state changes
/// * `states` - Current widget states (hover, drag, etc.)
/// * `color` - Custom color override
/// * `size` - Custom size override
///
/// ## Example
///
/// ```dart
/// DragHandle(
///   color: Colors.blue,
///   size: Size(40, 6),
///   onHover: (hovering) => setState(() => isHovered = hovering),
///   onSemanticsTap: () => Navigator.pop(context),
/// )
/// ```
class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
    required this.onHover,
    this.onSemanticsTap,
    this.states = const <WidgetState>{},
    this.color,
    this.size,
  });

  final VoidCallback? onSemanticsTap;
  final ValueChanged<bool> onHover;
  final Set<WidgetState> states;
  final Color? color;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;
    final m3Defaults = _BottomSheetDefaultsM3(context);
    final handleSize =
        size ?? bottomSheetTheme.dragHandleSize ?? m3Defaults.dragHandleSize!;

    final resolvedColor =
        WidgetStateProperty.resolveAs<Color?>(color, states) ??
            WidgetStateProperty.resolveAs<Color?>(
              bottomSheetTheme.dragHandleColor,
              states,
            ) ??
            m3Defaults.dragHandleColor;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: Semantics(
        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        container: true,
        onTap: onSemanticsTap,
        child: SizedBox(
          width: math.max(handleSize.width, kMinInteractiveDimension),
          height: math.max(handleSize.height, kMinInteractiveDimension),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(handleSize.height / 2),
                color: resolvedColor,
              ),
              child: SizedBox.fromSize(size: handleSize),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal provider for modal dismissal events
///
/// An InheritedWidget that provides dismissal functionality to descendant
/// widgets without requiring explicit callbacks or global state management.
/// without requiring explicit context passing. This enables context-free
/// dismissal
/// patterns where any widget in the modal tree can trigger dismissal.
///
/// ## Usage Pattern
///
/// This is automatically wrapped around modal content when an `onDismiss`
/// callback is provided, enabling child widgets to dismiss the modal without
/// needing direct
/// access to navigation or controller objects.
///
/// ## Implementation Note
///
/// The `updateShouldNotify` returns false because the dismiss function
/// typically
/// doesn't change during the widget's lifetime, avoiding unnecessary rebuilds.
///
/// ## Parameters
///
/// * `onDismiss` - Function to call when dismissal is requested
/// * `child` - The widget tree that can access dismissal functionality
///
/// This is an internal implementation detail and not intended for direct use
/// outside of the anchored sheets system.
class ModalDismissProvider extends InheritedWidget {
  final void Function(dynamic) onDismiss;

  const ModalDismissProvider({
    super.key,
    required this.onDismiss,
    required super.child,
  });

  static ModalDismissProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ModalDismissProvider>();
  }

  @override
  bool updateShouldNotify(ModalDismissProvider oldWidget) => false;
}

/// Legacy alias for backward compatibility
typedef _ModalProvider = ModalDismissProvider;

// BEGIN GENERATED TOKEN PROPERTIES - BottomSheet

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// dart format off
class _BottomSheetDefaultsM3 extends BottomSheetThemeData {
  _BottomSheetDefaultsM3(this.context)
      : super(
          elevation: 1.0,
          modalElevation: 1.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          constraints: const BoxConstraints(maxWidth: 640),
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get dragHandleColor => _colors.onSurfaceVariant;

  @override
  Size? get dragHandleSize => const Size(32, 4);

  @override
  BoxConstraints? get constraints => const BoxConstraints(maxWidth: 640.0);
}
