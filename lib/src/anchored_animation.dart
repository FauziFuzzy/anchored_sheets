import 'package:flutter/material.dart';

/// Abstract class for managing modal animations in slide-down components
///
/// Provides standardized animation setup and management for modals that
/// slide from top to bottom with fade effects.
///
/// Usage:
/// ```dart
/// class MyModalState extends State<MyModal>
///     with SingleTickerProviderStateMixin
///     implements ModalAnimationMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     setupAnimations();
///     showModal();
///   }
/// }
/// ```
abstract class ModalAnimation {
  // These should be implemented by the mixing class
  late AnimationController animationController;
  late Animation<double> slideAnimation;
  late Animation<double> fadeAnimation;

  // Animation constants that can be overridden
  Duration get enterDuration => const Duration(milliseconds: 250);
  Duration get exitDuration => const Duration(milliseconds: 200);
  Curve get animationCurve => Curves.easeOutCubic;

  bool get dismissUnderway =>
      animationController.status == AnimationStatus.reverse;

  /// Initialize animations - call this in initState()
  /// Requires the mixing class to have TickerProviderStateMixin
  void setupAnimations() {
    animationController = AnimationController(
      duration: enterDuration,
      reverseDuration: exitDuration,
      debugLabel: 'ModalAnimation',
      vsync: this as TickerProvider,
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

  /// Start the show animation
  void showModal() {
    animationController.forward();
  }

  /// Start the dismiss animation
  Future<void> dismissModal() async {
    await animationController.reverse();
  }

  /// Dispose animations - call this in dispose()
  void disposeAnimations() {
    animationController.dispose();
  }
}
