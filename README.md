# RT Ads Plugin

A powerful Flutter plugin for seamless ad integration in mobile applications.

## Overview

RT Ads Plugin is a comprehensive Flutter plugin designed to simplify the integration and management of advertisements in Flutter applications. This plugin provides a unified interface for implementing various types of ads across both Android and iOS platforms.

## Features

### Ad Types Support
- Banner Ads
  - Standard Banner
  - Adaptive Banner
  - Smart Banner
- Interstitial Ads
  - Full-screen ads
  - Customizable display timing
- Rewarded Ads
  - Video Rewards
  - Playable Ads
- Native Ads
  - Custom native ad layouts
  - In-feed ads
- App Open Ads
  - Splash screen integration
  - Background to foreground transitions

### Platform Support
- Android (API level 19 and above)
- iOS (11.0 and above)

### Key Features
- Easy integration with Flutter applications
- Cross-platform compatibility
- Simple and intuitive API
- Built-in error handling and logging
- Ad event callbacks
- Ad loading optimization
- Test mode support
- GDPR compliance
- COPPA compliance
- Ad mediation support
- Analytics integration
- Custom ad targeting
- Ad refresh control
- Offline support
- Debug mode

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  rt_ads_plugin: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Configuration

### Android Setup

1. Add required permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

2. Add AdMob app ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
</application>
```

### iOS Setup

1. Add required permissions to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

2. Add required frameworks in Xcode:
   - GoogleMobileAds.framework
   - AppTrackingTransparency.framework

## Usage

### Initialize the Plugin

```dart
import 'package:rt_ads_plugin/rt_ads_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RtAdsPlugin.initialize(
    androidAppId: 'ca-app-pub-xxx~yyy',
    iosAppId: 'ca-app-pub-xxx~yyy',
    testMode: true, // Enable test mode for development
  );
  runApp(MyApp());
}
```

### Banner Ads

```dart
// Load banner ad
final bannerAd = await RtAdsPlugin.loadBannerAd(
  adUnitId: 'ca-app-pub-xxx/yyy',
  size: BannerSize.banner,
  position: BannerPosition.bottom,
);

// Show banner
bannerAd.show();

// Hide banner
bannerAd.hide();

// Dispose banner
bannerAd.dispose();
```

### Interstitial Ads

```dart
// Load interstitial ad
final interstitialAd = await RtAdsPlugin.loadInterstitialAd(
  adUnitId: 'ca-app-pub-xxx/yyy',
);

// Show interstitial
if (await interstitialAd.isLoaded()) {
  await interstitialAd.show();
}

// Add event listeners
interstitialAd.onAdLoaded(() {
  print('Interstitial ad loaded');
});

interstitialAd.onAdFailedToLoad((error) {
  print('Interstitial ad failed to load: $error');
});
```

### Rewarded Ads

```dart
// Load rewarded ad
final rewardedAd = await RtAdsPlugin.loadRewardedAd(
  adUnitId: 'ca-app-pub-xxx/yyy',
);

// Show rewarded ad
if (await rewardedAd.isLoaded()) {
  await rewardedAd.show();
}

// Add reward callback
rewardedAd.onUserEarnedReward((reward) {
  print('User earned reward: ${reward.amount} ${reward.type}');
});
```

### Native Ads

```dart
// Load native ad
final nativeAd = await RtAdsPlugin.loadNativeAd(
  adUnitId: 'ca-app-pub-xxx/yyy',
  style: NativeAdStyle.custom(),
);

// Display native ad
nativeAd.show();
```

## API Reference

### RtAdsPlugin

#### Initialization
- `initialize({required String androidAppId, required String iosAppId, bool testMode = false})`

#### Banner Ads
- `loadBannerAd({required String adUnitId, BannerSize size, BannerPosition position})`
- `BannerAd.show()`
- `BannerAd.hide()`
- `BannerAd.dispose()`

#### Interstitial Ads
- `loadInterstitialAd({required String adUnitId})`
- `InterstitialAd.show()`
- `InterstitialAd.isLoaded()`

#### Rewarded Ads
- `loadRewardedAd({required String adUnitId})`
- `RewardedAd.show()`
- `RewardedAd.isLoaded()`

#### Native Ads
- `loadNativeAd({required String adUnitId, NativeAdStyle style})`
- `NativeAd.show()`

## Advanced Features

### Ad Targeting
```dart
await RtAdsPlugin.setTargeting({
  'age': '18-24',
  'gender': 'male',
  'interests': ['sports', 'gaming'],
});
```

### Analytics
```dart
await RtAdsPlugin.enableAnalytics(true);
await RtAdsPlugin.logEvent('ad_impression', {
  'ad_type': 'banner',
  'ad_unit': 'home_screen',
});
```

### Mediation
```dart
await RtAdsPlugin.configureMediation({
  'facebook': 'your_facebook_app_id',
  'admob': 'your_admob_app_id',
});
```

## Best Practices

1. Always test ads using test ad unit IDs during development
2. Implement proper error handling for ad loading failures
3. Follow platform-specific guidelines for ad placement
4. Respect user privacy and implement proper consent management
5. Optimize ad loading to minimize impact on app performance
6. Implement proper ad refresh strategies
7. Monitor ad performance and user engagement

## Troubleshooting

Common issues and solutions:
- Ad not loading: Check internet connection and ad unit IDs
- Test ads not showing: Ensure test mode is enabled
- iOS build issues: Verify framework integration
- Android build issues: Check manifest permissions

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please:
1. Check our [documentation](https://docs.rtads.com)
2. Search existing [issues](https://github.com/your-repo/issues)
3. Create a new issue if needed

## Credits

- Google AdMob
- Facebook Audience Network
- Other ad networks supported through mediation

## Version History

- 1.0.0
  - Initial release
  - Basic ad types support
  - Cross-platform compatibility

- 1.1.0 (Upcoming)
  - Advanced targeting options
  - Improved error handling
  - Performance optimizations

