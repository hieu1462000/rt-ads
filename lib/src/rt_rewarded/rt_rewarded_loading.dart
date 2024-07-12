import 'package:flutter/material.dart';

class LoadingAdsRewarded extends StatelessWidget {
  const LoadingAdsRewarded({super.key, this.loadingIconColor, this.loadingText});

  final Color? loadingIconColor;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: loadingIconColor),
            const SizedBox(height: 8),
            Text('${loadingText ?? 'Loading ads'}...'),
          ],
        ),
      ),
    );
  }
}
