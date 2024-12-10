import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:physicalcountv2/db/models/adminModel.dart';
import 'package:physicalcountv2/db/models/auditModel.dart';
import 'package:physicalcountv2/db/models/filterModel.dart';
import 'package:physicalcountv2/db/models/itemCountModel.dart';
import 'package:physicalcountv2/db/models/itemModel.dart';
import 'package:physicalcountv2/db/models/itemNotFoundModel.dart';
import 'package:physicalcountv2/db/models/locationModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/models/unitModel.dart';
import 'package:physicalcountv2/db/models/usersModel.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteDBHelper {
  static const _databaseName = 'PCOUNT19.db';
  static const _databaseVersion = 5;

  SqfliteDBHelper._();
  static final SqfliteDBHelper instance = SqfliteDBHelper._();

  late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
  }

  void _onDowngrade(Database db, int oldVersion, int newVersion) async{
    if (oldVersion > newVersion) {
      //await db.execute("ALTER TABLE ${Admin.tblAdmin}2 ADD COLUMN ${Admin.colBusinessUnit} TEXT");

//--ADMIN TABLE--//
      await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Admin.tblAdmin}(
        ${Admin.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Admin.colAppId} TEXT NOT NULL,
        ${Admin.colEmpId} TEXT NOT NULL,
        ${Admin.colEmpNo} TEXT NOT NULL,
        ${Admin.colEmpPin} TEXT NOT NULL,
        ${Admin.colUsertype} TEXT NOT NULL,
        ${Admin.colEmpName} TEXT NOT NULL,
        ${Admin.colBusinessUnit} TEXT NOT NULL
      )
    ''');
//--ADMIN TABLE--//

//--ADD COLUMN ITEMCOUNT TABLE//
      await db.execute("ALTER TABLE ${ItemCount.tblItemCount} ADD COLUMN ${ItemCount.colDesc} TEXT");
//--ADD COLUMN ITEMCOUNT TABLE//

//--ADD COLUMN ITEM TABLE//
      await db.execute("ALTER TABLE ${Item.tblItem} ADD COLUMN ${Item.colDesc} TEXT");
//--ADD COLUMN ITEM TABLE//
    }
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < newVersion) {
      //await db.execute("ALTER TABLE ${Admin.tblAdmin}2 ADD COLUMN ${Admin.colBusinessUnit} TEXT");

//--ADMIN TABLE--//
      await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Admin.tblAdmin}(
        ${Admin.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Admin.colAppId} TEXT NOT NULL,
        ${Admin.colEmpId} TEXT NOT NULL,
        ${Admin.colEmpNo} TEXT NOT NULL,
        ${Admin.colEmpPin} TEXT NOT NULL,
        ${Admin.colUsertype} TEXT NOT NULL,
        ${Admin.colEmpName} TEXT NOT NULL,
        ${Admin.colBusinessUnit} TEXT NOT NULL
      )
    ''');
//--ADMIN TABLE--//

//--ADD COLUMN ITEMCOUNT TABLE//
      await db.execute("ALTER TABLE ${ItemCount.tblItemCount} ADD COLUMN ${ItemCount.colDesc} TEXT");
//--ADD COLUMN ITEMCOUNT TABLE//

//--ADD COLUMN ITEM TABLE//
      await db.execute("ALTER TABLE ${Item.tblItem} ADD COLUMN ${Item.colDesc} TEXT");
//--ADD COLUMN ITEM TABLE//
    }
  }

  _onCreateDB(Database db, int version) async {
//--LOGS TABLE--//
    await db.execute('''
      CREATE TABLE ${Logs.tblLogs}(
        ${Logs.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Logs.colDate} TEXT NOT NULL,
        ${Logs.colTime} TEXT NOT NULL,
        ${Logs.colDevice} TEXT NOT NULL,
        ${Logs.colUser} TEXT NOT NULL,
        ${Logs.colEmpId} TEXT NOT NULL,
        ${Logs.colDetails} TEXT NOT NULL,
        ${Logs.colUploaded} TEXT NOT NULL
      )
    ''');
//--LOGS TABLE--//

//--USERS TABLE--//
    await db.execute('''
      CREATE TABLE ${User.tblUser}(
        ${User.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${User.colAppId} TEXT NOT NULL,
        ${User.coldEmpId} TEXT NOT NULL,
        ${User.coldEmpNo} TEXT NOT NULL,
        ${User.coldEmpPin} TEXT NOT NULL,
        ${User.colName} TEXT NOT NULL,
        ${User.colPosition} TEXT NOT NULL,
        ${User.colLocId} TEXT NOT NULL,
        ${User.colDone} TEXT NOT NULL,
        ${User.colLocked} TEXT NOT NULL
      )
    ''');
//--USERS TABLE--//

//--AUDIT TABLE--//
    await db.execute('''
      CREATE TABLE ${Audit.tblAudit}(
        ${Audit.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Audit.colAppId} TEXT NOT NULL,
        ${Audit.coldEmpId} TEXT NOT NULL,
        ${Audit.coldEmpNo} TEXT NOT NULL,
        ${Audit.coldEmpPin} TEXT NOT NULL,
        ${Audit.colName} TEXT NOT NULL,
        ${Audit.colPosition} TEXT NOT NULL,
        ${Audit.colLocId} TEXT NOT NULL
      )
    ''');
//--AUDIT TABLE--//

//--LOCATION TABLE--//
    await db.execute('''
      CREATE TABLE ${Location.tblLocation}(
        ${Location.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Location.colLocationId} TEXT NOT NULL,
        ${Location.colLocationCompany} TEXT NOT NULL,
        ${Location.colLocationBu} TEXT NOT NULL,
        ${Location.colLocationDepartment} TEXT NOT NULL, 
        ${Location.colLocationSection} TEXT NOT NULL, 
        ${Location.colLocationRackDesc} TEXT NOT NULL
      )
    ''');
//--LOCATION TABLE--//

//--ITEM TABLE--//
    await db.execute('''
      CREATE TABLE ${Item.tblItem}(
        ${Item.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Item.colItemcode} TEXT NOT NULL,
        ${Item.colBarcode} TEXT NOT NULL,
        ${Item.colDescription} TEXT NOT NULL,
        ${Item.colDesc} TEXT NOT NULL,
        ${Item.colUOM} TEXT NOT NULL,
        ${Item.colVendor} TEXT NOT NULL,
        ${Item.colGroup} TEXT NOT NULL,
        ${Item.colCategory} TEXT NOT NULL,
        ${Item.colConversionqty} TEXT NOT NULL,
        ${Item.colVariantcode} TEXT NOT NULL
      )
    ''');
//--ITEM TABLE--//

//--ITEM UNIT--//
    await db.execute('''
      CREATE TABLE ${Unit.tblUnit}(
        ${Unit.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Unit.colUom} TEXT NOT NULL
      )
    ''');
//--ITEM UNIT--//

//--ITEM NOT FOUND--//
    await db.execute('''
      CREATE TABLE ${ItemNotFound.tblItemNotFound}(
        ${ItemNotFound.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemNotFound.colBarcode} TEXT NOT NULL,
        ${ItemNotFound.colDesc} TEXT,
        ${ItemNotFound.colUom} TEXT NOT NULL,
        ${ItemNotFound.colQty} TEXT NOT NULL,
        ${ItemNotFound.colLocation} TEXT NOT NULL,
        ${ItemNotFound.colExported} TEXT NOT NULL,
        ${ItemNotFound.colDTCreated} TEXT NOT NULL,
        ${ItemNotFound.colBu} TEXT NOT NULL,
        ${ItemNotFound.coldept} TEXT NOT NULL,
        ${ItemNotFound.colsection} TEXT NOT NULL,
        ${ItemNotFound.colempno} TEXT NOT NULL,
        ${ItemNotFound.colrack} TEXT NOT NULL,
        ${ItemNotFound.coldescription} TEXT NOT NULL,
        ${ItemNotFound.colitemcode} TEXT NOT NULL
      )
    ''');
//--ITEM NOT FOUND--//

//--FILTERS TABLE--//
//     await db.execute('''
//       CREATE TABLE ${Filter.tblFilter}(
//         ${Filter.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
//         ${Filter.colbyCategory} TEXT NOT NULL,
//         ${Filter.colcategoryName} TEXT NOT NULL,
//         ${Filter.colbyVendor} TEXT NOT NULL,
//         ${Filter.colvendorName} TEXT NOT NULL,
//         ${Filter.coltype} TEXT NOT NULL,
//         ${Filter.collocation} TEXT NOT NULL
//       )
//     ''');
    await db.execute('''
      CREATE TABLE ${Filter.tblFilter}(
        ${Filter.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Filter.colbyCategory} TEXT,
        ${Filter.colcategoryName} TEXT,
        ${Filter.colbyVendor} TEXT,
        ${Filter.colvendorName} TEXT,
        ${Filter.coltype} TEXT,
        ${Filter.colcountType} TEXT,
        ${Filter.colbatchDate} TEXT,
        ${Filter.collocation} TEXT
      )
    ''');
//--FILTERS TABLE--//

//--ITEMCOUNT TABLE--//
    await db.execute('''
      CREATE TABLE ${ItemCount.tblItemCount}(
        ${ItemCount.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemCount.colBarcode} TEXT NOT NULL,
        ${ItemCount.colItemcode} TEXT NOT NULL,
        ${ItemCount.colDescription} TEXT NOT NULL,
        ${ItemCount.colDesc} TEXT NOT NULL,
        ${ItemCount.colUOM} TEXT NOT NULL,
        ${ItemCount.colLotno} TEXT,
        ${ItemCount.colExpiry} TEXT,
        ${ItemCount.colQty} TEXT NOT NULL,
        ${ItemCount.colConQty} TEXT NOT NULL,
        ${ItemCount.colLocation} TEXT NOT NULL,
        ${ItemCount.colBU} TEXT NOT NULL,
        ${ItemCount.colArea} TEXT NOT NULL,
        ${ItemCount.colRackNo} TEXT NOT NULL,
        ${ItemCount.colDTCreated} TEXT NOT NULL,
        ${ItemCount.colDTSaved} TEXT NOT NULL,
        ${ItemCount.colEmpNo} TEXT NOT NULL,
        ${ItemCount.colExported} TEXT NOT NULL,
        ${ItemCount.colLocationId} TEXT NOT NULL
      )
    ''');
//--ITEMCOUNT TABLE--//

//--ADMIN TABLE--//
    await db.execute('''
      CREATE TABLE ${Admin.tblAdmin}(
        ${Admin.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Admin.colAppId} TEXT NOT NULL,
        ${Admin.colEmpId} TEXT NOT NULL,
        ${Admin.colEmpNo} TEXT NOT NULL,
        ${Admin.colEmpPin} TEXT NOT NULL,
        ${Admin.colUsertype} TEXT NOT NULL,
        ${Admin.colEmpName} TEXT NOT NULL,
        ${Admin.colBusinessUnit} TEXT NOT NULL
      )
    ''');
//--ADMIN TABLE--//

  }

//-----------------LOGS-----------------//
  Future<int> insertLog(Logs logs) async {
    Database db = await database;
    return await db.insert(Logs.tblLogs, logs.toMap());
  }

  Future fetchLogsWhere(String where) async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Logs.tblLogs} WHERE $where");
  }

  Future<List<Logs>> fetchLogs() async {
    Database db = await database;
    List<Map<String, Object?>> logs =
    await db.query(Logs.tblLogs, orderBy: "id DESC");
    return logs.length == 0 ? [] : logs.map((e) => Logs.fromMap(e)).toList();
  }
//-----------------LOGS-----------------//

//-----------------USERS-----------------//
  Future<int> deleteUserAll() async {
    Database db = await database;
    return await db.delete(User.tblUser);
  }

  Future insertUserBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(User.tblUser, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  // Future<List> selectUserWhere(String empno, String emppin) async {
  //   var db = await database;
  //   List x = await db.rawQuery(
  //       "SELECT * FROM ${User.tblUser} WHERE emp_no='$empno' AND emp_pin='$emppin'");
  //   if (x.length > 0) {
  //     return db.rawQuery(
  //         "SELECT * FROM ${User.tblUser} WHERE emp_no ='$empno' AND emp_pin='$emppin'",null);
  //   } else {
  //     var user = int.parse(empno) * 1;
  //     return db.rawQuery(
  //         "SELECT * FROM ${User.tblUser} WHERE emp_no = '$user' AND emp_pin='$emppin'",null);
  //   }
  // }

  Future<List> selectUserWhere(String empno, String emppin) async {
    var db = await database;
    List x = await db.rawQuery(
        "SELECT * FROM ${User.tblUser} WHERE emp_no='$empno' AND emp_pin='$emppin'");

    if (x.isNotEmpty) {
      // Return the user data if found
      return x;
    } else {
      try {
        // Try parsing the empno and query again
        var user = int.parse(empno) * 1;
        List y = await db.rawQuery(
            "SELECT * FROM ${User.tblUser} WHERE emp_no = '$user' AND emp_pin='$emppin'");
        if (y.isNotEmpty) {
          return y;
        } else {
          print('no result both');
          // No results from both queries, return empty list
          return [];
        }
      } catch (e) {
        print('no result');
        // Return empty list in case of any exception
        return [];
      }
    }
  }


  Future fetchUsersWhere(String where) async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${User.tblUser} WHERE $where");
  }

  Future selectUserArea(String empno, String business_unit) async {
    print(business_unit);
    var db = await database;
    var where = "";
    switch(business_unit){
      case "LOCAL" :
        break;
      default:
        where = "AND b.business_unit = '$business_unit'";
    }
    List x = await db.rawQuery(
        "SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no = '$empno' $where");
    //"SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no = '$empno'");

    if (x.length > 0) {
      return db.rawQuery(
          "SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no = '$empno' $where");
      //"SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no = '$empno'");
    } else {
      var user = int.parse(empno) * 1;
      return db.rawQuery(
          "SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no LIKE '%$user%' $where");
      //"SELECT a.emp_no, b.business_unit, b.department, b.section, b.rack_desc, a.done, a.locked, a.location_id FROM ${User.tblUser} as a INNER JOIN ${Location.tblLocation} as b ON a.location_id = b.location_id WHERE a.emp_no LIKE '%$user%'");
    }
  }

  Future selectU(String empno) async {
    var db = await database;
    List x = await db
        .rawQuery("SELECT * FROM ${User.tblUser} WHERE emp_no = '$empno'");
    if (x.length > 0) {
      return db
          .rawQuery("SELECT * FROM ${User.tblUser} WHERE emp_no = '$empno'");
    } else {
      var u = int.parse(empno) * 1;
      return db.rawQuery("SELECT * FROM ${User.tblUser} WHERE emp_no = '$u'");
    }
  }

  Future updateUserAssignAreaWhere(String column, String where) async {
    var db = await database;
    print("UPDATE ${User.tblUser} SET $column WHERE $where");
    return db.rawQuery("UPDATE ${User.tblUser} SET $column WHERE $where");
  }
//-----------------USERS-----------------//

//-----------------ADMIN-----------------//
  Future<int> deleteAdminAll() async {
    Database db = await database;
    return await db.delete(Admin.tblAdmin);
  }

  Future insertAdminBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Admin.tblAdmin, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  Future<List> selectAdminWhere(String empno, String emppin) async {
    var db = await database;
    List x = await db.rawQuery(
        "SELECT * FROM ${Admin.tblAdmin} WHERE emp_no='$empno' AND emp_pin='$emppin'");
    if (x.length > 0) {
      return db.rawQuery(
          "SELECT * FROM ${Admin.tblAdmin} WHERE emp_no ='$empno' AND emp_pin='$emppin'",null);
    } else {
      var user = int.parse(empno) * 1;
      return db.rawQuery(
          "SELECT * FROM ${Admin.tblAdmin} WHERE emp_no = '$user' AND emp_pin='$emppin'",null);
    }
  }
//-----------------AMIN-----------------//

//-----------------AUDIT-----------------//
  Future<int> deleteAuditAll() async {
    Database db = await database;
    return await db.delete(Audit.tblAudit);
  }

  Future insertAuditBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Audit.tblAudit, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  Future selectAuditWhere(String id, String locationid) async {
    var db = await database;
    // print("SELECT * FROM ${Audit.tblAudit} WHERE $where");
    // return db.rawQuery("SELECT * FROM ${Audit.tblAudit} WHERE $where");
    List x = await db.rawQuery("SELECT * FROM ${Audit.tblAudit} WHERE emp_no='$id' AND location_id='$locationid'");
    if (x.length > 0) {
      return db.rawQuery("SELECT * FROM ${Audit.tblAudit} WHERE emp_no='$id' AND location_id='$locationid'");
    } else {
      var user = int.parse(id) * 1;
      return db.rawQuery(
          "SELECT * FROM ${Audit.tblAudit} WHERE emp_no = '$user' AND location_id='$locationid'");
    }
  }

  Future findAuditByLocationId(String locationid) async {
    var db = await database;
    List x = await db.rawQuery(
        "SELECT * FROM ${Audit.tblAudit} WHERE location_id='$locationid'");
    return x;
  }
//-----------------AUDIT-----------------//

//-----------------LOCATION-----------------//
  Future<int> deleteLocationAll() async {
    Database db = await database;
    return await db.delete(Location.tblLocation);
  }

  Future insertLocationBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Location.tblLocation, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  Future fetchLocation() async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Location.tblLocation}");
  }
//-----------------LOCATION-----------------//

//-----------------ITEM-----------------//
  Future<int> deleteItemAll() async {
    Database db = await database;
    return await db.delete(Item.tblItem);
  }

  Future itemSearched(text) async {
    var client = await database;
    print('Search items ni');
    // print(client.rawQuery(
    //     "SELECT * FROM itemsCount WHERE barcode LIKE '%$text%' AND exported = '' ",
    //     null));
    return client.rawQuery("SELECT * FROM itemsCount WHERE barcode LIKE '%$text%' AND exported = '' AND empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}' AND location_id = '${GlobalVariables.currentLocationID}'", null);
  }

  Future searchNfItems(value)async{
    var client = await database;
    return client.rawQuery("SELECT * FROM itemnotfound WHERE barcode LIKE '%$value%' AND exported = 'false' AND empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}' AND location = '${GlobalVariables.currentLocationID}'", null);
  }

  Future searchNFItemsbyItemCode(value)async{
    var client = await database;
    return client.rawQuery("SELECT * FROM itemnotfound WHERE itemcode LIKE '%$value%' AND exported ='' AND empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}' AND location = '${GlobalVariables.currentLocationID}'",null);
  }

  Future validateBarcode(barcode)async{
    var client = await database;
    return client.rawQuery("SELECT * FROM items WHERE barcode = '$barcode' ",null);
  }

  Future validateItemCode(itemCode)async{
    var client = await database;
    return client.rawQuery("SELECT * FROM items WHERE item_code = '$itemCode' ", null);
  }

  Future insertItemBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Item.tblItem, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  Future selectItemWhereCatVen(String barcode, String catven) async {
    var db = await database;
    return db.rawQuery(
        "SELECT * FROM ${Item.tblItem} WHERE barcode='$barcode' $catven");
  }

  Future selectItemWhereItemcode(String itemcode) async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Item.tblItem} WHERE barcode='$itemcode'");
  }
//-----------------ITEM-----------------//

//-----------------FILTERS-----------------//
  Future<int> deleteFilterAll() async {
    Database db = await database;
    return await db.delete(Filter.tblFilter);
  }

  Future insertFilterBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Filter.tblFilter, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }

  Future selectFilterWhere(String locationId) async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Filter.tblFilter} WHERE location_id ='$locationId'");
  }

  Future selectItemWhere(String barcode) async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Item.tblItem} WHERE barcode='$barcode'");
  }
//-----------------FILTERS-----------------//

//-----------------UNITS-------------------//
  Future<int> deleteUnitAll() async {
    Database db = await database;
    return await db.delete(Unit.tblUnit);
  }

  Future selectUnitsAll() async {
    var db = await database;
    return db.rawQuery("SELECT * FROM ${Unit.tblUnit}");
  }

  Future insertUnitBatch(items, int start, int end) async {
    Database db = await database;
    await db.transaction((txn1) async {
      print("start $start end $end");
      Batch batch = txn1.batch();
      for (var i = start; i < end; i++) {
        batch.insert(Unit.tblUnit, items[i]);
      }
      await batch.commit();
      print("done $start end $end");
    });
  }
//-----------------UNITS-------------------//

//-----------------ITEM NOT FOUND-------------------//
  Future selectItemNotFoundWhere(String location) async {
    var db = await database;
    return db.rawQuery(
        "SELECT * FROM ${ItemNotFound.tblItemNotFound} WHERE location='$location'");
  }

  Future<List<ItemNotFound>> fetchItemNotFoundWhere(String where) async {
    Database db = await database;
    List<Map<String, Object?>> itemNotFound = await db.query(ItemNotFound.tblItemNotFound, where: where);
    return itemNotFound.length == 0
        ? []
        : itemNotFound.map((e) => ItemNotFound.fromMap(e)).toList();
  }

  Future<int> insertItemNotFound(ItemNotFound itemNotFound) async {
    Database db = await database;
    return await db.insert(ItemNotFound.tblItemNotFound, itemNotFound.toMap());
  }

  Future<int> deleteItemNotFound(int id) async {
    Database db = await database;
    return await db.delete(ItemNotFound.tblItemNotFound,
        where: '${ItemNotFound.colId}=?', whereArgs: [id]);
  }

  Future updateItemNotFoundWhere(int id, String column) async {
    var db = await database;
    return db.rawQuery(
        "UPDATE ${ItemNotFound.tblItemNotFound} SET $column WHERE id=$id");
  }

  Future selectItemNotFoundRawQuery(String sql) async {
    var db = await database;
    return db.rawQuery(sql);
  }

  Future getCountType(location_id)async{
    var db = await database;
    return db.rawQuery("SELECT countType FROM filter WHERE location_id = '$location_id' ");
  }

  Future getCountTypeDate(String emp_no, String business_unit)async{
    print("Emp_no: $emp_no, Business Unit: $business_unit");
    var db = await database;
    return db.rawQuery("SELECT user.emp_no, user.location_id, fil.batchDate, fil.countType, fil.ctype "
        "FROM users AS user "
        "INNER JOIN filter AS fil ON user.location_id = fil.location_id "
        "INNER JOIN locations AS loc ON user.location_id = loc.location_id "
        "WHERE loc.business_unit = '$business_unit' "
    // "AND fil.batchDate BETWEEN '$formattedWeekBefore' AND '$formattedWeekAfter'"
        "AND user.emp_no = '$emp_no' ");
  }

  Future updateItemNotFoundByLocation(String locationid, String column) async {
    var db = await database;
    return db.rawQuery(
        "UPDATE ${ItemNotFound.tblItemNotFound} SET $column WHERE location='$locationid'");
  }
//-----------------ITEM NOT FOUND-------------------//

//-----------------ITEMCOUNT-----------------//
  /*Future<int> deleteItemCountAll() async {
    Database db = await database;
    return await db.delete(ItemCount.tblItemCount);
  }*/


  Future<int> insertItemCount(ItemCount itemCount) async {
    Database db = await database;
    return await db.insert(ItemCount.tblItemCount, itemCount.toMap());
  }

  Future<List<ItemCount>> fetchItemCountWhere(String where) async {
    Database db = await database;
    List<Map<String, Object?>> itemCount = await db.query(ItemCount.tblItemCount, where: where);
    return itemCount.length == 0
        ? []
        : itemCount.map((e) => ItemCount.fromMap(e)).toList();
  }

  Future<List<ItemNotFound>> fetchNFCountWhere(String where) async {
    Database db = await database;
    List<Map<String, Object?>> itemNF = await db.query(ItemNotFound.tblItemNotFound, where: where);
    return itemNF.length == 0
        ? []
        : itemNF.map((e) => ItemNotFound.fromMap(e)).toList();
  }


  Future<int> deleteItemCountWhere(int id) async {
    Database db = await database;
    return await db.delete(ItemCount.tblItemCount,
        where: '${ItemCount.colId}=?', whereArgs: [id]);
  }

  // Future updateItemCountWhere(int id, String column) async {
  //   var db = await database;
  //   return db
  //       .rawQuery("UPDATE ${ItemCount.tblItemCount} SET $column WHERE id=$id");
  // }

  Future updateItemCountWhere(int id, String column) async {
    var db = await database;
    return db
        .rawQuery("UPDATE ${ItemCount.tblItemCount} SET $column WHERE id=$id");
  }



  Future selectItemCountRawQuery(String sql) async {
    var db = await database;
    return db.rawQuery(sql);
  }

  Future updateItemCountNullDesc() async {
    print("update Item Count if Desc is null");
    var db = await database;
    return await db.rawQuery(
        "UPDATE ${ItemCount.tblItemCount} SET ${ItemCount.colDesc} = '' WHERE ${ItemCount.colDesc} IS NULL");
  }

  Future updateItemCountByLocation(String locationid, String column) async {
    var db = await database;
    return db.rawQuery(
        "UPDATE ${ItemCount.tblItemCount} SET $column WHERE location_id='$locationid'");
  }

  Future updateItemCountByUser(String userid, String column) async {
    var db = await database;
    return db.rawQuery(
        "UPDATE ${ItemCount.tblItemCount} SET $column WHERE empno='$userid'");
  }

  Future updateNFItemCountByUser(String userid, String column) async {
    var db = await database;
    return db.rawQuery(
        "UPDATE ${ItemNotFound.tblItemNotFound} SET $column WHERE empno='$userid'");
  }

//-----------------ITEMCOUNT-----------------//
  Future getAuditInfo(String id)async{
    var db= await database;
    return db.rawQuery("SELECT * FROM audit where emp_no = '$id'");
  }

  Future getAuditTrail()async {
    var db = await database;
    return db.rawQuery("SELECT date, time, device, user, empid, details FROM ${Logs.tblLogs} WHERE uploaded = 'false' ");
  }

  Future updateTblAuditTrail()async{
    var db = await database;
    return db.rawQuery("UPDATE ${Logs.tblLogs} SET uploaded = 'true' WHERE uploaded = 'false' ");
  }

}
