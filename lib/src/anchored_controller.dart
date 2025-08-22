import 'dart:async';

import 'package:flutter/material.dart';

/// Utility functions for managing static modal controller references
///
/// Provides a standardized way to handle global modal state for
/// context-free dismissal functionality.

// Private variables for storing global modal state
dynamic _currentController;
dynamic _currentState;
GlobalKey? _currentAnchorKey;

/// Sets the current active controller
void setCurrentController(dynamic controller, [GlobalKey? anchorKey]) {
  _currentController = controller;
  _currentAnchorKey = anchorKey;
}

/// Sets the current active state
void setCurrentState(dynamic state) {
  _currentState = state;
}

/// Gets the current active controller
T? getCurrentController<T>() {
  if (_currentController is T) {
    return _currentController as T;
  }
  return null;
}

/// Gets the current anchor key
GlobalKey? getCurrentAnchorKey() {
  return _currentAnchorKey;
}

/// Gets the current active state
T? getCurrentState<T>() {
  if (_currentState is T) {
    return _currentState as T;
  }
  return null;
}

/// Clears the controller reference
void clearController() {
  _currentController = null;
  _currentAnchorKey = null;
}

/// Clears the state reference
void clearState() {
  _currentState = null;
}

/// Clears all references
void clearAll() {
  _currentController = null;
  _currentState = null;
  _currentAnchorKey = null;
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
