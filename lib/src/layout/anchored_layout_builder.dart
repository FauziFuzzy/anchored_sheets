import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Builds a positioned modal content with Material theming
///
/// Handles the common layout patterns for modal sheets including:
/// - Material design theming
/// - Safe area handling
/// - Drag handle support
/// - Constraints and clipping
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
  BoxConstraints? constraints,
  bool useSafeArea = false,
  bool showDragHandle = false,
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
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: kMinInteractiveDimension,
                ),
                child: child,
              ),
              DragHandle(
                onSemanticsTap: onDragHandleTap,
                onHover: onDragHandleHover,
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
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: content,
    );
  }

  if (constraints != null) {
    content = Align(
      alignment: Alignment.topCenter,
      heightFactor: 1.0,
      child: ConstrainedBox(constraints: constraints, child: content),
    );
  }

  return content;
}

/// Builds a click-through area above the modal
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

/// Builds the main positioned modal with animations
Widget buildPositionedModal({
  required double topOffset,
  required double height,
  required Widget child,
  required Animation<double> slideAnimation,
  required Animation<double> fadeAnimation,
  Function(dynamic)? onDismiss,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return Builder(
    builder: (context) {
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final shouldExtendToStatusBar = topOffset <= statusBarHeight;

      Widget content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height,
          // Don't set minHeight - let the child determine its natural height
        ),
        child: ClipRect(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: onDismiss != null
                ? _ModalProvider(onDismiss: onDismiss, child: child)
                : child,
          ),
        ),
      );

      // If sheet overlaps with status bar, extend background and respect safe area
      if (shouldExtendToStatusBar) {
        return Positioned(
          top: slideAnimation.value * height,
          left: 0,
          right: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: height + statusBarHeight,
              minWidth: MediaQuery.sizeOf(context).width,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status bar background that matches the sheet style
                Container(
                  height: statusBarHeight,
                  width: MediaQuery.sizeOf(context).width,
                  color:
                      backgroundColor ?? Theme.of(context).colorScheme.surface,
                ),
                // Content that respects the design
                SizedBox(
                  width: MediaQuery.sizeOf(context)
                      .width, // Ensure content takes full width
                  child: content,
                ),
              ],
            ),
          ),
        );
      } else {
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
double calculateTopOffset({
  GlobalKey? anchorKey,
  double? topOffset,
  BuildContext? context,
  bool respectStatusBar = true,
}) {
  double calculatedOffset = 0.0;

  if (anchorKey != null) {
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox?.hasSize == true) {
      final position = renderBox!.localToGlobal(Offset.zero);
      calculatedOffset = position.dy + renderBox.size.height;
    }
  } else {
    calculatedOffset = topOffset ?? 0.0;
  }

  // Add status bar height if needed and context is available
  if (respectStatusBar && context != null && calculatedOffset < 50) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    calculatedOffset = math.max(calculatedOffset, statusBarHeight);
  }

  return calculatedOffset;
}

/// Calculates modal height based on scroll control settings
double calculateModalHeight({
  required double availableHeight,
  required bool isScrollControlled,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
}) {
  return isScrollControlled
      ? availableHeight
      : availableHeight * scrollControlDisabledMaxHeightRatio;
}

/// Reusable drag handle widget
class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
    this.onSemanticsTap,
    this.onHover,
    this.states = const <WidgetState>{},
    this.color,
    this.size,
  });

  final VoidCallback? onSemanticsTap;
  final ValueChanged<bool>? onHover;
  final Set<WidgetState> states;
  final Color? color;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final handleSize = size ?? const Size(32, 4);

    return MouseRegion(
      onEnter: onHover != null ? (event) => onHover!(true) : null,
      onExit: onHover != null ? (event) => onHover!(false) : null,
      child: Semantics(
        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        container: true,
        onTap: onSemanticsTap,
        child: SizedBox(
          width: math.max(handleSize.width, kMinInteractiveDimension),
          height: math.max(handleSize.height, kMinInteractiveDimension),
          child: Center(
            child: Container(
              height: handleSize.height,
              width: handleSize.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(handleSize.height / 2),
                color: color ??
                    Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal provider for modal dismissal (kept for compatibility)
class _ModalProvider extends InheritedWidget {
  final Function(dynamic) onDismiss;

  const _ModalProvider({required this.onDismiss, required super.child});

  @override
  bool updateShouldNotify(_ModalProvider oldWidget) => false;
}
