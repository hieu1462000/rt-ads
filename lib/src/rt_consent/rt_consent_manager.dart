import 'dart:async';
import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rt_ads_plugin/src/rt_log/rt_log.dart';

/// A class that manages consent for displaying ads.
///
/// This class provides methods for checking if ads can be requested,
/// loading and showing a consent form, and gathering user consent.
class RTConsentManager {
  static final RTConsentManager instance = RTConsentManager._internal();
  factory RTConsentManager() => instance;
  RTConsentManager._internal();

  /// Checks if the app is eligible to request ads.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the app can request ads.
  /// This method internally calls the `canRequestAds()` method of the [ConsentInformation] instance.
  ///
  /// Example usage:
  /// ```dart
  /// bool canRequest = await RTConsentManager.instance.canRequestAds();
  /// ```
  Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  /// Loads the consent form and returns a Future<bool> indicating whether the form was successfully loaded.
  ///
  /// The consent form is loaded using the `ConsentForm.loadConsentForm` method. If the consent status is required,
  /// the form is shown to the user. If the form is successfully shown, the method completes with a value of `true`.
  /// Otherwise, it completes with a value of `false`.
  ///
  /// If there is an error while loading or showing the consent form, the method also completes with a value of `false`.
  ///
  /// Returns a Future<bool> indicating whether the consent form was successfully loaded and shown.
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

  /// Gathers the consent from the user.
  /// Returns a [Future] that completes with a [bool] value indicating whether the consent was gathered successfully.
  ///
  /// The consent is gathered by requesting consent information update and checking if the consent form is available.
  /// If the consent form is available, it loads the form and completes the future with `true`.
  /// If the consent form is not available, it completes the future with `false`.
  /// If there is an error while showing the consent form, it completes the future with `false`.
  ///
  /// Usage:
  /// ```dart
  /// bool consent = await  RTConsentManager.instance.gatherConsent();
  /// ```
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
