import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTNativeView extends StatefulWidget {
  const RTNativeView({
    super.key,
    this.isReload = true,
    this.timeReload = 30,
    this.timeOut = 30,
    required this.adUnitId,
    this.type = RTNativeType.medium,
    this.controller,
    this.keyReload,
    this.isActive = true,
    this.style,
  });

  final bool isReload;
  final int timeReload;
  final int timeOut;
  final String adUnitId;
  final RTNativeType type;
  final RTNativeController? controller;
  final String? keyReload;
  final RTNativeStyle? style;

  // cho remote ads
  final bool isActive;

  @override
  State<RTNativeView> createState() => _RTNativeViewState();
}

class _RTNativeViewState extends State<RTNativeView> {
  NativeAd? _nativeAd;
  bool isLoading = true;
  bool isInit = true;
  Timer? timer;
  UniqueKey key = UniqueKey();
  bool isInternet = true;

  bool canRequestAds = false;

  @override
  void initState() {
    if (widget.isActive == false) {
      return;
    }

    _checkUMP();
    super.initState();
  }

  void _checkUMP() async {
    // Check internet
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.none)) {
      isInternet = false;
    }

    setState(() {});
    if (isInternet == false) return;

    canRequestAds = await RTAppManagement.instance.canRequestAds();
    if (canRequestAds) {
      _checkPreload();
    } else {
      isLoading = false; // ko hien ad nay vi ko xin dc consent
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    timer?.cancel();

    widget.controller?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive == false) {
      return const SizedBox();
    }

    return FocusDetector(
      onFocusGained: () {
        // tôi muốn chỉ bắt sự kiện chuyển màn hình và thoát app vào lại
        // để load lại ads

        if (widget.isReload && isInit == false && canRequestAds && RTAppManagement.instance.isLastNavigator == true) {
          key = UniqueKey();
          _loadAds(true);
        } else {
          isInit = false;
        }
      },
      onFocusLost: () {
        timer?.cancel();
      },
      child: isInternet == false || canRequestAds == false
          ? const SizedBox()
          : (isLoading == false && _nativeAd == null)
              ? const SizedBox()
              : (_nativeAd != null && !isLoading)
                  ? SizedBox(
                      height: widget.type.height == 0 ? MediaQuery.of(context).size.height : widget.type.height.toDouble(),
                      child: AdWidget(
                        key: key,
                        ad: _nativeAd!,
                      ),
                    )
                  : RTNativeLoading(height: widget.type.height == 0 ? MediaQuery.of(context).size.height : widget.type.height.toDouble()),
    );
  }

  _loadAds(isNext) {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAd ??= NativeAd(
      adUnitId: widget.adUnitId,
      request: AdRequest(
        nonPersonalizedAds: true,
        httpTimeoutMillis: widget.timeOut * 1000,
      ),
      factoryId: widget.type.factoryId,
      customOptions: (widget.style ?? RTAppManagement.instance.rtNativeStyle).toMap(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          RTLog.d('$NativeAd loaded.');
          // _nativeAd = ad as NativeAd;
          isLoading = false;
          setState(() {});
          _setupTimer();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          RTLog.d('$NativeAd failed to load: $error');
          isLoading = false;
          _nativeAd?.dispose();
          _nativeAd = null;
          setState(() {});

          if (isNext) {
            _setupTimer();
          }
        },
      ),
    );

    isLoading = true;
    setState(() {});
    _nativeAd!.load();
  }

  reLoad() {
    isLoading = true;
    setState(() {});
    RTLog.d("Reload ads NativeAd");
    _loadAds(true);
  }

  _setupTimer() {
    // timer?.cancel();
    // timer = Timer.periodic(Duration(seconds: widget.timeReload), (timer) {
    //   if (mounted && widget.isReload) {
    //     reLoad();
    //   }
    // });
  }

  _checkPreload() {
    if (RTAppManagement.instance.cacheNativeAd.containsKey(widget.keyReload ?? "default")) {
      final pair = RTAppManagement.instance.cacheNativeAd[widget.keyReload ?? "default"];
      if (pair != null && pair.first == RTNativePreLoadStatus.loaded) {
        _nativeAd = pair.second;
        RTAppManagement.instance.clearLoadNativeAd(widget.keyReload ?? "default");
        isLoading = false;
        setState(() {});
        _setupTimer();
      } else if (pair != null && pair.first == RTNativePreLoadStatus.loading) {
        isLoading = true;
        setState(() {});
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
          if (RTAppManagement.instance.cacheNativeAd.containsKey(widget.keyReload ?? "default")) {
            final pair = RTAppManagement.instance.cacheNativeAd[widget.keyReload ?? "default"];
            if (pair != null && pair.first == RTNativePreLoadStatus.loaded) {
              _nativeAd = pair.second;
              isLoading = false;
              RTAppManagement.instance.clearLoadNativeAd(widget.keyReload ?? "default");
              setState(() {});
              _setupTimer();
              timer.cancel();
            } else if (pair != null && pair.first == RTNativePreLoadStatus.failed) {
              isLoading = false;
              setState(() {});
              timer.cancel();
            }
          } else {
            isLoading = false;
            setState(() {});
            timer.cancel();
          }
        });
      }
    } else {
      if (mounted) {
        _loadAds(false);
      }
    }
  }
}
