import 'dart:async';
import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

class RTConsentManager {
  static final RTConsentManager instance = RTConsentManager._internal();
  factory RTConsentManager() => instance;
  RTConsentManager._internal();

  Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  Future<bool> loadForm() async {
    Completer<bool> adCompleter = Completer<bool>();

    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final consentStatus = await ConsentInformation.instance.getConsentStatus();
        if (consentStatus == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            if (formError == null) {
              RTLog.d("1.1 Consent form loaded");
              adCompleter.complete(true);
            } else {
              adCompleter.complete(false);
            }
          });
        } else {
          adCompleter.complete(true);
        }
      },
      (FormError formError) {
        log("Cant show consent form");
        adCompleter.complete(false);
      },
    );

    return await adCompleter.future;
  }

  Future<bool> gatherConsent() async {
    Completer<bool> adCompleter = Completer<bool>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(consentDebugSettings: ConsentDebugSettings()),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          RTLog.d("1. Consent form available");
          await loadForm();
          RTLog.d("2. Consent form loaded");
          adCompleter.complete(true);
        } else {
          adCompleter.complete(false);
        }
      },
      (FormError formError) {
        log("Cant show consent form");
        adCompleter.complete(false);
      },
    );

    await adCompleter.future;

    return await ConsentInformation.instance.canRequestAds();
  }
}
