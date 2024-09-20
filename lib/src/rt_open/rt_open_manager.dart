import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTOpenManager {
  static final RTOpenManager _instance = RTOpenManager._internal();

  factory RTOpenManager() {
    return _instance;
  }

  RTOpenManager._internal();

  late String adUnitId;
  AppOpenAd? _appOpenAd;

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  init(String adUnitId) {
    this.adUnitId = adUnitId;
    loadAd();
  }

  /// Load an AppOpenAd.
  void loadAd() {
    RTLog.d('id resume $adUnitId');
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          RTLog.d('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          RTLog.e('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    if (RTAppManagement.instance.isDisableByClick) {
      RTLog.e('Tried to show ad while app is disabled by click.');
      return;
    }

    if (RTAppManagement.instance.isEnableResume == false) {
      RTLog.e('Tried to show ad while app resume is enabled.');
      return;
    }

    if (!isAdAvailable) {
      RTLog.e('Tried to show ad before available.');
      loadAd();
      return;
    }

    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      RTLog.e('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        RTLog.d('$ad onAdShowedFullScreenContent');
        RTAppManagement.instance.disableResume();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        RTLog.e('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        RTLog.d('$ad onAdDismissedFullScreenContent');
        RTAppManagement.instance.enableResume();
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}

class RTOpenView extends StatefulWidget {
  const RTOpenView({
    super.key,
    required this.child,
    required this.adId,
    this.isActive = true,
  });

  final Widget child;
  final String adId;
  final bool isActive;

  @override
  State<RTOpenView> createState() => _RTOpenViewState();
}

class _RTOpenViewState extends State<RTOpenView> {
  @override
  void initState() {
    if (widget.isActive == false) return;
    final rtOpenManager = RTOpenManager()..init(widget.adId);
    final RTAppLifecycleReactor app = RTAppLifecycleReactor(rtOpenManager: rtOpenManager);
    app.listenToAppStateChanges();
    super.initState();
  }

  void _checkUMP() async {
    var canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (canRequestAds) {
      final rtOpenManager = RTOpenManager()..init(widget.adId);
      final RTAppLifecycleReactor app = RTAppLifecycleReactor(rtOpenManager: rtOpenManager);
      app.listenToAppStateChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        RTAppManagement.instance.isDisableByClick = false;
      },
      child: widget.child,
    );
  }
}
