import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await RTConsentManager().gatherConsent();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _platformVersion = 'Unknown';
  // final _rtAdsPlugin = RtAdsPlugin();

  @override
  void initState() {
    final rtOpenManager = RTOpenManager()..init('ca-app-pub-3940256099942544/9257395921');
    final RTAppLifecycleReactor app = RTAppLifecycleReactor(rtOpenManager: rtOpenManager);

    app.listenToAppStateChanges();
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion = await _rtAdsPlugin.getPlatformVersion() ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Builder(builder: (context) => const MyWidget()),
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  RTNativeController? controller;

  @override
  void initState() {
    controller = RTNativeController(adUnitId: "ca-app-pub-3940256099942544/2247696110");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          CupertinoButton(
              child: const Text("dslkfajslfdkjkl"),
              onPressed: () {
                RTAppManagement.instance.loadAndShowRewardedAd(
                  adUnitId: "ca-app-pub-3940256099942544/5224354917",
                  context: context,
                );
              }),
          const SizedBox(height: 10),
          const RTBannerView(
            adUnitId: "ca-app-pub-3940256099942544/6300978111",
            isReloadPerTime: true,
            timeOutInseconds: 60,
            isReloadNavigate: true,
            timeReloadInSeconds: 30,
          ),
          const SizedBox(height: 10),
          const RTNativeView(
            adUnitId: "ca-app-pub-3940256099942544/2247696110",
            type: RTNativeType.huge,
            isActive: true,
            isReload: true,
          ),
        ],
      ),
    );
  }
}
