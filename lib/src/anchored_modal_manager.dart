import 'package:flutter/material.dart';

import 'src.dart';

/// Modal management utility integrated into anchored sheets
abstract class AnchoredSheetModalManager {
  /// Check if any anchored sheet is currently showing
  static bool get hasAnchoredSheet => getCurrentController<dynamic>() != null;

  /// Dismiss any existing anchored sheet and wait for animation
  static Future<void> dismissAnchoredSheetIfExists() async {
    if (hasAnchoredSheet) {
      await dismissAnchoredSheet();
      // Minimal wait for animation to start (one frame)
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  /// Dismiss other modal types (like bottom sheets) that might be showing
  static Future<void> dismissOtherModals(BuildContext context) async {
    // Try to dismiss any existing bottom sheet or other Navigator-based modals
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      // Minimal delay for smooth transition
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  /// Show modal bottom sheet after safely dismissing anchored sheet
  static Future<T?> showBottomSheetAfterAnchored<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool enableDrag = true,
  }) async {
    // First dismiss any anchored sheet
    await dismissAnchoredSheetIfExists();

    // Check if context is still mounted after async operation
    if (!context.mounted) return null;

    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      enableDrag: enableDrag,
    );
  }

  /// Show anchored sheet after safely dismissing bottom sheet
  static Future<T?> showAnchoredAfterOthers<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    GlobalKey? anchorKey,
    bool useSafeArea = true,
    bool enableDrag = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    BorderRadius? borderRadius,
    bool isScrollControlled = false,
  }) async {
    return anchoredSheet<T>(
      context: context,
      builder: builder,
      anchorKey: anchorKey,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      borderRadius: borderRadius,
      isScrollControlled: isScrollControlled,
      dismissOtherModals: true, // This will handle dismissing other modals
    );
  }
}
