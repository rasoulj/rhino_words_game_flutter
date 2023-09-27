


import 'package:pishgaman/db/types.dart';

class FilterData {
  FilterData({
    this.isEqualTos,
    this.isNotEqualTos,
    this.isLessThans,
    this.isLessThanOrEqualTos,
    this.isGreaterThans,
    this.isGreaterThanOrEqualTos,
    this.arrayContainsAnys,
    this.arrayContainss,
  });
  final Json? isEqualTos;
  final Json? isNotEqualTos;
  final Json? isLessThans;
  final Json? isLessThanOrEqualTos;
  final Json? isGreaterThans;
  final Json? isGreaterThanOrEqualTos;
  final Map<String, List<dynamic>>? arrayContainsAnys;
  final Json? arrayContainss;

  FilterData copyWith({
    Json? isEqualTos,
    Json? isNotEqualTos,
    Json? isLessThans,
    Json? isLessThanOrEqualTos,
    Json? isGreaterThans,
    Json? isGreaterThanOrEqualTos,
    Map<String, List<dynamic>>? arrayContainsAnys,
    Json? arrayContainss,
  }) {
    return FilterData(
      isEqualTos: isEqualTos ?? this.isEqualTos,
      isNotEqualTos: isNotEqualTos ?? this.isNotEqualTos,
      isLessThans: isLessThans ?? this.isLessThans,
      isLessThanOrEqualTos: isLessThanOrEqualTos ?? this.isLessThanOrEqualTos,
      isGreaterThans: isGreaterThans ?? this.isGreaterThans,
      isGreaterThanOrEqualTos: isGreaterThanOrEqualTos ?? this.isGreaterThanOrEqualTos,
      arrayContainsAnys: arrayContainsAnys ?? this.arrayContainsAnys,
      arrayContainss: arrayContainss ?? this.arrayContainss,
    );
  }
}

extension FilterDataExtension on FilterData {
  FilterData addEqualTo(String key, dynamic value) {
    FilterData newFilter =
        copyWith(isEqualTos: isEqualTos ?? {});
    newFilter.isEqualTos![key] = value;
    return newFilter;
  }

  /// add a filter to current filter to only include docs which are not deleted
  FilterData addNotEqualTo(String key, dynamic value) {
    FilterData newFilter =
        copyWith(isNotEqualTos: isNotEqualTos ?? {});
    newFilter.isNotEqualTos![key] = value;
    return newFilter;
  }
}

/// add a filter to current filter to only include deleted docs

class SortOrder {
  /// When [ascending] nulls are position first, When not [ascending] nulls
  /// are positioned last
  ///
  /// [nullLast] means nulls are sorted last in ascending order
  /// so if not [ascending], it means null are sorted first
  SortOrder(this.field, {this.ascending = true, this.nullLast = true});
  String field;
  bool ascending;
  bool nullLast;
}
