import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_io.dart';
import 'dart:io' show Platform;

import 'idb.dart';
import 'types.dart';

class SembastDb {
  static const _kDeletedFlag = "deleted";
  sembast.Database db;

  /// to use this ctor, you should create a sembast isntance externally, or use [init]
  /// ```
  /// sembast.Database _db = await databaseFactoryIo.openDatabase(path);
  /// final db = SembastDb(_db);
  /// ```
  SembastDb(this.db);

  /// opens db, must run before using db
  static Future<SembastDb> init([String fileName = "database.db"]) async {
    final path = await generatePath(fileName);
    sembast.Database db = await databaseFactoryIo.openDatabase(path);
    return SembastDb._(db);
  }

  /// delete db file then reopens new one
  Future<void> deleteDb([String fileName = "database.db"]) async {
    final path = await generatePath(fileName);
    await db.close();
    await databaseFactoryIo.deleteDatabase(path);
  }

  Future deleteDoc(String collection, String id) async {
    final store = sembast.stringMapStoreFactory.store(collection);
    return await store.record(id).put(db, {_kDeletedFlag: true}, merge: true);
  }

  /// only adds deleted flag
  Future deleteDocs(
    String collection, {
    FilterData? filterData,
  }) async {
    final filter = _calcFilters(filterData);
    final store = sembast.stringMapStoreFactory.store(collection);
    final docs = await store.find(db,
        finder: sembast.Finder(filter: sembast.Filter.and(filter)));
    int cnt = 0;
    await db.transaction((tr) async {
      for (final doc in docs) {
        await store.record(doc.key).put(tr, {_kDeletedFlag: true}, merge: true);
        cnt++;
      }
    });
    return cnt;
  }

  /// delete docs, only used for garbage collecting
  Future _deleteDocs(
    String collection, {
    FilterData? filterData,
  }) async {
    final store = sembast.stringMapStoreFactory.store(collection);
    List<sembast.Filter> filters = _calcFilters(filterData);
    return store.delete(db,
        finder: filterData == null
            ? null
            : sembast.Finder(filter: sembast.Filter.and(filters)));
  }

  /// deletes docs which have deleted K_DELETED_FLAG == true
  Future garbageCollect(String collection, {FilterData? filterData}) {
    return _deleteDocs(collection,
        filterData: filterData?.addEqualTo(_kDeletedFlag, true));
  }

  Future<Json?> doc(String collection, String id) async {
    final store = sembast.stringMapStoreFactory.store(collection);
    final res = await store.record(id).get(db);
    if (res != null && res[_kDeletedFlag] == true) return null;
    return res;
  }

  Stream<Json?> docStream(String collection, String id) {
    final store = sembast.stringMapStoreFactory.store(collection);
    return store
        .record(id)
        .onSnapshot(db)
        .map((event) => event?.value)
        .asBroadcastStream()
        .where((d) => (d ?? {})[_kDeletedFlag] != true);
  }

  Future<String> _setData(String collection, Json doc,
      {String? id, bool? merge}) async {
    final store = sembast.stringMapStoreFactory.store(collection);
    if (id == null) {
      return await store.add(db, doc);
    } else {
      await store.record(id).put(db, doc, merge: merge);
      return id;
    }
  }

  /// write to db with dirty flag
  Future<String> setData(String collection, Json doc,
      {String? id, bool? merge}) async {
    // doc["dirty"] = 1;
    return _setData(collection, doc, id: id, merge: merge);
  }

  Future setList(String collection, List<Map<String, dynamic>> docs,
      {bool? merge}) async {
    docs = docs.map((d) => Json.from(d)).toList();
    final store = sembast.stringMapStoreFactory.store(collection);
    return await db.transaction((txn) async {
      for (final doc in docs) {
        final id = doc["_id"] as String?;
        if (id == null) {
          await store.add(txn, doc);
        } else {
          await store.record(id).put(txn, doc, merge: merge);
        }
      }
    });
  }

  ///  write to db without db flag
  Future<String> setDataRaw(String collection, Json doc,
      {String? id, bool? merge}) async {
    return _setData(collection, doc, id: id, merge: merge);
  }

  Stream<Json> colStream(String singleDocsCollection, {String? collection}) {
    throw UnimplementedError(); // NOTE: updated to consider deleted first
    // final store = sembast.stringMapStoreFactory.store(collection);
    // return store.stream(db).map((event) => event.value).asBroadcastStream();
  }

  Future<List<Json>> query(
    String collection, {
    FilterData? filterData,
    List<SortOrder>? sortOrders,
  }) async {
    final q = _query(
        collection: collection,
        filterData: filterData!.addNotEqualTo(_kDeletedFlag, true),
        sortOrders: sortOrders!);
    final snapshots = await q.getSnapshots(db);
    return snapshots.map((e) => e.value).toList();
  }

  Stream<List<Json>> queryStream(String collection,
      {FilterData? filterData, List<SortOrder>? sortOrders}) {
    final q = _query(
      collection: collection,
      filterData: filterData?.addNotEqualTo(_kDeletedFlag, true),
      sortOrders: sortOrders,
    );
    return q
        .onSnapshots(db)
        .map((event) => event.map((e) => e.value).toList())
        .asBroadcastStream();
  }

  Future dispose() async {
    return await db.close();
  }

  /// raw internal query, doesnt consider deleted status
  sembast.QueryRef<String, Json> _query({
    String? collection,
    FilterData? filterData,
    List<SortOrder>? sortOrders,
  }) {
    final store = sembast.stringMapStoreFactory.store(collection);
    List<sembast.Filter> filters = _calcFilters(filterData);
    return store.query(
        finder: sembast.Finder(
      filter: sembast.Filter.and(filters),
      sortOrders: sortOrders
          // fixes changing of nullLast logic when switching from asc to dec
          ?.map((e) => sembast.SortOrder(
              e.field, e.ascending, !(e.nullLast ^ e.ascending)))
          .toList(),
    ));
  }

  List<sembast.Filter> _calcFilters(
    FilterData? filterData,
  ) {
    final filters = <sembast.Filter>[];
    if (filterData != null) {
      if (filterData.isEqualTos!.isNotEmpty) {
        filterData.isEqualTos?.forEach((key, value) {
          filters.add(sembast.Filter.equals(key, value));
        });
      }

      if (filterData.isNotEqualTos!.isNotEmpty) {
        filterData.isNotEqualTos?.forEach((key, value) {
          filters.add(sembast.Filter.notEquals(key, value));
        });
      }

      if (filterData.isLessThans!.isNotEmpty) {
        filterData.isLessThans?.forEach((key, value) {
          filters.add(sembast.Filter.lessThan(key, value));
        });
      }

      if (filterData.isLessThanOrEqualTos!.isNotEmpty) {
        filterData.isLessThanOrEqualTos?.forEach((key, value) {
          filters.add(sembast.Filter.lessThanOrEquals(key, value));
        });
      }

      if (filterData.isGreaterThans!.isNotEmpty) {
        filterData.isGreaterThans?.forEach((key, value) {
          filters.add(sembast.Filter.greaterThan(key, value));
        });
      }

      if (filterData.isGreaterThanOrEqualTos!.isNotEmpty) {
        filterData.isGreaterThanOrEqualTos?.forEach((key, value) {
          filters.add(sembast.Filter.greaterThanOrEquals(key, value));
        });
      }

      if (filterData.arrayContainsAnys!.isNotEmpty) {
        filterData.arrayContainsAnys?.forEach((arKey, arValue) {
          final f = sembast.Filter.custom((record) {
            return (record.value[arKey] as List).any((element) {
              return arValue.any((e) => e == element);
            });
          });
          filters.add(f);
        });
      }

      if (filterData.arrayContainss != null &&
          filterData.arrayContainss!.isNotEmpty) {
        filterData.arrayContainss?.forEach((key, value) {
          final f = sembast.Filter.custom((record) {
            return (record.value[key] as List).any((rv) {
              return rv == value;
            });
          });
          filters.add(f);
        });
      }
    }
    return filters;
  }

  // @protected
  static Future<String> generatePath(String fileName) async {
    String dir = "";
    if (Platform.isIOS || Platform.isAndroid) {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    return "$dir/$fileName";
  }

  Future<dynamic> test() async {}

  SembastDb._(this.db);
}
