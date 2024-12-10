class Logs {
  static const tblLogs = 'logs';
  static const colId = 'id';
  static const colDate = 'date';
  static const colTime = 'time';
  static const colDevice = 'device';
  static const colUser = 'user';
  static const colEmpId = 'empid';
  static const colDetails = 'details';
  static const colUploaded = 'uploaded';

  late final int? id;
  late String? date;
  late String? time;
  late String? device;
  late String? user;
  late String? empid;
  late String? details;
  late String? uploaded;

  Logs(
      {this.id,
      this.date,
      this.time,
      this.device,
      this.user,
      this.empid,
      this.details,
      this.uploaded});

  Logs.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    date = map[colDate];
    time = map[colTime];
    device = map[colDevice];
    user = map[colUser];
    empid = map[colEmpId];
    details = map[colDetails];
    uploaded = map[colUploaded];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colDate: date,
      colTime: time,
      colDevice: device,
      colUser: user,
      colEmpId: empid,
      colDetails: details,
      colUploaded: 'false'
    };
    map[colId] = id;
    return map;
  }
}
