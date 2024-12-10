class Admin {
  static const tblAdmin     = 'admin';
  static const colId        = '_id';
  static const colAppId     = 'id';
  static const colEmpId     = "emp_id";
  static const colEmpNo     = "emp_no";
  static const colEmpPin    = "emp_pin";
  static const colUsertype  = 'usertype';
  static const colEmpName   = 'emp_name';
  static const colBusinessUnit = 'business_unit';

  late final int? id;
  late String? empAppId;
  late String? empId;
  late String? empNo;
  late String? empPin;
  late String? empUsertype;
  late String? empName;
  late String? empBusinessUnit;

  Admin(
      {this.id,
        this.empAppId,
        this.empId,
        this.empNo,
        this.empPin,
        this.empUsertype,
        this.empName,
        this.empBusinessUnit});

  Admin.fromMap(Map<String, dynamic> map) {
    id          = map[colId];
    empAppId    = map[colAppId];
    empId       = map[colEmpId];
    empNo       = map[colEmpNo];
    empPin      = map[colEmpPin];
    empUsertype = map[colUsertype];
    empName     = map[colEmpName];
    empBusinessUnit = map[colBusinessUnit];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAppId    : empAppId,
      colEmpId    : empId,
      colEmpNo    : empNo,
      colEmpPin   : empPin,
      colUsertype : empUsertype,
      colEmpName  : empName,
      colBusinessUnit : empBusinessUnit
    };
    map[colId] = id;
    return map;
  }
}