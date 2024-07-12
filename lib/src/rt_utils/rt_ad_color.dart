import 'package:flutter/material.dart';

class RTAdColor {
  final Color primaryColor;
  final Color secondaryColor;

  const RTAdColor({
    required this.primaryColor,
    required this.secondaryColor,
  });

  RTAdColor copyWith({
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return RTAdColor(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }

  RTAdColor merge(RTAdColor? other) {
    if (other == null) return this;
    return copyWith(
      primaryColor: other.primaryColor,
      secondaryColor: other.secondaryColor,
    );
  }
}

const RTAdColor rtAdColorDefault = RTAdColor(
  primaryColor: Colors.blue,
  secondaryColor: Color(0xff67B6EB),
);
