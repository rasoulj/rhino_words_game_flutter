abstract class AppConfigs {
  static const int maxTry = 7;
  static const int maxHistory = 5;

  // static const String baseUrl = "http://157.90.207.53:2537";
  // static const String baseUrl = "http://91.218.229.163:2537";
  static const String baseUrl = "http://localhost:2537";

  static final List<String> initGuesses = List.generate(maxTry, (index) => "");

  static const String version = "0.0.1";
}

abstract class TapsellIds {
  static const String appId =
      "odbpersiaojrctnmfkanjmgjapsgbknagdcaeemifbkhqjetahiipcipfgeefoqkrplkbn";

  static const String rewardBased = "62cff56cb0f60101056ea344";
}
