import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_banner/rt_banner_loading.dart';

/// A collapsible banner view that displays ads.
///
/// The [RTBannerCollapseView] widget is used to display banner ads that can be collapsed.
/// It provides options for automatically reloading ads, setting timeouts, and handling ad events.
/// The widget can be controlled using a [RTBannerCollapseAdController].
///
/// Example usage:
/// ```dart
/// RTBannerCollapseView(
///   adUnitId: 'your_ad_unit_id',
///   isReloadPerTime: true,
///   timeReloadInSeconds: 30,
///   timeOutInseconds: 10,
///   isReloadNavigate: true,
///   controller: yourController,
///   onAdLoaded: (ad) {
///     // Handle ad loaded event
///   },
///   onAdFailedToLoad: (ad, error) {
///     // Handle ad failed to load event
///   },
///   // Other ad event callbacks...
/// )
/// ```
class RTBannerCollapseView extends StatefulWidget {
  const RTBannerCollapseView({
    super.key,
    required this.adUnitId,
    required this.isReloadPerTime,
    this.timeReloadInSeconds = 30,
    required this.timeOutInseconds,
    required this.isReloadNavigate,
    this.controller,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdWillDismissScreen,
    this.onAdImpression,
    this.onPaidEvent,
    this.onAdClicked,
    this.isActive = true,
  });

  ///Ad Unit Id
  final String adUnitId;

  ///Automatically Reload Ads or Not
  final bool isReloadPerTime;

  ///Time in Seconds of Automatically Reload
  final int timeReloadInSeconds;

  ///Time-out load Ad
  final int timeOutInseconds;

  ///Reload when Navigate to Another Screen or Not
  final bool isReloadNavigate;

  ///controller for load and reload ads
  final RTBannerCollapseAdController? controller;

  final bool isActive;

  final Function(Ad)? onAdLoaded;
  final Function(Ad, LoadAdError)? onAdFailedToLoad;
  final Function(Ad)? onAdOpened;
  final Function(Ad)? onAdClosed;
  final Function(Ad)? onAdWillDismissScreen;
  final Function(Ad)? onAdImpression;
  final Function(Ad, double, PrecisionType, String)? onPaidEvent;
  final Function(Ad)? onAdClicked;

  @override
  State<RTBannerCollapseView> createState() => _RTBannerCollapseViewState();
}

class _RTBannerCollapseViewState extends State<RTBannerCollapseView> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false; //loading or not
  bool _isTimeOut = false; //ads or sizebox
  Timer? timer;
  UniqueKey key = UniqueKey();
  bool canRequestAds = false;

  @override
  void initState() {
    if (widget.isActive == false) {
      return;
    }
    _checkUMP();
    super.initState();
  }

  ///Check UMP to show ads or not
  void _checkUMP() async {
    canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (canRequestAds) {
      if (widget.controller != null) {
        if (!widget.controller!.isPreloadDone) {
          //preload fail
          if (mounted) {
            _loadBannerAd();
          }
        }
        widget.controller!.addListener(() {
          // Reload ads
          if (widget.controller!.isReload) {
            if (mounted) {
              reLoad();
            }
          }

          // Preload ads
          if (widget.controller!.isPreloadDone) {
            //preload successful
            _bannerAd = widget.controller!.bannerAd;
            widget.controller?.setPreLoadDone(false);
            _isBannerAdReady = true;
            if (widget.isReloadPerTime) {
              _setupTimer();
            }
          }
        });
      } else {
        if (mounted) {
          _loadBannerAd();
        }
      }
    } else {
      setState(() {
        _isTimeOut = true; //ko hien ad
      });
    }
  }

  ///Load Banner Ad
  void _loadBannerAd() async {
    double width = MediaQuery.sizeOf(context).width;
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: AdRequest(extras: {"collapsible": "bottom"}, httpTimeoutMillis: widget.timeOutInseconds * 1000),
      size: AdSize(width: width.toInt(), height: 60),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('ads banner collapse loaded');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdReady = true;
          });
          if (widget.isReloadPerTime) {
            _setupTimer();
          }
          widget.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, err) {
          log('Failed to load a banner ad collapse: ${err.message}');
          setState(() {
            _isBannerAdReady = false;
            _isTimeOut = true;
          });
          ad.dispose();
          widget.onAdFailedToLoad?.call(ad, err);
        },
        onAdClosed: (ad) {
          widget.onAdClosed?.call(ad);
        },
        onAdClicked: (ad) {
          widget.onAdClicked?.call(ad);
        },
        onAdImpression: (ad) {
          widget.onAdImpression?.call(ad);
        },
        onAdOpened: (ad) {
          widget.onAdOpened?.call(ad);
        },
        onAdWillDismissScreen: (ad) {
          widget.onAdWillDismissScreen?.call(ad);
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          widget.onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
        },
      ),
    );

    await _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isActive
        ? FocusDetector(
            onVisibilityGained: () {
              if (widget.isReloadNavigate && canRequestAds) {
                reLoad();
              }
            },
            onVisibilityLost: () {
              timer?.cancel();
            },
            onFocusLost: () {
              timer?.cancel();
            },
            child: !_isTimeOut
                ? Column(
                    children: [
                      Container(
                        color: Colors.black38,
                        height: 1,
                      ),
                      _isBannerAdReady
                          ? Container(
                              width: _bannerAd!.size.width.toDouble(),
                              height: _bannerAd!.size.height.toDouble(),
                              alignment: Alignment.bottomCenter,
                              child: AdWidget(key: key, ad: _bannerAd!),
                            )
                          : const RTBannerLoading(),
                      Container(
                        color: Colors.black38,
                        height: 1,
                      ),
                    ],
                  )
                : const SizedBox(),
          )
        : const SizedBox();
  }

  ///Reload Banner Ad
  reLoad() {
    key = UniqueKey();
    _isBannerAdReady = false;
    _isTimeOut = false;
    _bannerAd?.dispose();
    if (mounted) {
      _loadBannerAd();
    }
  }

  ///Timer for automatically reload
  _setupTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: widget.timeReloadInSeconds * 1000), (timer) {
      if (mounted && widget.isReloadPerTime) {
        reLoad();
      }
    });
  }

  @override
  void dispose() {
    //timer?.cancel();
    //_bannerAd?.dispose();
    super.dispose();
  }
}

/// Controller for managing the collapse banner ad.
///
/// This controller is responsible for preloading and reloading the collapse banner ad,
/// as well as keeping track of the ad's loading status.
class RTBannerCollapseAdController extends ChangeNotifier {
  RTBannerCollapseAdController({required String adUnitId}) : _adUnitId = adUnitId;

  late final String _adUnitId;
  bool _isReload = false;
  bool _isLoadingPreload = false;
  bool _isPreloadDone = false;
  BannerAd? _bannerAd;

  /// Preload a banner collapse ad.
  void preLoadAd() {
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

    Size size = view.physicalSize;
    double width = size.width;
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(httpTimeoutMillis: 30000),
      size: AdSize(width: width.toInt(), height: 60),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('ads banner collapse preloaded');
          _bannerAd = ad as BannerAd;
          _isPreloadDone = true;
        },
        onAdFailedToLoad: (ad, err) {
          log('Failed to preload a banner collapse ad: ${err.message}');
          _isPreloadDone = false;
          ad.dispose();
        },
      ),
    );

    _isLoadingPreload = true;
    _bannerAd!.load().then((value) {
      _isLoadingPreload = false;
      notifyListeners();
    });
  }

  /// Reload the banner collapse ad.
  void reloadAd() {
    _isReload = true;
    notifyListeners();
    _isReload = false;
  }

  get isReload => _isReload;

  get isPreloadDone => _isPreloadDone;

  get isLoadingPreload => _isLoadingPreload;

  get bannerAd => _bannerAd;

  get adUnitId => _adUnitId;

  /// Set the preload status of the banner collapse ad.
  setPreLoadDone(bool value) {
    _isPreloadDone = value;
  }
}
