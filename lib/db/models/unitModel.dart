class Unit {
  static const tblUnit = 'unit';
  static const colId = 'id';
  static const colUom = 'uom';

  late final int? id;
  late String? uom;

  Unit({
    this.id,
    this.uom,
  });

  Unit.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    uom = map[colUom];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUom: uom,
    };
    map[colId] = id;
    return map;
  }
}
