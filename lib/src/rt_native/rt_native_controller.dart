import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTNativeController extends ChangeNotifier {
  RTNativeController({required String adUnitId}) : _adUnitId = adUnitId;

  late final String _adUnitId;
  bool _isReload = false;
  bool _isLoadingPreload = false;
  bool _isPreloadDone = false;
  NativeAd? _nativeAd;

  void preLoadAd() {
    if (_nativeAd != null) _nativeAd?.dispose();
    _nativeAd?.dispose();

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(
        keywords: <String>['fitness', 'workout'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
        httpTimeoutMillis: 30000,
      ),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          RTLog.d('$NativeAd loaded.');
          _nativeAd = ad as NativeAd;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          RTLog.d('$NativeAd failed to load: $error');
        },
      ),
    );

    _isLoadingPreload = true;
    _nativeAd!.load().then((value) {
      _isLoadingPreload = false;
      _isPreloadDone = true;
      notifyListeners();
    });
  }

  void reloadAd() {
    _isReload = true;
    notifyListeners();
    _isReload = false;
  }

  bool get isReload => _isReload;

  get isPreloadDone => _isPreloadDone;

  get isLoadingPreload => _isLoadingPreload;

  get nativeAd => _nativeAd;

  get adUnitId => _adUnitId;

  setPreLoadDone(bool value) {
    _isPreloadDone = value;
  }
}
