import 'package:flutter/material.dart';

/// Abstract class for handling drag-to-dismiss functionality in modal components
///
/// Provides standardized drag gesture handling for modals that can be
/// dismissed by dragging in a specific direction.
///
/// Usage:
/// ```dart
/// class MyModalState extends State<MyModal> implements DragDismissMixin {
///   // Implement required getters
///   @override
///   AnimationController get dragAnimationController => _animationController;
///
///   @override
///   double get dragTargetHeight => _calculateHeight();
///
///   @override
///   VoidCallback get onDragDismiss => _handleDismiss;
/// }
/// ```
abstract class DragDismiss {
  // Drag constants that can be overridden
  double get minFlingVelocity => 700.0;
  double get closeThreshold => 0.5;

  Set<WidgetState> dragHandleStates = <WidgetState>{};

  // Abstract methods that must be implemented
  AnimationController get dragAnimationController;
  double get dragTargetHeight;
  VoidCallback get onDragDismiss;
  void setStateCallback(VoidCallback callback);

  // Optional callbacks that can be overridden
  void onDragStart(DragStartDetails details) {}
  void onDragEnd(DragEndDetails details, {required bool isClosing}) {}

  void handleDragStart(DragStartDetails details) {
    setStateCallback(() {
      dragHandleStates.add(WidgetState.dragged);
    });
    onDragStart(details);
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (dragAnimationController.status == AnimationStatus.reverse) return;

    // For top modals, positive delta moves up (dismiss)
    final dragHeight = dragTargetHeight > 0 ? dragTargetHeight : 200.0;
    dragAnimationController.value += details.primaryDelta! / dragHeight;
  }

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
}
