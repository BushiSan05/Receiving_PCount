class Item {
  static const tblItem = 'items';
  static const colId = 'id';
  static const colItemcode = 'item_code';
  static const colBarcode = 'barcode';
  // static const colDescription = 'desc';
  static const colDescription = 'extended_desc';
  static const colDesc = 'desc';
  static const colUOM = 'uom';
  static const colVendor = 'vendor_name';
  static const colGroup = 'ggroup';
  static const colCategory = 'category';
  static const colConversionqty = 'conversion_qty';
  static const colVariantcode = 'variant_code';

  late final int? id;
  late String? itemcode;
  late String? barcode;
  late String? description;
  late String? uom;
  late String? vendor;
  late String? group;
  late String? category;
  late String? conversionqty;
  late String? variantcode;

  Item({
    this.id,
    this.itemcode,
    this.barcode,
    this.description,
    this.uom,
    this.vendor,
    this.group,
    this.category,
    this.conversionqty,
    this.variantcode,
  });

  Item.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    itemcode = map[colItemcode];
    barcode = map[colBarcode];
    description = map[colDescription];
    uom = map[colUOM];
    vendor = map[colVendor];
    group = map[colGroup];
    category = map[colCategory];
    conversionqty = map[colConversionqty];
    variantcode = map[colVariantcode];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colItemcode: itemcode,
      colBarcode: barcode,
      colDescription: description,
      colUOM: uom,
      colVendor: vendor,
      colCategory: category,
      colGroup: group,
      colConversionqty: conversionqty,
      colVariantcode: variantcode,
    };
    map[colId] = id;
    return map;
  }
}
