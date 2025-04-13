import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_app_management.dart';
import 'package:rt_ads_plugin/src/rt_inter/rt_inter_loading.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

/// Manages the loading and showing of interstitial ads.
///
/// The [RTInterManager] class provides methods to load and show interstitial ads.
/// It also handles callbacks for various ad events such as ad loaded, ad failed to load,
/// ad dismissed, ad failed to show, ad showed, ad clicked, ad impression, and ad will dismiss.
/// The class also includes a method to close the loading dialog.
class RTInterManager {
  static final RTInterManager instance = RTInterManager._internal();
  factory RTInterManager() => instance;
  RTInterManager._internal();

  InterstitialAd? _interstitialAd;

  /// Loads an interstitial ad.
  ///
  /// This method loads an interstitial ad with the specified [adUnitId] and displays it when it's loaded.
  /// The [context] parameter is required to show the ad.
  /// The [onAdLoaded] callback is called when the ad is successfully loaded.
  /// The [onAdFailedToLoad] callback is called when the ad fails to load.
  /// The [isActive] parameter determines whether the ad should be loaded and shown.
  Future<void> loadInterstitialAd({
    required BuildContext context,
    required String adUnitId,
    Function(InterstitialAd ad)? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
    bool isActive = true,
  }) async {
    // Check if the ad is active
    if (isActive == false) {
      return;
    }

    // Check if ads can be requested
    var canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (!canRequestAds) {
      return;
    }

    // Load the interstitial ad
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('Mediation $ad loaded: ${ad.responseInfo?.mediationAdapterClassName}');
          RTLog.d('Inter ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          if (onAdLoaded != null) onAdLoaded(ad);
          _interstitialAd?.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            RTAppManagement.instance.logPaidAdImpressionToMeta(valueMicros, currencyCode);
          };
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

  /// Shows an interstitial ad.
  ///
  /// This method displays an interstitial ad with the provided parameters.
  /// It takes a [BuildContext] as a required parameter to show the ad in the correct context.
  /// The [onAdDismissedFullScreenContent] callback is called when the ad is dismissed.
  /// The [onAdFailedToShowFullScreenContent] callback is called when the ad fails to show.
  /// The [onAdShowedFullScreenContent] callback is called when the ad is fully shown.
  /// The [onAdClicked] callback is called when the ad is clicked.
  /// The [onAdImpression] callback is called when the ad is being displayed.
  /// The [onAdWillDismissFullScreenContent] callback is called when the ad is about to be dismissed.
  /// The [loadingIconColor] parameter sets the color of the loading icon.
  /// The [loadingText] parameter sets the text to be displayed during the loading process.
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

  /// Loads and shows an interstitial ad.
  ///
  /// The [adUnitId] parameter specifies the ID of the ad unit to load.
  /// The [onAdLoaded] callback is called when the ad is loaded successfully.
  /// The [onAdDismissedFullScreenContent] callback is called when the ad is dismissed after being shown in full screen.
  /// The [onAdFailedToShowFullScreenContent] callback is called when the ad fails to show in full screen.
  /// The [onAdShowedFullScreenContent] callback is called when the ad is shown in full screen.
  /// The [onAdFailedToLoad] callback is called when the ad fails to load.
  /// The [onAdClicked] callback is called when the ad is clicked.
  /// The [onAdImpression] callback is called when the ad is displayed on the screen.
  /// The [onAdWillDismissFullScreenContent] callback is called when the ad is about to be dismissed after being shown in full screen.
  /// The [context] parameter specifies the build context.
  /// The [loadingIconColor] parameter specifies the color of the loading icon.
  /// The [loadingText] parameter specifies the text to display while loading the ad.
  /// The [isActive] parameter specifies whether the ad is active or not.
  ///
  /// Throws an exception if the [adUnitId] is null.
  /// Throws an exception if the [context] is null.
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
          debugPrint('Mediation $ad loaded: ${ad.responseInfo?.mediationAdapterClassName}');
          RTLog.d('Inter ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          if (onAdLoaded != null) onAdLoaded(ad);
          _interstitialAd?.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            RTAppManagement.instance.logPaidAdImpressionToMeta(valueMicros, currencyCode);
          };
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

  //close loading dialog
  _backLoadingDialog(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.of(context).pop();
    }
  }
}
