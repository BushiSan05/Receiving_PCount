class Audit {
  static const tblAudit = 'audit';
  static const colId = 'id';
  static const colAppId = 'auappid';
  static const coldEmpId = "emp_id";
  static const coldEmpNo = "emp_no";
  static const coldEmpPin = "emp_pin";
  static const colName = 'name';
  static const colPosition = 'position';
  static const colLocId = 'location_id';

  late final int? id;
  late String? empAppId;
  late String? empId;
  late String? empNo;
  late String? empPin;
  late String? empName;
  late String? empPosition;
  late String? empLocId;

  Audit(
      {this.id,
      this.empAppId,
      this.empId,
      this.empNo,
      this.empPin,
      this.empName,
      this.empPosition,
      this.empLocId});

  Audit.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    empAppId = map[colAppId];
    empId = map[coldEmpId];
    empNo = map[coldEmpNo];
    empPin = map[coldEmpPin];
    empName = map[colName];
    empPosition = map[colPosition];
    empLocId = map[colLocId];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAppId: empAppId,
      coldEmpId: empId,
      coldEmpNo: empNo,
      coldEmpPin: empPin,
      colName: empName,
      colPosition: empPosition,
      colLocId: empLocId
    };
    map[colId] = id;
    return map;
  }
}
