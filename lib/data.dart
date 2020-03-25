import 'package:corona_virus_tracker/location.dart';

class Fetch_data{
  List<location> loc;
  List<String> countrys;
  Map<String,List<String>> provinces;

  Fetch_data(this.loc,this.countrys,this.provinces);
}