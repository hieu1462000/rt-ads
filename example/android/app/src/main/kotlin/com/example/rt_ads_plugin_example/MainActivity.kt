package com.example.rt_ads_plugin_example

import android.view.LayoutInflater
import com.example.rt_ads_plugin.RTNative.RTNativeBig
import com.example.rt_ads_plugin.RTNative.RTNativeBigCustom
import com.example.rt_ads_plugin.RTNative.RTNativeFull
import com.example.rt_ads_plugin.RTNative.RTNativeHuge
import com.example.rt_ads_plugin.RTNative.RTNativeMedium
import com.example.rt_ads_plugin.RTNative.RTNativeSmall
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeSmall", RTNativeSmall(LayoutInflater.from(context)))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeMedium", RTNativeMedium(LayoutInflater.from(context)))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeBig", RTNativeBig(LayoutInflater.from(context)))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeHuge", RTNativeHuge(LayoutInflater.from(context)))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeFull", RTNativeFull(LayoutInflater.from(context)))

        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeBigCustom1", RTNativeBigCustom(LayoutInflater.from(context), R.layout.rt_native_big_custom_1_view))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeBigCustom2", RTNativeBigCustom(LayoutInflater.from(context), R.layout.rt_native_big_custom_2_view))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeBigCustom3", RTNativeBigCustom(LayoutInflater.from(context), R.layout.rt_native_big_custom_3_view))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "RTNativeBigCustom4", RTNativeBigCustom(LayoutInflater.from(context), R.layout.rt_native_big_custom_4_view))
    }
}
