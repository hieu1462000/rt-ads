import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_app_management.dart';
import 'package:rt_ads_plugin/src/rt_inter/rt_inter_loading.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTInterManager {
  static final RTInterManager instance = RTInterManager._internal();
  factory RTInterManager() => instance;
  RTInterManager._internal();

  InterstitialAd? _interstitialAd;

  Future<void> loadInterstitialAd({
    required BuildContext context,
    required String adUnitId,
    Function(InterstitialAd ad)? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
    bool isActive = true,
  }) async {
    if (isActive == false) {
      return;
    }
    var canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (!canRequestAds) {
      return;
    }

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          RTLog.d('Inter ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          if (onAdLoaded != null) onAdLoaded(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          RTLog.e('Inter ad failed to load: ${error.message}');
          _backLoadingDialog(context);
          onAdFailedToLoad?.call(error);
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showInterstitialAd({
    required BuildContext context,
    Function(InterstitialAd ad)? onAdDismissedFullScreenContent,
    Function(InterstitialAd ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(InterstitialAd ad)? onAdShowedFullScreenContent,
    Function(InterstitialAd ad)? onAdClicked,
    Function(InterstitialAd ad)? onAdImpression,
    Function(InterstitialAd ad)? onAdWillDismissFullScreenContent,
    Color? loadingIconColor,
    String? loadingText,
  }) async {
    if (_interstitialAd == null) {
      RTLog.e('Warning: attempt to show interstitial before loaded.');
      return;
    }
    // show loading
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: LoadingAdsInter(
          loadingIconColor: loadingIconColor,
          loadingText: loadingText,
        ),
      ),
    );
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _backLoadingDialog(context);
        onAdShowedFullScreenContent?.call(ad);
        RTLog.d('InterstitialAd showed');
        RTAppManagement.instance.disableResume();
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onAdDismissedFullScreenContent?.call(ad);
        RTLog.d('InterstitialAd dismissed');
        RTAppManagement.instance.enableResume();
        RTLog.d('enable resume ne');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onAdFailedToShowFullScreenContent?.call(ad, error);
        RTLog.e('$ad onAdFailedToShowFullScreenContent: $error');
        _backLoadingDialog(context);
        RTAppManagement.instance.enableResume();
        RTLog.d('enable resume ne');
        ad.dispose();
      },
      onAdClicked: (ad) {
        onAdClicked?.call(ad);
        RTLog.d('InterstitialAd clicked');
      },
      onAdImpression: (ad) {
        onAdImpression?.call(ad);
        RTLog.d('InterstitialAd impression');
      },
      onAdWillDismissFullScreenContent: (ad) {
        onAdWillDismissFullScreenContent?.call(ad);
        RTLog.d('InterstitialAd will dismiss');
      },
    );
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadAndShowInterstitialAd({
    required String adUnitId,
    Function(InterstitialAd ad)? onAdLoaded,
    Function(InterstitialAd ad)? onAdDismissedFullScreenContent,
    Function(InterstitialAd ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(InterstitialAd ad)? onAdShowedFullScreenContent,
    Function()? onAdFailedToLoad,
    Function(InterstitialAd ad)? onAdClicked,
    Function(InterstitialAd ad)? onAdImpression,
    Function(InterstitialAd ad)? onAdWillDismissFullScreenContent,
    required BuildContext context,
    Color? loadingIconColor,
    String? loadingText,
    bool isActive = true,
  }) async {
    if (isActive == false) {
      onAdFailedToLoad?.call();
      return;
    }
    var canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (!canRequestAds) {
      onAdFailedToLoad?.call();
      return;
    }
    RTAppManagement.instance.disableResume();
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: LoadingAdsInter(
          loadingIconColor: loadingIconColor,
          loadingText: loadingText,
        ),
      ),
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(httpTimeoutMillis: 10000),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          RTLog.d('Inter ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          if (onAdLoaded != null) onAdLoaded(ad);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              _backLoadingDialog(context);
              onAdShowedFullScreenContent?.call(
                  ad); //chạy luôn dòng này ở đây thì nó sẽ ko bị nháy lúc tắt ad inter vì khi ad được show lên thì vẫn sẽ chạy app ở dưới (ví dụ: chuyển màn)
              RTLog.d('InterstitialAd showed');
              RTAppManagement.instance.disableResume();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              onAdDismissedFullScreenContent?.call(ad);
              RTLog.d('InterstitialAd dismissed');
              RTAppManagement.instance.enableResume();
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              RTLog.e('$ad onAdFailedToShowFullScreenContent: $error');
              _backLoadingDialog(context);
              onAdFailedToShowFullScreenContent?.call(ad, error);
              RTAppManagement.instance.enableResume();
              ad.dispose();
            },
            onAdClicked: (ad) {
              RTLog.d('InterstitialAd clicked');
              onAdClicked?.call(ad);
            },
            onAdImpression: (ad) {
              RTLog.d('InterstitialAd impression');
              onAdImpression?.call(ad);
            },
            onAdWillDismissFullScreenContent: (ad) {
              RTLog.d('InterstitialAd will dismiss');
              onAdWillDismissFullScreenContent?.call(ad);
            },
          );
          _interstitialAd!.show();
          _interstitialAd = null;
        },
        onAdFailedToLoad: (LoadAdError error) {
          RTLog.e('Inter ad failed to load: $error.');
          _backLoadingDialog(context);
          onAdFailedToLoad?.call();
          _interstitialAd = null;
          RTAppManagement.instance.enableResume();
        },
      ),
    );
  }

  _backLoadingDialog(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent != true) {
      RTLog.d('Tat loading inter');
      Navigator.of(context).pop();
    }
  }
}
