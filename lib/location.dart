class location{
  String latitude;
  String longitude;
  String country;
  String country_code;
  int id;
  int confirmed;
  int deaths;
  int recovered;
  String province;

  location.fromJson(Map<dynamic,dynamic> map){

    this.latitude=map['coordinates']['latitude'];
    this.longitude=map['coordinates']['longitude'];
    this.country=map['country'];
    this.country_code=map['country_code'];
    this.confirmed=map['latest']['confirmed'];
    this.deaths=map['latest']['deaths'];
    this.recovered=map['latest']['recovered'];
    this.province=map['province'];
    this.id=map['id'];

    
  }
}