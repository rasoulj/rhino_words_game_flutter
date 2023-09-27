import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pishgaman/consts/app_configs.dart';
import 'package:pishgaman/consts/t.dart';
import 'package:pishgaman/db/types.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/models/login_result.dart';
import 'package:pishgaman/models/rest_response.dart';
import 'package:pishgaman/utils/debug.dart';

import '../consts/f.dart';
import '../models/rank.dart';

// const List<ConnectivityResult> _okConn = [
//   ConnectivityResult.mobile,
//   ConnectivityResult.wifi,
// ];

//bool isOkConn(ConnectivityResult conn) => _okConn.contains(conn);

abstract class RestApi {
  static Map<String, String> getHeaders([String? token]) => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'x-access-token': token
      };

  static Future<RestResponse> _put(String tag, Json body,
      [String? token]) async {
    try {
      // ConnectivityResult conn = await (Connectivity().checkConnectivity());
      // debug("message: ${conn.name}");
      // if(!isOkConn(conn)) {
      //   return RestRespArr.error(T.networkError);
      // }
      var url = Uri.parse('${AppConfigs.baseUrl}/$tag');
      final response = await http.put(url,
          headers: getHeaders(token), body: json.encode(body));

      if (response.statusCode == 200) {
        return RestResponse.fromJson(jsonDecode(response.body) ?? {});
      } else {
        return RestResponse.error(response.body);
      }
    } catch (e) {
      return RestResponse.error(e.toString());
    }
  }

  static Future<RestResponse> _post(String tag, Json body,
      [String? token]) async {
    try {
      // ConnectivityResult conn = await (Connectivity().checkConnectivity());
      //debug("message: ${conn.name}");
      // if(!isOkConn(conn)) {
      //   return RestRespArr.error(T.networkError);
      // }
      var url = Uri.parse('${AppConfigs.baseUrl}/$tag');
      final response = await http.post(url,
          headers: getHeaders(token), body: json.encode(body));

      debug(response.request.toString());

      if (response.statusCode == 200) {
        return RestResponse.fromJson(jsonDecode(response.body) ?? {});
      } else {
        return RestResponse.error(response.body);
      }
    } catch (e) {
      debug(body.toString());
      debug("POST: " + e.toString());
      return RestResponse.error(e.toString());
    }
  }

  static Future<RestRespArr> _get(String tag) async {
    try {
      ConnectivityResult conn = await (Connectivity().checkConnectivity());
      debug("message: ${conn.name}");

      var url = Uri.parse('${AppConfigs.baseUrl}/$tag');
      final response = await http.get(url, headers: getHeaders());

      debug(response.body);

      if (response.statusCode == 200) {
        debug(jsonDecode(response.body));
        return RestRespArr.fromJson(jsonDecode(response.body));
      } else {
        return RestRespArr.error(response.body);
        // return RestRespArr.fromJson(jsonDecode(response.body) ?? {});
        // If the server did not return a 200 OK response,
        // then throw an exception.
        //throw Exception('Failed to GET $tag with id=$id');
      }
    } catch (e) {
      debug("111222");
      debug(e.toString());
      return RestRespArr.error(e.toString());
    }
  }

  static Future<RestResponse> _getD(String tag) async {
    try {
      // ConnectivityResult conn = await (Connectivity().checkConnectivity());

      var url = Uri.parse('${AppConfigs.baseUrl}/$tag');
      final response = await http.get(url, headers: getHeaders());

      if (response.statusCode == 200) {
        return RestResponse.fromJson(jsonDecode(response.body));
      } else {
        return RestResponse.error(response.body);
      }
    } catch (e) {
      debug(e.toString());
      return RestResponse.error(e.toString());
    }
  }

  static Future<RestRespArr> _fetch(String id) async {
    return _get("word$id");
  }

  static Future<ApiResponse<String>> fetchWord([int length = 5]) async {
    var resp = await _fetch("/$length");
    if (!resp.ok) return ApiResponse.error(resp.message);
    if (resp.data?.isEmpty ?? false) return ApiResponse.error();
    Json d = resp.data?.first ?? {};
    return ApiResponse(d.getStringField("text") ?? T.rhino);
  }

  static Future<ApiResponse<bool>> reportWord(String word) async {
    var resp = await _fetch("/report/$word");
    return resp.ok ? ApiResponse(true) : ApiResponse.error(resp.message);
  }

  static Future<ApiResponse<bool>> verifyWord(String text) async {
    var resp = await _fetch("?text=$text");
    debug("verifyWord: ${resp.status} ${resp.message} ${resp.ok}");
    return !resp.ok
        ? ApiResponse<bool>.error(resp.message)
        : ApiResponse<bool>(resp.data?.isNotEmpty ?? false);
  }

  static Future<ApiResponse<LoginResult>> login(
      String userName, String password) async {
    Json body = {
      F.userName: userName,
      F.password: password,
    };

    debug(body.toString());

    var resp = await _post(F.wuser, body);

    return resp.ok
        ? ApiResponse<LoginResult>(LoginResult.fromJson(resp.data ?? {}))
        : ApiResponse<LoginResult>.error(resp.message ?? T.unknownError);
  }

  static Future<ApiResponse<LoginResult>> register(
    String userName,
    String password,
    AppSettings? settings,
  ) async {
    Json body = {
      F.userName: userName,
      F.password: password,
      ...(settings ?? const AppSettings()).userSettings,
    };

    var resp = await _post("${F.wuser}/reg", body);
    if (!resp.ok) {
      return ApiResponse<LoginResult>.error(resp.message ?? T.unknownError);
    }

    return login(userName, password);
  }

  static Future<ApiResponse<Map<String, List<Rank>>>> getTopRanks(
      int score) async {
    try {
      RestResponse resp = await _getD(
        "${F.wuser}/tops?v=${AppConfigs.version}&score=$score",
      );

      if (!resp.ok) {
        return ApiResponse.error(resp.message ?? T.unknownError);
      }

      debug("score: $score");

      var ranks = List<Rank>.from(
        (resp.data ?? {}).getMapList(F.ranks).map((x) => Rank.fromJson(x)),
      );
      var update = List<Rank>.from(
        ((resp.data ?? {}).getMapList(F.update)).map((x) => Rank.fromJson(x)),
      );
      return ApiResponse({
        F.update: update,
        F.ranks: ranks,
      });
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Json?>> update(Json? body, String token) async {
    try {
      if ((body ?? {}).isEmpty) return ApiResponse.error("Empty body!");
      RestResponse resp = await _put(F.wuser, body ?? {}, token);
      debug("---> ${resp.data}");
      return resp.ok ? ApiResponse(resp.data) : ApiResponse.error(resp.message);
    } catch (e) {
      debug(e.toString());
      return ApiResponse.error(e.toString());
    }
  }
}
