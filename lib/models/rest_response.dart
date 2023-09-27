// To parse this JSON data, do
//
//     final restResponse = restResponseFromJson(jsonString);

import 'dart:convert';

import 'package:pishgaman/db/types.dart';

import '../consts/t.dart';

class ApiResponse<S> {
  final S? data;
  final String? message;
  final int status;

  ApiResponse(this.data, {this.message, this.status = 1});
  bool get ok => status == 1;

  factory ApiResponse.error([String? error = T.unknownError]) => ApiResponse(
        null,
        status: 0,
        message: error ?? T.unknownError,
      );
}

// Json toStringMap(Map<dynamic, dynamic>? a) {
//   Json ret = {};
//   Map<dynamic, dynamic> aa = a ?? {};
//   for (var key in aa.keys) {
//     ret[key.toString()] = aa[key];
//   }
//   return ret;
// }
//
// List<Json> getMapList(Json? map, String key) {
//   if (map == null) return [];
//   List p = map[key] ?? [];
//   List<Map> q = p.map((e) => e as Map).toList();
//   return q.map(toStringMap).toList();
// }

class RestResponse {
  RestResponse({
    this.status,
    this.message,
    this.data,
  });

  factory RestResponse.error([String error = T.unknownError]) => RestResponse(
        status: 0,
        message: error,
        data: {},
      );

  final int? status;
  final String? message;
  final Json? data;

  bool get ok => status == 1;

  RestResponse copyWith({
    int? status,
    String? message,
    Json? data,
  }) =>
      RestResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory RestResponse.fromRawJson(String str) =>
      RestResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestResponse.fromJson(Json json) => RestResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
      );

  Json toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}

class RestRespArr {
  RestRespArr({
    this.status,
    this.message,
    this.data,
  });

  bool get ok => status == 1;

  final int? status;
  final String? message;
  final List<Json>? data;

  RestRespArr copyWith({
    int? status,
    String? message,
    List<Json>? data,
  }) =>
      RestRespArr(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory RestRespArr.fromRawJson(String str) =>
      RestRespArr.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestRespArr.error([String error = T.unknownError]) => RestRespArr(
        status: 0,
        message: error,
        data: [],
      );
  factory RestRespArr.fromJson(Json json) => RestRespArr(
        status: json["status"],
        message: json["message"],
        data: json.getMapList("data"),
      );

  Json toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}
