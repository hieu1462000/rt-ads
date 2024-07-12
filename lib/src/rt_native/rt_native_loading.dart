import 'package:flutter/material.dart';
import 'package:rt_ads_plugin/rt_ads_plugin.dart';
import 'package:shimmer/shimmer.dart';

class RTNativeLoading extends StatelessWidget {
  const RTNativeLoading({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        border: Border.all(color: const Color(0xffEAEAEA), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Shimmer.fromColors(
                  baseColor: const Color(0xffE7ECF2),
                  highlightColor: const Color(0xffB8C8D8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        color: Colors.white,
                        height: 36,
                        width: 36,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          height: 36,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 15,
                    width: 20,
                    decoration: BoxDecoration(
                      color: RTAppManagement.instance.rtAdColor.secondaryColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(2),
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(10)),
                    ),
                    child: const Center(
                      child: Text(
                        'Ad',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (height > 62)
            Expanded(
              child: Shimmer.fromColors(
                baseColor: const Color(0xffE7ECF2),
                highlightColor: const Color(0xffB8C8D8),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          if (height > 62)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Shimmer.fromColors(
                baseColor: const Color(0xffE7ECF2),
                highlightColor: const Color(0xffB8C8D8),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: 24,
                ),
              ),
            ),
          if (height > 62)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Shimmer.fromColors(
                baseColor: const Color(0xffE7ECF2),
                highlightColor: const Color(0xffB8C8D8),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
