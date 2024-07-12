import 'dart:developer';

class RTLog {
  static const String _tag = 'RTLog';

  RTLog._();

  static void d(String message) {
    log('$_tag: $message');
  }

  static void e(String message) {
    log('$_tag: $message');
  }
}
