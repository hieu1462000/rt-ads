import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';
import 'package:rt_ads_plugin/src/rt_rewarded/rt_rewarded_loading.dart';

class RTRewardedManager {
  RewardedAd? _rewardedAd;

  static final RTRewardedManager instance = RTRewardedManager._internal();
  factory RTRewardedManager() => instance;
  RTRewardedManager._internal();

  void load({
    required String adUnitId,
    Function(RewardedAd ad)? onAdLoaded,
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
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          RTLog.d('RewardedAd loaded.');
          _rewardedAd = ad;
          _rewardedAd!.setImmersiveMode(true);
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          RTLog.e('RewardedAd failed to load: $error');
          _rewardedAd = null;
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  void show({
    required BuildContext context,
    Function(RewardedAd ad)? onAdDismissedFullScreenContent,
    Function(RewardedAd ad, AdError error)? onAdFailedToShowFullScreenContent,
    Function(AdWithoutView ad, RewardItem reward)? onUserEarnedReward,
    Function(RewardedAd ad)? onAdShowedFullScreenContent,
    Function(RewardedAd ad)? onAdClicked,
    Function(RewardedAd ad)? onAdImpression,
    Function(RewardedAd ad)? onAdWillDismissFullScreenContent,
    Color? loadingIconColor,
    String? loadingText,
  }) {
    if (_rewardedAd == null) {
      RTLog.e('Warning: attempt to show rewarded before loaded.');
      return;
    }
    // show loading
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: LoadingAdsRewarded(
          loadingIconColor: loadingIconColor,
          loadingText: loadingText,
        ),
      ),
    );

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        RTLog.d('RewardedAd onAdShowedFullScreenContent');
        RTAppManagement.instance.disableResume();
        onAdShowedFullScreenContent?.call(ad);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        RTLog.d("RewardedAd onAdDismissedFullScreenContent");
        RTAppManagement.instance.enableResume();
        onAdDismissedFullScreenContent?.call(ad);

        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        RTLog.e('RewardedAd onAdFailedToShowFullScreenContent: $error');
        onAdFailedToShowFullScreenContent?.call(ad, error);
        ad.dispose();
      },
      onAdClicked: (ad) {
        RTLog.d('RewardedAd onAdClicked');
        onAdClicked?.call(ad);
      },
      onAdImpression: (ad) {
        RTLog.d('RewardedAd onAdImpression');
        onAdImpression?.call(ad);
      },
      onAdWillDismissFullScreenContent: (ad) {
        RTLog.d('RewardedAd onAdWillDismissFullScreenContent');
        onAdWillDismissFullScreenContent?.call(ad);
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        RTLog.d('RewardedAd onUserEarnedReward');
        onUserEarnedReward?.call(ad, reward);
      },
    );
  }

  void loadAndShow({
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
    bool isActive = true,
    Color? loadingIconColor,
    String? loadingText,
  }) async {
    if (isActive == false) {
      return;
    }
    var canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (!canRequestAds) {
      return;
    }
    // show loading
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: LoadingAdsRewarded(
          loadingIconColor: loadingIconColor,
          loadingText: loadingText,
        ),
      ),
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          RTLog.d('RewardedAd loaded.');
          _rewardedAd = ad;
          _rewardedAd!.setImmersiveMode(true);
          if (onAdLoaded != null) onAdLoaded(ad);
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd ad) {
              RTLog.d('RewardedAd onAdShowedFullScreenContent');
              onAdShowedFullScreenContent?.call(ad);
              RTAppManagement.instance.disableResume();
              _backLoadingDialog(context);
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              RTLog.d("RewardedAd onAdDismissedFullScreenContent");
              onAdDismissedFullScreenContent?.call(ad);
              RTAppManagement.instance.enableResume();
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              RTLog.e('RewardedAd onAdFailedToShowFullScreenContent: $error');
              onAdFailedToShowFullScreenContent?.call(ad, error);
              _backLoadingDialog(context);
              ad.dispose();
            },
            onAdClicked: (ad) {
              RTLog.d('RewardedAd onAdClicked');
              onAdClicked?.call(ad);
            },
            onAdImpression: (ad) {
              RTLog.d('RewardedAd onAdImpression');
              onAdImpression?.call(ad);
            },
            onAdWillDismissFullScreenContent: (ad) {
              RTLog.d('RewardedAd onAdWillDismissFullScreenContent');
              onAdWillDismissFullScreenContent?.call(ad);
            },
          );
          //close dialog
          _backLoadingDialog(context);
          _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            RTLog.d('RewardedAd onUserEarnedReward');
            onUserEarnedReward?.call(ad, reward);
          });
          _rewardedAd = null;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _backLoadingDialog(context);
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  _backLoadingDialog(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.of(context).pop();
    }
  }
}
