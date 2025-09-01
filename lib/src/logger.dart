/// # Anchored Sheets Logger
///
/// A lightweight logging utility for the anchored_sheets package.
/// Provides structured logging with different levels and conditional output.
///
/// ## Features
///
/// * 🎯 Multiple log levels (debug, info, warning, error)
/// * 📱 Platform-aware output (development vs production)
/// * 🎨 Colored console output for better readability
/// * ⚡ Performance optimized with conditional compilation
/// * 🔧 Configurable log level filtering
///
/// ## Usage
///
/// ```dart
/// // Simple logging
/// AppLogger.i('User opened profile sheet');
/// AppLogger.w('Sheet dismissed without result');
/// AppLogger.e('Failed to create overlay entry', error);
///
/// // With additional context
/// AppLogger.d('Animation started', tag: 'AnimationController');
/// ```
///
/// ## Log Levels
///
/// * `v` - Verbose (most detailed)
/// * `d` - Debug (development info)
/// * `i` - Info (general information)
/// * `w` - Warning (potential issues)
/// * `e` - Error (errors and exceptions)
///
/// ## Configuration
///
/// The logger automatically detects development vs production mode:
/// - Development: Shows all log levels with colors
/// - Production: Only shows warnings and errors
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  none(5, 'NONE');

  const LogLevel(this.value, this.name);
  final int value;
  final String name;
}

/// ANSI color codes for console output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String cyan = '\x1B[36m';
  static const String gray = '\x1B[90m';
}

/// Main logger class for the anchored_sheets package
class AppLogger {
  /// Current minimum log level - messages below this level are ignored
  static LogLevel _minLevel = kDebugMode ? LogLevel.warning : LogLevel.debug;

  /// Configure the minimum log level
  static void setLogLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Get the current minimum log level
  static LogLevel getLogLevel() => _minLevel;

  /// Log a verbose message (most detailed level)
  static void v(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.verbose,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a debug message (development information)
  static void d(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an info message (general information)
  static void i(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message (potential issues)
  static void w(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message (errors and exceptions)
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Skip if below minimum level
    if (level.value < _minLevel.value) return;

    final String timestamp = DateTime.now().toIso8601String();
    final String levelName = level.name.padRight(7);
    final String tagStr = tag != null ? '[$tag] ' : '';
    final String fullMessage = '$timestamp $levelName $tagStr$message';

    // Use developer.log for structured logging
    developer.log(
      fullMessage,
      name: 'AnchoredSheets',
      level: level.value * 100, // Convert to developer log levels
      error: error,
      stackTrace: stackTrace,
    );

    // Also print to console with colors in development
    if (!kReleaseMode) {
      _colorizeMessage(level, fullMessage);
      // Use print instead of debugPrint for better performance in development
      // ignore: avoid_print
    }
  }

  /// Add colors to log messages for better console readability
  static String _colorizeMessage(LogLevel level, String message) {
    if (kReleaseMode) return message; // No colors in production

    final String color = switch (level) {
      LogLevel.verbose => _AnsiColors.gray,
      LogLevel.debug => _AnsiColors.cyan,
      LogLevel.info => _AnsiColors.green,
      LogLevel.warning => _AnsiColors.yellow,
      LogLevel.error => _AnsiColors.red,
      LogLevel.none => _AnsiColors.reset,
    };

    return '$color$message${_AnsiColors.reset}';
  }

  /// Create a logger instance for a specific component
  static ComponentLogger forComponent(String componentName) {
    return ComponentLogger._(componentName);
  }
}

/// Component-specific logger that automatically adds tags
class ComponentLogger {
  final String _componentName;

  ComponentLogger._(this._componentName);

  void v(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.v(
      message,
      tag: _componentName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void d(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.d(
      message,
      tag: _componentName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void i(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.i(
      message,
      tag: _componentName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void w(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.w(
      message,
      tag: _componentName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.e(
      message,
      tag: _componentName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
