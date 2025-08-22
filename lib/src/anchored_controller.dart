import 'dart:async';

import 'package:flutter/material.dart';

/// Utility functions for managing static modal controller references
///
/// Provides a standardized way to handle global modal state for
/// context-free dismissal functionality.

// Private variables for storing global modal state
dynamic _currentController;
dynamic _currentState;

/// Sets the current active controller
void setCurrentController(dynamic controller) {
  _currentController = controller;
}

/// Sets the current active state
void setCurrentState(dynamic state) {
  _currentState = state;
}

/// Gets the current active controller
T? getCurrentController<T>() {
  return _currentController as T?;
}

/// Gets the current active state
T? getCurrentState<T>() {
  return _currentState as T?;
}

/// Clears the controller reference
void clearController() {
  _currentController = null;
}

/// Clears the state reference
void clearState() {
  _currentState = null;
}

/// Clears all references
void clearAll() {
  _currentController = null;
  _currentState = null;
}

/// Generic modal controller for managing completion state
class GenericModalController<T> {
  final VoidCallback? onDismiss;
  final Completer<T?> _completer = Completer();

  GenericModalController({this.onDismiss});

  Future<T?> get future => _completer.future;

  void dismiss([T? result]) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
      onDismiss?.call();
    }
  }

  bool get isCompleted => _completer.isCompleted;
}
