import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_banner/rt_banner_loading.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

/// A widget that displays a banner ad.
///
/// The [RTBannerView] widget is used to display a banner ad in your app. It supports various customization options such as ad unit ID, automatic ad reload, timeout duration, reload on navigation, and more.
///
/// To use [RTBannerView], simply provide the required parameters such as [adUnitId], [isReloadPerTime], [timeReloadInSeconds], [timeOutInseconds], and [isReloadNavigate]. You can also provide optional parameters such as [controller], [onAdLoadFinished], [onAdLoaded], [onAdFailedToLoad], [onAdOpened], [onAdClosed], [onAdWillDismissScreen], [onAdImpression], [onPaidEvent], and [onAdClicked].
///
/// Example usage:
///
/// ```dart
/// RTBannerView(
///   adUnitId: 'your_ad_unit_id',
///   isReloadPerTime: true,
///   timeReloadInSeconds: 30,
///   timeOutInseconds: 10,
///   isReloadNavigate: true,
///   onAdLoaded: (ad) {
///     print('Ad loaded: $ad');
///   },
///   onAdFailedToLoad: (ad, error) {
///     print('Failed to load ad: $error');
///   },
/// )
/// ```
class RTBannerView extends StatefulWidget {
  const RTBannerView({
    super.key,
    required this.adUnitId,
    required this.isReloadPerTime,
    this.timeReloadInSeconds = 30,
    required this.timeOutInseconds,
    required this.isReloadNavigate,
    this.controller,
    this.onAdLoadFinished,
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

  final RTBannerAdController? controller;

  //Call after ads loaded or not (ex. load ad inter after ad banner load finished)
  final VoidCallback? onAdLoadFinished;

  // cho remote ads
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
  State<RTBannerView> createState() => _RTBannerViewState();
}

class _RTBannerViewState extends State<RTBannerView> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isTimeOut = false;
  Timer? timer;
  bool _isInitFunctionFinished = false;
  UniqueKey key = UniqueKey();
  bool _isInit = false;
  bool canRequestAds = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RTBannerView oldWidget) {
    if (widget.isActive == false) {
      return;
    }
    if (_bannerAd == null) {
      _checkUMP();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (widget.isActive == false) {
      return;
    }
    if (_isInit == false) {
      _checkUMP();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  //check UMP to show ads or not
  void _checkUMP() async {
    canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (canRequestAds) {
      if (widget.controller != null) {
        if (!widget.controller!.isPreloadDone) {
          if (mounted) {
            _loadBannerAd();
          }
        }
        widget.controller!.addListener(() {
          // Reload ads
          RTLog.d('RELOAD NAVIGATE banner');
          if (widget.controller!.isReload) {
            if (RTAppManagement.instance.reloadBannerPeriod) {
              if (mounted) {
                reLoad();
              }
            }
          }

          // Preload ads
          if (widget.controller!.isPreloadDone) {
            _bannerAd = widget.controller!.bannerAd;
            widget.controller?.setPreLoadDone(false);
            _isBannerAdReady = true;
            if (widget.isReloadPerTime && RTAppManagement.instance.reloadBannerPeriod) {
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

  //load ad
  void _loadBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      return;
    }
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: AdRequest(httpTimeoutMillis: widget.timeOutInseconds * 1000),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          RTLog.d('Banner loaded');
          debugPrint('Mediation $ad loaded: ${ad.responseInfo?.mediationAdapterClassName}');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdReady = true;
          });
          if (widget.isReloadPerTime && RTAppManagement.instance.reloadBannerPeriod) {
            _setupTimer();
          }
          if (widget.onAdLoadFinished != null && _isInitFunctionFinished == false) {
            _isInitFunctionFinished = true;
            widget.onAdLoadFinished!();
          }
          widget.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, err) {
          RTLog.e('Failed to load a banner ad: ${err.message}');
          setState(() {
            _isBannerAdReady = false;
            _isTimeOut = true;
          });
          ad.dispose();
          if (widget.onAdLoadFinished != null && _isInitFunctionFinished == false) {
            _isInitFunctionFinished = true;
            widget.onAdLoadFinished!();
          }
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
          RTAppManagement.instance.logPaidAdImpressionToMeta(valueMicros, currencyCode);
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
              RTLog.d("vo visibility");
              if (widget.isReloadNavigate && !_isTimeOut) {
                reLoad();
              }
            },
            onVisibilityLost: () {
              timer?.cancel();
            },
            onFocusLost: () {
              timer?.cancel();
            },
            onForegroundGained: () {
              if (!_isTimeOut) {
                reLoad();
              }
            },
            onForegroundLost: () {
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
                              width: MediaQuery.of(context).size.width,
                              height: 60,
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

  //reload
  reLoad() {
    RTLog.d("Banner reload");
    key = UniqueKey();

    if (mounted) {
      _isBannerAdReady = false;
      setState(() {});
    }
    _isTimeOut = false;

    _bannerAd?.dispose();
    _loadBannerAd();
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
    timer?.cancel();
    _bannerAd?.dispose();

    super.dispose();
  }
}

/// A controller for managing a banner ad in the RTBannerView.
///
/// The [RTBannerAdController] is responsible for preloading and reloading a banner ad,
/// as well as keeping track of the ad's loading status and unit ID.
class RTBannerAdController extends ChangeNotifier {
  RTBannerAdController({required String adUnitId}) : _adUnitId = adUnitId;

  late final String _adUnitId;
  bool _isReload = false;
  bool _isLoadingPreload = false;
  bool _isPreloadDone = false;
  BannerAd? _bannerAd;

  //call this function to preload ads before showing
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
          _bannerAd = ad as BannerAd;
          _isPreloadDone = true;
        },
        onAdFailedToLoad: (ad, err) {
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

  //call this function to reload ads
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

  //set preload done
  setPreLoadDone(bool value) {
    _isPreloadDone = value;
  }
}
