import 'package:polymer/polymer.dart';

@CustomTag('aha-column')
class AhaColumn extends PolymerElement {
  AhaColumn.created() : super.created();

  /// Defines the column name.
  @published String name = '';

  /// Defines the column type. It could have next values:
  /// 
  /// * string
  /// * text
  /// * date
  /// * time
  /// * datetime
  /// * choice
  @published String type = "string";

  /// Sets if the column is sortable. If true, when user clicks the column
  /// header this column is going to be sorted.
  @published bool sortable = false;

  /// Sets if the column is searchable. In this case is going to appear a search
  /// component
  @published bool searchable = false;

  /// Defines if this column is editable
  @published bool editable = false;

  /// Defines if this column is required when editing.
  @published bool required = false;

  ///used for placeholder for empty cell.
  @published String editorplaceholder;

  /// editor default Value
  @published var defaultVal;

  ///choices read from data-choices attribute
  @published List choices = [];

  /// hint text in column header
  @published String hint;

  /// Search Place Holder for filter input
  @published String searchplaceholder;

  /// Defines the label that is going to appears in the column header
  @published String label;

  /// Defines the options that the dropdown editor is going to have
  @published List<Map> options;
}
