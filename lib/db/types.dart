import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Json = Map<String, dynamic>;

typedef SetStateFunc = void Function(VoidCallback fn);

extension JsonEx on Json {
  String? getStringField(String key, {String? defValue = ""}) {
    return containsKey(key) ? this[key] ?? defValue : defValue;
  }

  int getIntField(String key, {int defValue = 0}) {
    return containsKey(key) ? (this[key] + 0.0).toInt() : defValue;
  }

  double getDoubleField(String key, {double defValue = 0}) {
    return containsKey(key) ? this[key] + 0.0 : defValue;
  }

  bool getBoolField(String key, {bool defValue = false}) {
    return containsKey(key) ? this[key] : defValue;
  }

  List<Json> getMapList(String key) {
    List p = this[key] ?? [];
    List<Map> q = p.map((e) => e as Map).toList();
    return q.map(Json.from).toList();
  }

  List<String> getStringList(String key, {List<String> defValue = const []}) {
    List p = this[key] ?? defValue;
    List<String> q = p.map((e) => e as String).toList();
    return q;
  }

  DateTime? getDateTimeField(String key, {DateTime? defValue}) {
    return containsKey(key) ? DateTime.parse(this[key]) : defValue;
  }
}

// String? getStringField(Map<dynamic, dynamic>? json, String key,
//     {String? defValue = ""}) {
//   if (json == null) return defValue;
//   return json.containsKey(key) ? json[key] ?? defValue : defValue;
// }

// int getIntField(Map<dynamic, dynamic>? json, String key, {int defValue = 0}) {
//   if (json == null || json[key] == null) return defValue;
//   return json.containsKey(key) ? (json[key] + 0.0).toInt() : defValue;
// }

// double getDoubleField(Map<dynamic, dynamic>? json, String key,
//     {double defValue = 0}) {
//   if (json == null) return defValue;
//   return json.containsKey(key) ? json[key] + 0.0 : defValue;
// }

// bool getBoolField(Map<dynamic, dynamic>? json, String key,
//     {bool defValue = false}) {
//   if (json == null) return defValue;
//   return json.containsKey(key) ? json[key] : defValue;
// }

// Json toStringMap(Map<dynamic, dynamic>? a) {
//   return Json.from(a as Map);
//   Json ret = {};
//   Map<dynamic, dynamic> aa = a ?? {};
//   for (var key in aa.keys) {
//     ret[key.toString()] = aa[key];
//   }
//   return ret;
// }

// List<Json> getMapList(Json? map, String key) {
//   if (map == null) return [];
//   List p = map[key] ?? [];
//   List<Map> q = p.map((e) => e as Map).toList();
//   return q.map(toStringMap).toList();
// }

// List<String> getStringList(Json? map, String key,
//     {List<String> defValue = const []}) {
//   if (map == null) return defValue;
//   List p = map[key] ?? defValue;
//   List<String> q = p.map((e) => e as String).toList();
//   return q;
// }

// Json getJsonField(Map<dynamic, dynamic>? json, String key) {
//   if (json == null) return {};
//   return (json.containsKey(key) ? toStringMap(json[key]) : {});
// //  return a.map((e) => e.toString()).toList();
// }

// DateTime? getDateTimeField(Map<dynamic, dynamic>? json, String key,
//     {DateTime? defValue}) {
//   if (json == null) return defValue;
//   return json.containsKey(key) ? DateTime.parse(json[key]) : defValue;
// }

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

enum AppCollections {
  singleDocsCollection,
  bookings,
}
