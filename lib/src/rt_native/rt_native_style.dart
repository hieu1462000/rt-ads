import 'package:flutter/material.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

/// Represents the style configuration for a native component in the RTAds library.
class RTNativeStyle {
  final Color primaryColor;
  final Color backgroundColor;
  final Color strokeColor;

  /// Constructs a new instance of [RTNativeStyle] with the specified colors.
  const RTNativeStyle({
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeColor,
  });

  /// Creates a new [RTNativeStyle] instance with the specified color values, replacing any existing values.
  ///
  /// If a color value is not provided, the corresponding color value from the original [RTNativeStyle] instance is used.
  RTNativeStyle copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? strokeColor,
  }) {
    return RTNativeStyle(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      strokeColor: strokeColor ?? this.strokeColor,
    );
  }

  /// Merges the properties of another [RTNativeStyle] instance into this instance.
  ///
  /// If the other instance is null, this instance is returned unchanged.
  RTNativeStyle merge(RTNativeStyle? other) {
    if (other == null) return this;
    return copyWith(
      primaryColor: other.primaryColor,
      backgroundColor: other.backgroundColor,
      strokeColor: other.strokeColor,
    );
  }

  /// Creates a new [RTNativeStyle] instance from a map of properties.
  ///
  /// The map should contain the following keys: 'primaryColor', 'backgroundColor', and 'strokeColor'.
  /// If a key is missing or the value is null, a default color value is used.
  factory RTNativeStyle.fromMap(Map<String, dynamic> map) {
    return RTNativeStyle(
      primaryColor: map['primaryColor'] ?? Colors.blue,
      backgroundColor: map['backgroundColor'] ?? Colors.white,
      strokeColor: map['strokeColor'] ?? Colors.grey,
    );
  }

  /// Converts the [RTNativeStyle] instance to a map of properties.
  ///
  /// The map contains the following keys: 'primaryColor', 'backgroundColor', and 'strokeColor'.
  /// The color values are represented as hexadecimal strings.
  Map<String, Object> toMap() {
    RTLog.d('primaryColor: #${primaryColor.value.toRadixString(16).padLeft(8, '0')}');
    return {
      'primaryColor': "#${primaryColor.value.toRadixString(16).padLeft(8, '0')}",
      'backgroundColor': "#${backgroundColor.value.toRadixString(16).padLeft(8, '0')}",
      'strokeColor': "#${strokeColor.value.toRadixString(16).padLeft(8, '0')}",
    };
  }
}

/// Default RTNativeStyle used in the application.
const RTNativeStyle rtNativeStyleDefault = RTNativeStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  strokeColor: Colors.grey,
);
