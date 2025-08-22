import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A specialized gesture detector for modal dragging
///
/// Provides a reusable gesture detector that can be configured
/// for different modal types (top, bottom, side, etc.)
class ModalGestureDetector extends StatelessWidget {
  const ModalGestureDetector({
    super.key,
    required this.child,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.enableVerticalDrag = false,
    this.enableHorizontalDrag = false,
  });

  final Widget child;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final bool enableVerticalDrag;
  final bool enableHorizontalDrag;

  @override
  Widget build(BuildContext context) {
    if (!enableVerticalDrag && !enableHorizontalDrag) {
      return child;
    }

    final gestures = <Type, GestureRecognizerFactory<GestureRecognizer>>{};

    if (enableVerticalDrag) {
      gestures[VerticalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(debugOwner: this),
            (instance) {
              instance
                ..onStart = onVerticalDragStart
                ..onUpdate = onVerticalDragUpdate
                ..onEnd = onVerticalDragEnd
                ..onlyAcceptDragOnThreshold = true;
            },
          );
    }

    if (enableHorizontalDrag) {
      gestures[HorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(debugOwner: this),
            (instance) {
              instance
                ..onStart = onHorizontalDragStart
                ..onUpdate = onHorizontalDragUpdate
                ..onEnd = onHorizontalDragEnd
                ..onlyAcceptDragOnThreshold = true;
            },
          );
    }

    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: gestures,
      child: child,
    );
  }
}

/// Creates a gesture detector for top modal (drag up to dismiss)
ModalGestureDetector forTopModal({
  required Widget child,
  GestureDragStartCallback? onDragStart,
  GestureDragUpdateCallback? onDragUpdate,
  GestureDragEndCallback? onDragEnd,
}) {
  return ModalGestureDetector(
    enableVerticalDrag: true,
    onVerticalDragStart: onDragStart,
    onVerticalDragUpdate: onDragUpdate,
    onVerticalDragEnd: onDragEnd,
    child: child,
  );
}

/// Creates a gesture detector for bottom modal (drag down to dismiss)
ModalGestureDetector forBottomModal({
  required Widget child,
  GestureDragStartCallback? onDragStart,
  GestureDragUpdateCallback? onDragUpdate,
  GestureDragEndCallback? onDragEnd,
}) {
  return ModalGestureDetector(
    enableVerticalDrag: true,
    onVerticalDragStart: onDragStart,
    onVerticalDragUpdate: onDragUpdate,
    onVerticalDragEnd: onDragEnd,
    child: child,
  );
}

/// Creates a gesture detector for side modal (drag left/right to dismiss)
ModalGestureDetector forSideModal({
  required Widget child,
  GestureDragStartCallback? onDragStart,
  GestureDragUpdateCallback? onDragUpdate,
  GestureDragEndCallback? onDragEnd,
}) {
  return ModalGestureDetector(
    enableHorizontalDrag: true,
    onHorizontalDragStart: onDragStart,
    onHorizontalDragUpdate: onDragUpdate,
    onHorizontalDragEnd: onDragEnd,
    child: child,
  );
}
