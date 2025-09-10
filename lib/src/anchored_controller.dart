import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logger.dart';

/// Simple static tracking for duplicate prevention
///
/// This class provides minimal global state tracking
/// specifically for preventing
/// duplicate modal sheets when users click buttons multiple times quickly.
/// It maintains a clean architecture by only tracking what's necessary.
///
/// ## Features
///
/// * 🚫 **Duplicate prevention** - Prevents multiple sheets from same anchor
/// * 🔄 **Toggle behavior** - Second click on same button dismisses sheet
/// * 🧹 **Auto-cleanup** - Automatically clears when controller is disposed
/// * 📦 **Minimal footprint** - Only tracks active controller and anchor key
///
/// ## Usage
///
/// ```dart
/// // Check for duplicates before creating new sheet
/// if (ActiveSheetTracker.hasActive &&
///     anchorKey == ActiveSheetTracker.currentAnchorKey) {
///   ActiveSheetTracker.currentController?.dismiss();
///   return; // Don't create duplicate
/// }
///
/// // Track new active sheet
/// ActiveSheetTracker.setActive(controller, anchorKey);
/// ```
///
/// ## Automatic Cleanup
///
/// The tracker automatically clears itself when controllers are disposed,
/// preventing memory leaks and stale references.
class ActiveSheetTracker {
  /// Private storage for the currently active controller
  ///
  /// This is the controller for the most recently opened anchored sheet.
  /// It's cleared automatically when the controller is disposed.
  static ModalController<dynamic>? _currentController;

  /// Private storage for the anchor key of the active sheet
  ///
  /// This tracks which UI element (button, etc.) opened the current sheet.
  /// Used for duplicate prevention and toggle behavior.
  static GlobalKey? _currentAnchorKey;

  /// Stack of all active sheets for proper dismissal order
  ///
  /// This maintains a stack of all currently open anchored sheets,
  /// allowing proper LIFO (Last In, First Out) dismissal behavior.
  static final List<ModalController<dynamic>> _sheetStack = [];

  /// Stack of anchor keys corresponding to the sheet stack
  ///
  /// Parallel array to _sheetStack containing the anchor keys.
  static final List<GlobalKey?> _anchorKeyStack = [];

  /// Sets the currently active sheet controller and anchor key
  ///
  /// This should be called when a new anchored sheet is created to enable
  /// duplicate prevention and toggle behavior for subsequent clicks.
  ///
  /// Parameters:
  /// * [controller] - The modal controller for the new active sheet
  /// * [anchorKey] -
  /// Optional key identifying the UI element that opened the sheet
  ///
  /// ```dart
  /// final controller = ModalController<String>();
  /// ActiveSheetTracker.setActive(controller, myButtonKey);
  /// ```
  static void setActive(
    ModalController<dynamic> controller,
    GlobalKey? anchorKey,
  ) {
    _currentController = controller;
    _currentAnchorKey = anchorKey;

    // Add to stack for proper dismissal order
    _sheetStack.add(controller);
    _anchorKeyStack.add(anchorKey);
  }

  /// Gets the currently active modal controller
  ///
  /// Returns null if no sheet is currently active or if the controller
  /// has been disposed. Use [hasActive] to check before accessing.
  ///
  /// ```dart
  /// if (ActiveSheetTracker.hasActive) {
  ///   ActiveSheetTracker.currentController?.dismiss('result');
  /// }
  /// ```
  static ModalController<dynamic>? get currentController => _currentController;

  /// Gets the anchor key for the currently active sheet
  ///
  /// Returns null if no sheet is active or if no anchor key was provided
  /// when the sheet was created. Used for duplicate prevention logic.
  ///
  /// ```dart
  /// if (myButtonKey == ActiveSheetTracker.currentAnchorKey) {
  ///   // Same button clicked - toggle behavior
  /// }
  /// ```
  static GlobalKey? get currentAnchorKey => _currentAnchorKey;

  /// Clears all tracking state
  ///
  /// This is called automatically when controllers are disposed, but can
  /// also be called manually if needed. Generally not needed in normal usage.
  ///
  /// ```dart
  /// ActiveSheetTracker.clear(); // Manual cleanup
  /// ```
  static void clear() {
    _currentController = null;
    _currentAnchorKey = null;
    _sheetStack.clear();
    _anchorKeyStack.clear();
  }

  /// Removes a specific controller from the stack
  ///
  /// This is called when a sheet is dismissed to maintain stack integrity.
  static void removeFromStack(ModalController<dynamic> controller) {
    final index = _sheetStack.indexOf(controller);
    if (index != -1) {
      _sheetStack.removeAt(index);
      _anchorKeyStack.removeAt(index);

      // Update current references to the topmost sheet
      if (_sheetStack.isNotEmpty) {
        _currentController = _sheetStack.last;
        _currentAnchorKey = _anchorKeyStack.last;
      } else {
        _currentController = null;
        _currentAnchorKey = null;
      }
    }
  }

  /// Gets the topmost (most recently added) sheet controller
  ///
  /// Returns the controller that should be dismissed when user wants to
  /// close the "current" sheet. Uses LIFO (Last In, First Out) behavior.
  static ModalController<dynamic>? get topmostController {
    if (_sheetStack.isNotEmpty) {
      return _sheetStack.last;
    }
    return _currentController; // Fallback for compatibility
  }

  /// Checks if there is currently an active sheet
  ///
  /// Returns true if there is an active controller that hasn't been disposed.
  /// This is the recommended way to check before accessing the controller.
  ///
  /// ```dart
  /// if (ActiveSheetTracker.hasActive) {
  ///   // Safe to access currentController and currentAnchorKey
  ///   final controller = ActiveSheetTracker.currentController;
  /// }
  /// ```
  static bool get hasActive =>
      _currentController != null && !_currentController!.isDisposed;
}

/// Modal controller with proper lifecycle management and error handling
///
/// This controller follows Flutter best practices for resource management,
/// async operations, and state updates.
class ModalController<T> {
  final Completer<T?> _completer = Completer<T?>();
  bool _isDisposed = false;
  VoidCallback? _onStateChanged;
  Future<void> Function()? _onAnimatedDismiss;

  /// Future that completes when the modal is dismissed
  Future<T?> get future => _completer.future;

  /// Whether the modal has been completed/dismissed
  bool get isCompleted => _completer.isCompleted;

  /// Whether this controller has been disposed
  bool get isDisposed => _isDisposed;

  /// Sets the callback for state changes
  ///
  /// This should be called from initState and cleared in dispose
  /// to follow proper widget lifecycle patterns.
  void setStateCallback(VoidCallback? callback) {
    if (!_isDisposed) {
      _onStateChanged = callback;
    }
  }

  /// Sets the callback for animated dismissal
  ///
  /// This callback should handle the animation sequence before dismissal.
  /// It will be called by [dismissWithAnimation] to trigger the animation.
  void setAnimatedDismissCallback(Future<void> Function()? callback) {
    if (!_isDisposed) {
      _onAnimatedDismiss = callback;
    }
  }

  /// Dismisses the modal with animation
  ///
  /// If an animated dismiss callback is set, it will be called first
  /// to handle the animation, then the modal will be dismissed.
  Future<void> dismissWithAnimation([T? result]) async {
    if (_isDisposed || _completer.isCompleted) return;

    if (_onAnimatedDismiss != null) {
      try {
        await _onAnimatedDismiss!();
      } catch (e) {
        // If animation fails, still dismiss the modal
      }
    }
    
    dismiss(result);
  }

  /// Dismisses the modal with an optional result
  ///
  /// This method is safe to call multiple times and handles
  /// edge cases gracefully.
  void dismiss([T? result]) {
    if (_isDisposed || _completer.isCompleted) return;

    try {
      _completer.complete(result);

      // Schedule state update for next frame to ensure widget is still mounted
      if (_onStateChanged != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            _onStateChanged?.call();
          }
        });
      }
    } catch (error) {
      AppLogger.e(
        'Error dismissing modal',
        error: error,
        tag: 'ModalController',
      );
      // Still complete the completer to prevent hanging
      if (!_completer.isCompleted) {
        _completer.complete(result);
      }
    }
  }

  /// Disposes the controller and cleans up resources
  ///
  /// This method ensures proper cleanup and prevents memory leaks.
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    // Complete the completer if not already done
    if (!_completer.isCompleted) {
      _completer.complete(null);
    }

    // Clean up tracking and callbacks
    ActiveSheetTracker.removeFromStack(this);
    _onStateChanged = null;
  }
}
