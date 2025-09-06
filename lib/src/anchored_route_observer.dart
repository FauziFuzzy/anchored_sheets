import 'package:flutter/material.dart';

import 'src.dart';

/// Global RouteObserver instance for anchored sheets
/// This observer will track route changes and
/// dismiss anchored sheets when needed
class AnchoredSheetRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final AnchoredSheetRouteObserver _instance =
      AnchoredSheetRouteObserver._internal();
  factory AnchoredSheetRouteObserver() => _instance;
  AnchoredSheetRouteObserver._internal();

  // Track active anchored sheet controllers
  final Set<ModalController<dynamic>> _activeControllers = {};

  void registerController(ModalController<dynamic> controller) {
    _activeControllers.add(controller);
    AppLogger.d(
      'Registered anchored sheet controller',
      tag: 'AnchoredSheetRouteObserver',
    );
  }

  void unregisterController(ModalController<dynamic> controller) {
    _activeControllers.remove(controller);
    AppLogger.d(
      'Unregistered anchored sheet controller',
      tag: 'AnchoredSheetRouteObserver',
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute);
    }
  }

  void _handleRouteChange(Route<dynamic> route) {
    // Use Flutter's built-in lifecycle detection
    // instead of manual type checking
    if (_isModalRoute(route) && _activeControllers.isNotEmpty) {
      AppLogger.d(
        'Detected modal route, dismissing anchored sheets',
        tag: 'AnchoredSheetRouteObserver',
      );

      // Dismiss all active anchored sheets
      final controllersToNotify =
          Set<ModalController<dynamic>>.from(_activeControllers);
      for (final controller in controllersToNotify) {
        if (!controller.isDisposed) {
          controller.dismiss();
        }
      }
    }
  }

  /// Uses Flutter's built-in route properties to detect modal behavior
  /// instead of manual string matching
  bool _isModalRoute(Route<dynamic> route) {
    if (route is ModalRoute) {
      if (route.barrierDismissible ||
          route.barrierColor != null ||
          route.barrierLabel != null) {
        return true;
      }

      if (route.semanticsDismissible) {
        return true;
      }

      if (!route.maintainState) {
        return true;
      }
    }

    if (route is DialogRoute ||
        route is ModalBottomSheetRoute ||
        route is RawDialogRoute ||
        route is PopupRoute) {
      return true;
    }

    return false;
  }
}
