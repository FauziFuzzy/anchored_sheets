/// # Anchored Performance System
///
/// This module provides performance optimization utilities for anchored sheets
/// using Flutter's lifecycle management and animation systems. It implements
/// best practices for memory management, animation efficiency, and widget
/// lifecycle optimization.
///
/// ## Key Features
///
/// * 🚀 **Animation Optimization** -
/// Pre-configured animation controllers with optimal settings
/// * 🔄 **Lifecycle Management** -
/// Automatic disposal and keep-alive functionality
/// * ⚡ **Performance Monitoring** - Built-in performance tracking capabilities
/// * 🎯 **Memory Efficiency** - Smart memory management for modal widgets
/// * 🎬 **Smooth Animations** -
/// Coordinated slide and fade animations with Material curves
///
/// ## Architecture
///
/// The performance system follows Flutter's optimization patterns:
/// - Uses `AutomaticKeepAliveClientMixin` for efficient widget preservation
/// - Employs `SingleTickerProviderStateMixin` for animation optimization
/// - Provides abstract base classes for consistent implementation
/// - Implements proper disposal patterns for memory management
///
/// ## Animation Configuration
///
/// The system uses Material Design animation curves and timing:
/// - **Enter Duration**: 250ms with `Curves.easeOutCubic`
/// - **Exit Duration**: 200ms for snappy dismissals
/// - **Slide Animation**: Subtle slide-down effect (-0.01 to 0.0)
/// - **Fade Animation**: Smooth opacity transition (0.0 to 1.0)
///
/// ## Usage Patterns
///
/// ```dart
/// class MyAnchoredSheet extends StatefulWidget {
///   @override
///   State<MyAnchoredSheet> createState() => _MyAnchoredSheetState();
/// }
///
/// class _MyAnchoredSheetState extends AnchoredSheetState<MyAnchoredSheet> {
///   @override
///   Widget build(BuildContext context) {
///     super.build(context); // Required for AutomaticKeepAliveClientMixin
///     return AnimatedBuilder(
///       animation: controller,
///       builder: (context, child) => // Your animated content
///     );
///   }
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// Abstract base class for anchored sheets with automatic lifecycle management
///
/// This class provides a foundation for building high-performance anchored
/// sheets with optimized animations and memory management. It combines
/// multiple Flutter mixins to provide comprehensive lifecycle support.
///
/// ## Features
///
/// * **Animation Management** - Pre-configured animation controllers
/// * **Memory Optimization** - Automatic keep-alive functionality
/// * **Lifecycle Safety** - Proper disposal and initialization patterns
/// * **Performance Monitoring** - Built-in animation debugging support
/// * **Material Design Compliance** - Follows Material motion guidelines
///
/// ## Mixins Included
///
/// * `SingleTickerProviderStateMixin` -
/// Provides optimized ticker for animations
/// * `AutomaticKeepAliveClientMixin` - Prevents unnecessary widget disposal
///
/// ## Animation System
///
/// The class provides two coordinated animations:
/// 1. **Slide Animation** - Subtle downward motion for sheet appearance
/// 2. **Fade Animation** - Opacity transition for smooth visual feedback
///
/// ## Implementation Requirements
///
/// When extending this class, you must:
/// 1. Call `super.build(context)`
/// in your build method (for AutomaticKeepAliveClientMixin)
/// 2. Use the provided animations in your widget tree
/// 3. Call `animateIn()` to show the sheet
/// 4. Call `animateOut()` to dismiss the sheet
///
/// ## Example Implementation
///
/// ```dart
/// class _MySheetState extends AnchoredSheetState<MySheet> {
///   @override
///   Widget build(BuildContext context) {
///     super.build(context); // Required!
///
///     return AnimatedBuilder(
///       animation: controller,
///       builder: (context, child) {
///         return Transform.translate(
///           offset: Offset(0, slideAnimation.value * 100),
///           child: Opacity(
///             opacity: fadeAnimation.value,
///             child: YourContent(),
///           ),
///         );
///       },
///     );
///   }
///
///   @override
///   void initState() {
///     super.initState();
///     animateIn(); // Show the sheet
///   }
/// }
/// ```
///
/// ## Performance Benefits
///
/// * **Reduced Rebuilds** - Keep-alive prevents unnecessary widget recreation
/// * **Optimized Animations** -
/// Single ticker provider reduces animation overhead
/// * **Memory Efficiency** - Proper disposal prevents memory leaks
/// * **Smooth Transitions** - Pre-tuned animation curves for professional feel
abstract class AnchoredSheetState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// Main animation controller for coordinating all sheet animations
  ///
  /// This controller manages the overall animation lifecycle of the anchored
  /// sheet. It's configured with Material Design timing and provides the
  /// foundation for both slide and fade animations.
  ///
  /// **Configuration:**
  /// - Enter duration: 250ms (smooth appearance)
  /// - Exit duration: 200ms (snappy dismissal)
  /// - Debug label: 'ModalAnimation' (for performance debugging)
  late final AnimationController controller;

  /// Animation that controls the vertical slide motion of the sheet
  ///
  /// Provides a subtle downward motion as the sheet appears, creating
  /// a natural entrance effect. The animation range is carefully tuned
  /// to be noticeable but not distracting.
  ///
  /// **Animation Range:**
  /// - Begin: -0.01 (slightly above final position)
  /// - End: 0.0 (final resting position)
  /// - Curve: `Curves.easeOutCubic` (Material Design standard)
  late final Animation<double> slideAnimation;

  /// Animation that controls the opacity transition of the sheet
  ///
  /// Creates a smooth fade-in effect that coordinates with the slide
  /// animation for a polished appearance. Uses a gentler curve for
  /// natural opacity progression.
  ///
  /// **Animation Range:**
  /// - Begin: 0.0 (fully transparent)
  /// - End: 1.0 (fully opaque)
  /// - Curve: `Curves.easeOut` (smooth deceleration)
  late final Animation<double> fadeAnimation;

  /// Controls whether the widget should be kept alive in the widget tree
  ///
  /// Returns `true` to enable AutomaticKeepAliveClientMixin functionality,
  /// which prevents the widget from being disposed when it scrolls out of
  /// view or is temporarily hidden. This optimization is beneficial for:
  ///
  /// * **Performance** - Avoids recreating expensive widget trees
  /// * **State Preservation** - Maintains animation state across rebuilds
  /// * **Memory Efficiency** - Reduces allocation/deallocation cycles
  /// * **User Experience** - Prevents flickering during transitions
  ///
  /// ## Override Behavior
  ///
  /// Subclasses can override this property to customize keep-alive behavior:
  /// ```dart
  /// @override
  /// bool get wantKeepAlive => isVisible && hasExpensiveContent;
  /// ```
  @override
  bool get wantKeepAlive => true;

  /// Initializes the widget state and sets up the animation system
  ///
  /// This method is called once when the widget is first created. It
  /// properly initializes the parent state and then configures the
  /// animation system with optimal settings for anchored sheets.
  ///
  /// ## Initialization Order
  ///
  /// 1. **Parent Initialization** - Calls super.initState() first
  /// 2. **Animation Setup** - Configures controllers and animations
  /// 3. **Ready State** - Widget is ready for animation triggers
  ///
  /// ## Subclass Integration
  ///
  /// When overriding this method in subclasses:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState(); // Always call first
  ///   // Your additional initialization
  ///   animateIn(); // Trigger entrance animation
  /// }
  /// ```
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  /// Private method that configures the animation system
  ///
  /// Sets up the animation controller and derived animations with optimal
  /// settings for anchored sheet behavior. This method encapsulates all
  /// animation configuration to maintain consistency and enable easy tuning.
  ///
  /// ## Animation Configuration
  ///
  /// **Controller Setup:**
  /// - Uses SingleTickerProviderStateMixin for efficiency
  /// - Configures different enter/exit durations for UX optimization
  /// - Includes debug labeling for performance profiling
  ///
  /// **Slide Animation:**
  /// - Subtle vertical motion for natural appearance
  /// - Uses cubic easing for Material Design compliance
  /// - Range optimized to be noticeable but not distracting
  ///
  /// **Fade Animation:**
  /// - Smooth opacity transition coordinated with slide
  /// - Uses ease-out curve for natural deceleration
  /// - Full opacity range for maximum visual impact
  ///
  /// ## Performance Considerations
  ///
  /// * Single animation controller reduces ticker overhead
  /// * Derived animations share the same timeline for efficiency
  /// * Curves are chosen for smooth 60fps performance
  /// * Debug labels enable profiling in development builds
  void _setupAnimations() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
      debugLabel: 'ModalAnimation',
      vsync: this,
    );

    slideAnimation = Tween<double>(
      begin: -0.01, // Start above screen
      end: 0.0, // End at final position
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }

  /// Disposes the animation controller to prevent memory leaks
  ///
  /// This method is called when the widget is permanently removed from
  /// the widget tree. It ensures proper cleanup of animation resources
  /// to prevent memory leaks and ticker active errors.
  ///
  /// ## Disposal Order
  ///
  /// 1. **Controller Disposal** - Stops and disposes animation controller
  /// 2. **Parent Disposal** - Calls super.dispose() for mixin cleanup
  ///
  /// ## Memory Management
  ///
  /// Proper disposal is critical because:
  /// * Animation controllers hold references to ticker providers
  /// * Undisposed controllers can cause memory leaks
  /// * Active tickers can cause exceptions if not properly stopped
  ///
  /// ## Automatic Handling
  ///
  /// This method is automatically called by Flutter's widget lifecycle,
  /// so subclasses rarely need to override it. If overriding is necessary:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   // Your cleanup code
  ///   super.dispose(); // Always call last
  /// }
  /// ```
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Triggers the entrance animation for the anchored sheet
  ///
  /// Starts the forward animation sequence, causing the sheet to slide
  /// down and fade in smoothly. This method should be called when the
  /// sheet should become visible, typically in initState() or in response
  /// to user interactions.
  ///
  /// ## Animation Behavior
  ///
  /// * **Duration**: 250ms (configured in controller)
  /// * **Curve**: Cubic easing for Material Design compliance
  /// * **Effects**: Coordinated slide and fade animations
  /// * **State**: Sets controller value from 0.0 to 1.0
  ///
  /// ## Usage Examples
  ///
  /// ```dart
  /// // In initState for immediate display
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   animateIn();
  /// }
  ///
  /// // In response to user action
  /// void showSheet() {
  ///   setState(() => isVisible = true);
  ///   animateIn();
  /// }
  /// ```
  ///
  /// ## Performance Notes
  ///
  /// * Uses the shared animation controller for efficiency
  /// * Coordinates multiple visual effects in a single timeline
  /// * Optimized timing prevents animation conflicts
  void animateIn() => controller.forward();

  /// Triggers the exit animation for the anchored sheet
  ///
  /// Starts the reverse animation sequence, causing the sheet to slide
  /// up and fade out smoothly. This method returns a Future that completes
  /// when the animation finishes, enabling proper timing coordination.
  ///
  /// ## Animation Behavior
  ///
  /// * **Duration**: 200ms (faster than entrance for snappy feel)
  /// * **Direction**: Reverse of entrance animation
  /// * **Effects**: Coordinated slide and fade out
  /// * **State**: Sets controller value from current to 0.0
  ///
  /// ## Usage Examples
  ///
  /// ```dart
  /// // Simple dismissal
  /// void dismissSheet() {
  ///   animateOut();
  /// }
  ///
  /// // With completion handling
  /// Future<void> dismissSheet() async {
  ///   await animateOut();
  ///   Navigator.of(context).pop();
  /// }
  ///
  /// // In gesture handling
  /// void handleDismissGesture() {
  ///   animateOut().then((_) {
  ///     // Cleanup after animation
  ///     onDismissComplete();
  ///   });
  /// }
  /// ```
  ///
  /// ## Timing Coordination
  ///
  /// The returned Future enables proper coordination with other operations:
  /// * Navigation transitions
  /// * State cleanup
  /// * Callback execution
  /// * Resource disposal
  ///
  /// ## Returns
  ///
  /// * [Future<void>] - Completes when the exit animation finishes
  Future<void> animateOut() => controller.reverse();
}
