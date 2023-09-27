import 'package:flutter/foundation.dart';

void debug(Object? obj) {
  if (kDebugMode) {
    print(obj);
  }
}
