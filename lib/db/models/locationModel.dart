class Location {
  static const tblLocation = 'locations';
  static const colId = 'id';
  static const colLocationId = 'location_id';
  static const colLocationCompany = 'company';
  static const colLocationBu = 'business_unit';
  static const colLocationDepartment = 'department';
  static const colLocationSection = 'section';
  static const colLocationRackDesc = 'rack_desc';

  late final int? id;
  late String? locationId;
  late String? locationCompany;
  late String? locationBusinessUnit;
  late String? locationDeparment;
  late String? locationSection;
  late String? locationRackDescription;

  Location(
      {this.id,
      this.locationId,
      this.locationCompany,
      this.locationBusinessUnit,
      this.locationDeparment,
      this.locationSection,
      this.locationRackDescription});

  Location.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    locationId = map[colLocationId];
    locationCompany = map[colLocationCompany];
    locationBusinessUnit = map[colLocationBu];
    locationDeparment = map[colLocationDepartment];
    locationSection = map[colLocationSection];
    locationRackDescription = map[colLocationRackDesc];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colLocationId: locationId,
      colLocationCompany: locationCompany,
      colLocationBu: locationBusinessUnit,
      colLocationDepartment: locationDeparment,
      colLocationSection: locationSection,
      colLocationRackDesc: locationRackDescription
    };
    map[colId] = id;
    return map;
  }
}
