import 'package:polymer/polymer.dart';

@CustomTag('aha-table-demo')
class AhaTableDemo extends PolymerElement{
  AhaTableDemo.created() : super.created();

  @observable ObservableList secondOptions = toObservable([{'value': '1', 'label':'opt1'}, {'value':'2', 'label': 'opt2'}]);
  
  @observable var tableData = toObservable([
    {'first': true, 'second': 'opt1', 'third': 'one'},
    {'first': false, 'second': 'opt2', 'third': 'two'},
    {'first': true, 'second': 'opt1', 'third': 'three'}
  ]);
  
}