import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';

class RtBannerScaffoldView extends StatelessWidget {
  const RtBannerScaffoldView({
    super.key,
    required this.child,
    this.isActive = true,
    this.controller,
    this.adUnitId,
    this.isReloadPerTime = true,
    this.timeOutInseconds = 10,
    this.isReloadNavigate = true,
    this.onAdClicked,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdImpression,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLoadFinished,
    this.onAdWillDismissScreen,
    this.onPaidEvent,
    this.timeReloadInSeconds = 10,
  });

  final Widget child;
  final bool isActive;
  final RTBannerAdController? controller;
  final String? adUnitId;
  final bool isReloadPerTime;
  final int timeOutInseconds;
  final bool isReloadNavigate;
  final void Function(Ad ad)? onAdClicked;
  final void Function(Ad ad)? onAdLoaded;
  final void Function(Ad ad, LoadAdError error)? onAdFailedToLoad;
  final void Function(Ad ad)? onAdImpression;
  final void Function(Ad ad)? onAdOpened;
  final void Function(Ad ad)? onAdClosed;
  final void Function()? onAdLoadFinished;
  final void Function(Ad ad)? onAdWillDismissScreen;
  final void Function(Ad ad, double, PrecisionType, String)? onPaidEvent;
  final int timeReloadInSeconds;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(child: child),
          if (isActive)
            RTBannerView(
              controller: controller,
              isActive: isActive,
              adUnitId: adUnitId ?? '',
              isReloadPerTime: isReloadPerTime,
              timeOutInseconds: timeOutInseconds,
              isReloadNavigate: isReloadNavigate,
              onAdClicked: onAdClicked,
              onAdLoaded: onAdLoaded,
              onAdFailedToLoad: onAdFailedToLoad,
              onAdImpression: onAdImpression,
              onAdOpened: onAdOpened,
              onAdClosed: onAdClosed,
              onAdLoadFinished: onAdLoadFinished,
              onAdWillDismissScreen: onAdWillDismissScreen,
              onPaidEvent: onPaidEvent,
              timeReloadInSeconds: timeReloadInSeconds,
            ),
        ],
      ),
    );
  }
}
