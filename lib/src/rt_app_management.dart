import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';
import 'package:rt_ads_plugin/src/rt_utils/pair.dart';
import 'package:rt_ads_plugin/src/rt_utils/rt_ad_color.dart';

class RTAppManagement {
  static final RTAppManagement instance = RTAppManagement._internal();
  factory RTAppManagement() => instance;
  RTAppManagement._internal();

  final Map<String, Pair<RTNativePreLoadStatus, NativeAd?>> _cacheNativeAd = {};
  Map<String, Pair<RTNativePreLoadStatus, NativeAd?>> get cacheNativeAd => _cacheNativeAd;
  final _facebookAppEvents = FacebookAppEvents();

  bool _isEnableResume = true;
  bool isDisableByClick = false;
  int _countResumeAdsInter = -1;
  bool _isReloadBannerPeriod = true;
  DateTime _lastTimeShowAdsInter = DateTime.now().subtract(const Duration(days: 1));

  RTNativeStyle _rtNativeStyle = rtNativeStyleDefault;
  RTAdColor _rtAdColor = rtAdColorDefault;
  DateTime? _lastNavigator;

  bool get isEnableResume => _isEnableResume;
  RTNativeStyle get rtNativeStyle => _rtNativeStyle;
  RTAdColor get rtAdColor => _rtAdColor;
  int get countResumeAdsInter => _countResumeAdsInter;
  bool get isActiveResumeAdsInter => DateTime.now().difference(_lastTimeShowAdsInter).inSeconds > _countResumeAdsInter;
  bool get reloadBannerPeriod => _isReloadBannerPeriod;

  void setLastNavigator() {
    _lastNavigator = DateTime.now();
  }

  bool get isLastNavigator => _lastNavigator != null && DateTime.now().difference(_lastNavigator!).inMilliseconds <= 1000;

  void setNativeStyle(RTNativeStyle style) {
    _rtNativeStyle = style;
  }

  void setAdColor({required Color primaryColor, required Color secondaryColor}) {
    _rtAdColor = RTAdColor(primaryColor: primaryColor, secondaryColor: secondaryColor);
  }

  void setIsReloadBannerPeriod(bool value) {
    RTLog.d("Reload banner per period via remote config: $value");
    _isReloadBannerPeriod = value;
  }

  void setCountResumeAdsInter(int count) {
    RTLog.d("SetCountResumeAdsInter: $count");
    _countResumeAdsInter = count;
  }

  void setLastTimeShowAdsInter() {
    RTLog.d("SetLastTimeShowAdsInter");
    _lastTimeShowAdsInter = DateTime.now();
  }

  void enableResume() {
    RTLog.d("EnableResume");
    _isEnableResume = true;
  }

  void disableResume() {
    RTLog.d("DisableResume");
    _isEnableResume = false;
  }

  void disableAdResumeByClickAction() {
    RTLog.d("disableAdResumeByClickAction");
    isDisableByClick = true;
  }

  Future<void> loadInterstitialAd({
    required BuildContext context,
    required String adUnitId,
    Function(InterstitialAd ad)? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
  }) async {
    await RTInterManager.instance.loadInterstitialAd(
      context: context,
      adUnitId: adUnitId,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  Future<void> showInterstitialAd({
    required BuildContext context,
    Function(InterstitialAd? ad)? onAdDismissedFullScreenContent,
    Function(InterstitialAd? ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(InterstitialAd? ad)? onAdShowedFullScreenContent,
    Function(InterstitialAd? ad)? onAdClicked,
    Function(InterstitialAd? ad)? onAdImpression,
    Function(InterstitialAd? ad)? onAdWillDismissFullScreenContent,
    Function()? onAdNotActiveByRemoteConfig,
  }) async {
    if (isActiveResumeAdsInter == false) {
      RTLog.d("Show Interstitial Ads: Not Active");
      onAdNotActiveByRemoteConfig?.call();
      return;
    }

    await RTInterManager.instance.showInterstitialAd(
      context: context,
      onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
      onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
      onAdWillDismissFullScreenContent: onAdWillDismissFullScreenContent,
      loadingIconColor: _rtAdColor.primaryColor,
    );
  }

  Future<void> loadAndShowInterstitialAd(
    BuildContext context, {
    required String adUnitId,
    Function(InterstitialAd? ad)? onAdLoaded,
    Function()? onAdFailedToLoad,
    Function(InterstitialAd? ad)? onAdDismissedFullScreenContent,
    Function(InterstitialAd? ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(InterstitialAd? ad)? onAdShowedFullScreenContent,
    Function(InterstitialAd? ad)? onAdClicked,
    Function(InterstitialAd? ad)? onAdImpression,
    Function(InterstitialAd? ad)? onAdWillDismissFullScreenContent,
    Function()? onAdNotActiveByRemoteConfig,
  }) async {
    if (isActiveResumeAdsInter == false) {
      RTLog.d("Show Interstitial Ads: Not Active");
      onAdNotActiveByRemoteConfig?.call();
      return;
    }

    setLastTimeShowAdsInter();
    RTInterManager.instance.loadAndShowInterstitialAd(
      adUnitId: adUnitId,
      context: context,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
      onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
      onAdWillDismissFullScreenContent: onAdWillDismissFullScreenContent,
      loadingIconColor: _rtAdColor.primaryColor,
    );
  }

  void loadRewardedAd({
    required String adUnitId,
    Function(RewardedAd ad)? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
  }) {
    RTRewardedManager.instance.load(
      adUnitId: adUnitId,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  void showRewardedAd({
    required BuildContext context,
    Function(RewardedAd ad)? onAdDismissedFullScreenContent,
    Function(RewardedAd ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(RewardedAd ad)? onAdShowedFullScreenContent,
    Function(RewardedAd ad)? onAdClicked,
    Function(RewardedAd ad)? onAdImpression,
    Function(RewardedAd ad)? onAdWillDismissFullScreenContent,
    Function(AdWithoutView ad, RewardItem reward)? onUserEarnedReward,
  }) {
    RTRewardedManager.instance.show(
      context: context,
      onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
      onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
      onAdWillDismissFullScreenContent: onAdWillDismissFullScreenContent,
      onUserEarnedReward: onUserEarnedReward,
      loadingIconColor: _rtAdColor.primaryColor,
    );
  }

  void loadAndShowRewardedAd({
    required String adUnitId,
    required BuildContext context,
    Function(RewardedAd ad)? onAdLoaded,
    Function(RewardedAd ad)? onAdDismissedFullScreenContent,
    Function(RewardedAd ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(AdWithoutView ad, RewardItem reward)? onUserEarnedReward,
    Function(LoadAdError error)? onAdFailedToLoad,
    Function(RewardedAd ad)? onAdShowedFullScreenContent,
    Function(RewardedAd ad)? onAdClicked,
    Function(RewardedAd ad)? onAdImpression,
    Function(RewardedAd ad)? onAdWillDismissFullScreenContent,
  }) {
    RTRewardedManager.instance.loadAndShow(
      adUnitId: adUnitId,
      context: context,
      onAdLoaded: onAdLoaded,
      onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
      onUserEarnedReward: onUserEarnedReward,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
      onAdWillDismissFullScreenContent: onAdWillDismissFullScreenContent,
      loadingIconColor: _rtAdColor.primaryColor,
    );
  }

  void preLoadNativeAd({
    required String adUnitId,
    String keySave = 'default',
    RTNativeType type = RTNativeType.medium,
    Function(NativeAd ad)? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
    RTNativeStyle? style,
  }) {
    RTLog.d('Preload Native "$keySave" Start');
    _cacheNativeAd[keySave] = Pair(RTNativePreLoadStatus.loading, null);
    NativeAd nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(nonPersonalizedAds: true),
      customOptions: (style ?? _rtNativeStyle).toMap(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          RTLog.d('Preload Native "$keySave" loaded.');
          _cacheNativeAd[keySave] = Pair(RTNativePreLoadStatus.loaded, ad as NativeAd);
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          RTLog.d('Preload "$keySave" failed to load: $error');
          _cacheNativeAd[keySave] = Pair(RTNativePreLoadStatus.failed, null);
          onAdFailedToLoad?.call(error);
        },
      ),
      factoryId: type.factoryId,
    );

    nativeAd.load();
  }

  void clearLoadNativeAd(String keySave) {
    RTLog.d('Clear Native "$keySave"');
    _cacheNativeAd.remove(keySave);
  }

  Future<bool> gatherConsent() async {
    return await RTConsentManager.instance.gatherConsent();
  }

  Future<bool> canRequestAds() async {
    final canRequestAds = await RTConsentManager.instance.canRequestAds();
    RTLog.d('RTADS CAN REQUEST AD: $canRequestAds');
    return canRequestAds;
  }

  void logPaidAdImpressionToMeta(double micros, String currencyCode) {
    try {
      double revenue = micros / 1000000;
      _facebookAppEvents.logPurchase(amount: revenue, currency: currencyCode);
    } catch (_) {}
  }
}
