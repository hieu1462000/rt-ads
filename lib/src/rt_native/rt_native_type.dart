/// Represents the types of RTNative ads.
enum RTNativeType {
  small,
  medium,
  big,
  huge,
  full,
  bigCustom1,
  bigCustom2,
  bigCustom3,
  bigCustom4;

  //height of the ad
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
      case RTNativeType.bigCustom1:
        return 250;
      case RTNativeType.bigCustom2:
        return 250;
      case RTNativeType.bigCustom3:
        return 250;
      case RTNativeType.bigCustom4:
        return 200;
    }
  }

  //id of the ad
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
      case RTNativeType.bigCustom1:
        return 'RTNativeBigCustom1';
      case RTNativeType.bigCustom2:
        return 'RTNativeBigCustom2';
      case RTNativeType.bigCustom3:
        return 'RTNativeBigCustom3';
      case RTNativeType.bigCustom4:
        return 'RTNativeBigCustom4';
    }
  }
}

/// Enum representing the pre-load status of a native ad in library.
enum RTNativePreLoadStatus {
  none,
  loading,
  loaded,
  failed,
}
