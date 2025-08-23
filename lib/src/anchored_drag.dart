/// # Anchored Drag System
///
/// This module provides drag-to-dismiss functionality for anchored sheets
/// using Flutter's gesture detection and animation systems. It implements
/// Material Design drag behavior with proper velocity handling and smooth
/// animations.
///
/// ## Key Features
///
/// * 🎯 **Gesture Recognition** - Pan gesture detection with velocity tracking
/// * ⚡ **Velocity-based Dismissal** -
/// Smart fling detection for quick dismissals
/// * 🎬 **Smooth Animations** - Coordinated transform and opacity animations
/// * 📏 **Threshold-based Logic** - Configurable drag distance thresholds
/// * 🔄 **Spring-back Animation** -
/// Returns to original position when not dismissed
///
/// ## Architecture
///
/// The drag system follows Flutter's gesture handling patterns:
/// - Uses `GestureDetector` for pan gesture recognition
/// - Employs `AnimationController` for smooth state transitions
/// - Implements threshold-based dismissal logic
/// - Provides real-time visual feedback during drag operations
///
/// ## Usage Patterns
///
/// ```dart
/// DraggableDismissible(
///   onDismiss: () => Navigator.pop(context),
///   minFlingVelocity: 800.0,
///   closeThreshold: 0.4,
///   child: MyModalContent(),
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// A draggable widget that can be dismissed through pan gestures
///
/// This widget wraps its child with drag-to-dismiss functionality, allowing
/// users to swipe the content to close modals or sheets. It implements
/// Material Design gesture behavior with configurable thresholds and
/// smooth animations.
///
/// ## Features
///
/// * **Pan Gesture Detection** - Responds to vertical pan gestures
/// * **Velocity Analysis** - Considers both drag distance and velocity
/// * **Visual Feedback** - Real-time opacity and position changes
/// * **Configurable Thresholds** - Customizable dismissal sensitivity
/// * **Smooth Animations** - Professional spring-back and dismiss animations
///
/// ## Gesture Behavior
///
/// The widget uses a dual-criteria dismissal system:
/// 1. **Velocity Threshold** - Quick flicks trigger immediate dismissal
/// 2. **Distance Threshold** - Slow drags require crossing a distance threshold
///
/// ## Animation Details
///
/// * **During Drag**: Real-time position and opacity updates
/// * **On Dismiss**: Forward animation to completion with callback
/// * **On Cancel**: Reverse animation back to original position
///
/// ## Example
///
/// ```dart
/// DraggableDismissible(
///   onDismiss: () {
///     Navigator.of(context).pop();
///   },
///   minFlingVelocity: 700.0,
///   closeThreshold: 0.5,
///   child: Container(
///     height: 200,
///     child: Text('Swipe me to dismiss!'),
///   ),
/// )
/// ```
///
/// ## Performance Considerations
///
/// * Uses `AnimatedBuilder` for efficient rebuilds
/// * Clamps animation values to prevent overflow
/// * Disposes animation controller properly in widget lifecycle
class DraggableDismissible extends StatefulWidget {
  /// The child widget that will be made draggable
  ///
  /// This widget will be wrapped with gesture detection and animation
  /// capabilities. It should be the main content that users will interact
  /// with through drag gestures.
  final Widget child;

  /// Callback function executed when the widget should be dismissed
  ///
  /// This function is called when either:
  /// - The drag velocity exceeds [minFlingVelocity]
  /// - The drag distance exceeds [closeThreshold]
  ///
  /// Typically used to close modals, sheets, or navigate back:
  /// ```dart
  /// onDismiss: () => Navigator.of(context).pop(),
  /// ```
  final VoidCallback? onDismiss;

  /// Minimum velocity required for fling-based dismissal (pixels per second)
  ///
  /// When a user quickly flicks the content, if the gesture velocity
  /// exceeds this threshold, the dismissal will be triggered immediately
  /// regardless of the drag distance.
  ///
  /// **Default**: 700.0 pixels per second
  /// **Material Design**: Recommended range 600-1000 for mobile devices
  final double minFlingVelocity;

  /// Threshold for distance-based dismissal (as a ratio of drag distance)
  ///
  /// This value represents what percentage of the reference distance
  /// (200 pixels) must be dragged to trigger dismissal for slow gestures.
  ///
  /// **Default**: 0.5 (50% of reference distance)
  /// **Range**: 0.0 to 1.0
  /// **Examples**:
  /// - 0.3 = Easy to dismiss (30% drag)
  /// - 0.7 = Hard to dismiss (70% drag)
  final double closeThreshold;

  /// Creates a draggable dismissible widget
  ///
  /// ## Parameters
  ///
  /// * [child] - Required. The widget to make draggable
  /// * [onDismiss] - Optional. Callback when dismissal should occur
  /// * [minFlingVelocity] - Velocity threshold for quick dismissals
  /// (default: 700.0)
  /// * [closeThreshold] - Distance threshold for slow dismissals (default: 0.5)
  ///
  /// ## Example
  ///
  /// ```dart
  /// DraggableDismissible(
  ///   onDismiss: () => Navigator.pop(context),
  ///   minFlingVelocity: 800.0,  // Slightly higher threshold
  ///   closeThreshold: 0.4,      // Easier to dismiss
  ///   child: MyContent(),
  /// )
  /// ```
  const DraggableDismissible({
    super.key,
    required this.child,
    this.onDismiss,
    this.minFlingVelocity = 700.0,
    this.closeThreshold = 0.5,
  });

  @override
  State<DraggableDismissible> createState() => _DraggableDismissibleState();
}

/// State class for [DraggableDismissible]
///
/// Manages the animation controller, drag state, and gesture handling
/// for the draggable dismissible widget. Implements proper Flutter
/// lifecycle management with [SingleTickerProviderStateMixin].
class _DraggableDismissibleState extends State<DraggableDismissible>
    with SingleTickerProviderStateMixin {
  /// Animation controller for smooth transitions and spring-back effects
  ///
  /// Controls the progress of both dismissal and return animations.
  /// Duration is optimized for responsive feel (200ms).
  late AnimationController _controller;

  /// Animation that drives the visual effects during drag operations
  ///
  /// Ranges from 0.0 (initial state) to 1.0 (fully dismissed).
  /// Used to calculate opacity and position transforms.
  late Animation<double> _animation;

  /// Current drag position in pixels from the initial position
  ///
  /// Positive values indicate downward drag, negative values indicate
  /// upward drag. This value is reset to 0.0 when drag is cancelled.
  double _dragPosition = 0.0;

  /// Initializes the animation controller and animation
  ///
  /// Sets up the animation system with a 200ms duration for responsive
  /// feel. The animation is configured to drive visual effects during
  /// drag operations and dismissal sequences.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = _controller.drive(Tween<double>(begin: 0.0, end: 1.0));
  }

  /// Disposes the animation controller to prevent memory leaks
  ///
  /// Essential for proper Flutter lifecycle management when using
  /// animation controllers with ticker providers.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles pan gesture updates during active dragging
  ///
  /// Updates the drag position and animation controller value in real-time
  /// as the user drags the widget. The animation value is calculated as
  /// a ratio of the absolute drag distance to a reference distance (200px).
  ///
  /// ## Behavior
  /// - Accumulates drag delta to track total displacement
  /// - Updates animation controller for immediate visual feedback
  /// - Clamps animation value between 0.0 and 1.0 to prevent overflow
  ///
  /// ## Parameters
  /// * [details] - Contains the primary delta (movement distance)
  /// for this frame
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta ?? 0.0;
      _controller.value = (_dragPosition.abs() / 200.0).clamp(0.0, 1.0);
    });
  }

  /// Handles pan gesture completion and determines dismissal outcome
  ///
  /// Analyzes the final gesture state to decide whether to dismiss the
  /// widget or return it to its original position. Uses both velocity
  /// and distance thresholds for intelligent dismissal logic.
  ///
  /// ## Dismissal Criteria
  /// The widget will be dismissed if either condition is met:
  /// 1. **Velocity Check**: Gesture velocity exceeds [minFlingVelocity]
  /// 2. **Distance Check**: Animation progress exceeds [closeThreshold]
  ///
  /// ## Animation Outcomes
  /// - **Dismiss**: Forward animation to completion, then trigger callback
  /// - **Cancel**: Reverse animation to original position, reset drag state
  ///
  /// ## Parameters
  /// * [details] - Contains velocity information for the completed gesture
  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss = velocity.abs() > widget.minFlingVelocity ||
        _controller.value > widget.closeThreshold;

    if (shouldDismiss) {
      _controller.forward().then((_) => widget.onDismiss?.call());
    } else {
      _controller.reverse();
      setState(() => _dragPosition = 0.0);
    }
  }

  /// Builds the draggable widget with gesture detection and animations
  ///
  /// Creates a gesture-responsive widget that combines:
  /// - Pan gesture detection for drag interaction
  /// - Real-time position transformation during drag
  /// - Opacity animation for visual feedback
  /// - Efficient rebuilding through [AnimatedBuilder]
  ///
  /// ## Widget Structure
  /// ```
  /// GestureDetector (pan detection)
  ///   └── AnimatedBuilder (efficient rebuilds)
  ///       └── Transform.translate (position changes)
  ///           └── Opacity (fade effect)
  ///               └── Child widget
  /// ```
  ///
  /// ## Animation Effects
  /// - **Position**: Follows drag position for immediate feedback
  /// - **Opacity**: Fades from 1.0 to 0.5 as animation progresses
  /// - **Smooth Transitions**: Both effects use the same animation curve
  ///
  /// ## Performance
  /// - Uses [AnimatedBuilder] to minimize rebuilds
  /// - Only rebuilds the visual effects, not the entire widget tree
  /// - Efficient gesture handling with minimal state updates
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _dragPosition),
          child: Opacity(
            opacity: 1.0 - (_animation.value * 0.5),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
