import 'package:flutter/material.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTNativeStyle {
  final Color primaryColor;
  final Color backgroundColor;
  final Color strokeColor;

  const RTNativeStyle({required this.primaryColor, required this.backgroundColor, required this.strokeColor});

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

  RTNativeStyle merge(RTNativeStyle? other) {
    if (other == null) return this;
    return copyWith(
      primaryColor: other.primaryColor,
      backgroundColor: other.backgroundColor,
      strokeColor: other.strokeColor,
    );
  }

  factory RTNativeStyle.fromMap(Map<String, dynamic> map) {
    return RTNativeStyle(
      primaryColor: map['primaryColor'] ?? Colors.blue,
      backgroundColor: map['backgroundColor'] ?? Colors.white,
      strokeColor: map['strokeColor'] ?? Colors.grey,
    );
  }

  Map<String, Object> toMap() {
    RTLog.d('primaryColor: #${primaryColor.value.toRadixString(16).padLeft(8, '0')}');
    return {
      'primaryColor': "#${primaryColor.value.toRadixString(16).padLeft(8, '0')}",
      'backgroundColor': "#${backgroundColor.value.toRadixString(16).padLeft(8, '0')}",
      'strokeColor': "#${strokeColor.value.toRadixString(16).padLeft(8, '0')}",
    };
  }
}

const RTNativeStyle rtNativeStyleDefault = RTNativeStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  strokeColor: Colors.grey,
);
