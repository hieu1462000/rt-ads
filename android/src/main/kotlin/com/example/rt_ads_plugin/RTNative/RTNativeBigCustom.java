package com.example.rt_ads_plugin.RTNative;


import android.annotation.SuppressLint;
import android.graphics.BlendMode;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.example.rt_ads_plugin.R;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

import io.flutter.Log;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

import java.util.Map;
import java.util.Objects;

/**
 * my_native_ad.xml can be found at
 * github.com/googleads/googleads-mobile-flutter/blob/main/packages/google_mobile_ads/
 *     example/android/app/src/main/res/layout/my_native_ad.xml
 */
public class RTNativeBigCustom implements GoogleMobileAdsPlugin.NativeAdFactory {
    private final LayoutInflater layoutInflater;
    private final int layoutResource;

    public RTNativeBigCustom(LayoutInflater layoutInflater, int layoutResource) {
        this.layoutInflater = layoutInflater;
        this.layoutResource = layoutResource;
    }

    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        @SuppressLint("InflateParams") final NativeAdView adView = (NativeAdView) layoutInflater.inflate(layoutResource, null);



        adView.setMediaView(adView.findViewById(R.id.ad_media));
        adView.setHeadlineView(adView.findViewById(R.id.ad_headline));
        adView.setBodyView(adView.findViewById(R.id.ad_body));
        adView.setCallToActionView(adView.findViewById(R.id.ad_call_to_action));
        adView.setIconView(adView.findViewById(R.id.ad_app_icon));
        adView.setAdvertiserView(adView.findViewById(R.id.ad_advertiser));

        int primaryColor = Color.parseColor(customOptions.get("primaryColor").toString());
        adView.findViewById(R.id.ad_call_to_action).getBackground().setColorFilter(primaryColor, PorterDuff.Mode.SRC_ATOP);

        int backgroundColor = Color.parseColor(customOptions.get("backgroundColor").toString());
        int strokeColor = Color.parseColor(customOptions.get("strokeColor").toString());

        adView.findViewById(R.id.native_view).getBackground().setColorFilter(backgroundColor, PorterDuff.Mode.SRC_ATOP);
        //        GradientDrawable drawable = (GradientDrawable)view.getBackground();
//        drawable.mutate(); // only change this instance of the xml, not all components using this xml
//        drawable.setStroke(3, Color.RED); // set stroke width and stroke color
        // adView.findViewById(R.id.native_view).getBackground().setTint(Color.RED);



//        ShapeDrawable drawable = button.getBackground() instanceof ShapeDrawable ? (ShapeDrawable) button.getBackground() : null;
//        if (drawable != null) {
//            drawable.getPaint().setColor(primaryColor);
//        }
//        button.setBackground(drawable);
        TextView textView3 = adView.findViewById(R.id.textView3);
        adView.findViewById(R.id.textView3).getBackground().setColorFilter(primaryColor,PorterDuff.Mode.SRC_ATOP);
        TextView ad_headline = adView.findViewById(R.id.ad_headline);
        ad_headline.setTextColor(primaryColor);

        // The headline and mediaContent are guaranteed to be in every NativeAd.
        ((TextView) Objects.requireNonNull(adView.getHeadlineView())).setText(nativeAd.getHeadline());

        if (adView.getMediaView() != null) {
            adView.getMediaView().setMediaContent(nativeAd.getMediaContent());
        }

        // These assets aren't guaranteed to be in every NativeAd, so it's important to
        // check before trying to display them.
        if (nativeAd.getBody() == null) {
            Objects.requireNonNull(adView.getBodyView()).setVisibility(View.INVISIBLE);
        } else {
            Objects.requireNonNull(adView.getBodyView()).setVisibility(View.VISIBLE);
            ((TextView) adView.getBodyView()).setText(nativeAd.getBody());
        }

        if (nativeAd.getCallToAction() == null) {
            Objects.requireNonNull(adView.getCallToActionView()).setVisibility(View.INVISIBLE);
        } else {
            adView.getCallToActionView().setVisibility(View.VISIBLE);
            ((TextView) adView.getCallToActionView()).setText(nativeAd.getCallToAction());
        }

        if (nativeAd.getIcon() == null) {
            adView.getIconView().setVisibility(View.INVISIBLE);
        } else {
            ((ImageView) adView.getIconView()).setImageDrawable(nativeAd.getIcon().getDrawable());
            adView.getIconView().setVisibility(View.VISIBLE);
        }

        if (adView.getAdvertiserView() != null) {
            if (nativeAd.getAdvertiser() == null) {
                adView.getAdvertiserView().setVisibility(View.INVISIBLE);
            } else {
                ((TextView) adView.getAdvertiserView()).setText(nativeAd.getAdvertiser());
                adView.getAdvertiserView().setVisibility(View.VISIBLE);
            }
        }



        // This method tells the Google Mobile Ads SDK that you have finished populating your
        // native ad view with this native ad.
        adView.setNativeAd(nativeAd);

        return adView;
    }
}