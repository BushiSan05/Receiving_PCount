class ItemCount {
  static const tblItemCount = 'itemsCount';
  static const colId = 'id';
  static const colBarcode = 'barcode';
  static const colItemcode = 'itemcode';
  static const colDescription = 'description';
  static const colDesc = 'desc';
  static const colUOM = 'uom';
  static const colLotno = 'lot_number';
  // static const colBatno = 'batch_number';
  static const colExpiry = 'expiry';
  static const colQty = 'qty';
  static const colConQty = 'conqty';
  static const colLocation = 'business_unit';
  static const colBU = 'department';
  static const colArea = 'section';
  static const colRackNo = 'rack_desc';
  static const colDTCreated = 'datetimecreated';
  static const colDTSaved = 'datetimesaved';
  static const colEmpNo = 'empno';
  static const colExported = 'exported';
  static const colLocationId = 'location_id';

  late final int? id;
  late String? barcode;
  late String? itemcode;
  late String? description;
  late String? desc;
  late String? uom;
  late String? lotno;
  // late String? batno;
  late String? expiry;
  late String? qty;
  late String? conqty;
  late String? location;
  late String? bu;
  late String? area;
  late String? rackno;
  late String? dateTimeCreated;
  late String? dateTimeSaved;
  late String? empNo;
  late String? exported;
  late String? locationid;


  ItemCount(
      {this.id,
      this.barcode,
      this.itemcode,
      this.description,
      this.desc,
      this.uom,
      this.lotno,
      // this.batno,
      this.expiry,
      this.qty,
      this.conqty,
      this.location,
      this.bu,
      this.area,
      this.rackno,
      this.dateTimeCreated,
      this.dateTimeSaved,
      this.empNo,
      this.exported,
      this.locationid});

  ItemCount.fromMap(Map<String, dynamic> map) {
    id              = map[colId];
    barcode         = map[colBarcode];
    itemcode        = map[colItemcode];
    description     = map[colDescription];
    desc            = map[colDesc] ?? map[""];
    uom             = map[colUOM];
    lotno           = map[colLotno];
    // batno           = map[colBatno];
    expiry          = map[colExpiry];
    qty             = map[colQty];
    conqty          = map[colConQty];
    location        = map[colLocation];
    bu              = map[colBU];
    area            = map[colArea];
    rackno          = map[colRackNo];
    dateTimeCreated = map[colDTCreated];
    dateTimeSaved   = map[colDTSaved];
    empNo           = map[colEmpNo];
    exported        = map[colExported];
    locationid      = map[colLocationId];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colBarcode      : barcode,
      colItemcode     : itemcode,
      colDescription  : description,
      colDesc         : desc ?? "",
      colUOM          : uom,
      colLotno        : lotno,
      // colBatno        : batno,
      colExpiry       : expiry,
      colQty          : qty,
      colConQty       : conqty,
      colLocation     : location,
      colBU           : bu,
      colArea         : area,
      colRackNo       : rackno,
      colDTCreated    : dateTimeCreated,
      colDTSaved      : dateTimeSaved,
      colEmpNo        : empNo,
      colExported     : exported,
      colLocationId   : locationid,
    };
    map[colId] = id;
    return map;
  }
}
