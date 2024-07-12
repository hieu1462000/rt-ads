import 'package:flutter/material.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:shimmer/shimmer.dart';

class RTBannerLoading extends StatelessWidget {
  const RTBannerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 60,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Shimmer.fromColors(
              baseColor: const Color(0xffE7ECF2),
              highlightColor: const Color(0xffB8C8D8),
              period: const Duration(milliseconds: 3000),
              child: Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    color: Colors.white,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      height: 50,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    color: Colors.white,
                    height: 20,
                    width: 10,
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              )),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 16,
              width: 22,
              decoration: BoxDecoration(
                color: RTAppManagement.instance.rtAdColor.secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Ad',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
