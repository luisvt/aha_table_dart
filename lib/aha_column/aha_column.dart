import 'package:polymer/polymer.dart';

@CustomTag('aha-column')
class AhaColumn extends PolymerElement {
  AhaColumn.created() : super.created();

  ///column name
  @published String name = "";
  ///column type: string, text, date, time, datetime, choice
  @published String type = "string";
  @published bool sortable = false;
  @published bool searchable = false;
  @published bool editable = false;
  @published bool requried = false;
  //used for placeholder for empty cell.
  @published String placeholder;
  @published var defaultVal;
  //choices read from data-choices attribute
  @published List choices = [];
  //hint text in column header
  @published String hint;
  //placehoder for filter input
  @published String searchplaceholder;

  @published String label;

  @published bool required;

  @published List<Map> options;
}
