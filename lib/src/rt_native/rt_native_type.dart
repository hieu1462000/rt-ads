enum RTNativeType {
  small,
  medium,
  big,
  huge;

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
    }
  }
}

enum RTNativePreLoadStatus {
  none,
  loading,
  loaded,
  failed,
}
