enum RTNativeType {
  small,
  medium,
  big,
  huge,
  full;

  int get height {
    switch (this) {
      case RTNativeType.small:
        return 62;
      case RTNativeType.medium:
        return 160;
      case RTNativeType.big:
        return 250;
      case RTNativeType.huge:
        return 300;
      case RTNativeType.full:
        return 0;
    }
  }

  String get factoryId {
    switch (this) {
      case RTNativeType.small:
        return 'RTNativeSmall';
      case RTNativeType.medium:
        return 'RTNativeMedium';
      case RTNativeType.big:
        return 'RTNativeBig';
      case RTNativeType.huge:
        return 'RTNativeHuge';
      case RTNativeType.full:
        return 'RTNativeFull';
    }
  }
}

enum RTNativePreLoadStatus {
  none,
  loading,
  loaded,
  failed,
}
