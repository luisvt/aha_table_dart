import 'package:polymer/polymer.dart';
import 'package:template_binding/template_binding.dart';
import 'dart:html';
import 'package:aha_table/aha_column/aha_column.dart';
import 'package:polymer_expressions/filter.dart';

class StringToInt extends Transformer<String, int> {
  String forward(int i) => i.toString();

  int reverse(String s) {
    try {
      return int.parse(s);
    } catch (e) {
      return null;
    }
  }
}

class AhaRow extends Object with Observable {
  @observable int index = 0;
  @observable bool selected = false;
  @observable bool editing = false;
  @observable bool modified = false;
  @observable var value;
}

@CustomTag('aha-table')
class AhaTable extends PolymerElement {

  AhaTable.created() : super.created();

//  void polymerCreated() {
//    ListPathObserver observer = new ListPathObserver(viewingRows, 'checked');
//    observer.changes.listen((changeRecords) {
//      print('viewingRows.checked changed');
//      notifyPropertyChange(#allSelected, false, true);
//    });
//    super.polymerCreated();
//  }

  /// instance of the model data
  @published ObservableList dataRows = toObservable([]);
  List<AhaRow> _dataRowsAux;

  //instance of the model meta
  @published List meta = [];

  /// all created or modified row will be referenced here.
  /// it's hard to determine if it's created or modified after multiple
  /// operations, because the element doesn't assume there's an id column,
  /// so you need to determine if by yourself, like check
  /// if the id exists if your model has an id column.
  @published List modifiedRows = [];

  /// all deleted row will be moved here.
  @published List deleted = [];

  ///all selected row will be referenced here.
  @published ObservableList selectedRows = toObservable([]);

  /// if table row is selectable
  @published bool selectable = false;

  /// if table row is copyable
  @published bool copyable = false;

  /// if table row is removable
  @published bool removable = false;

  ///if table rows are searchable
  @published bool searchable = false;

  /// text displayed in first column of search row.
  @published String searchtitle = 'Search';

  /// text displayed as title of select checkbox.
  @published String selecttitle = 'Select Row';

  /// text displayed as title of selectall checkbox.
  @published String selectalltitle = 'Select All';

  /// text displayed as title of sorting column.
  @published String sorttitle = 'Sort column';

  /// text displayed as title of column name.
  @published String columntitle = "";

  /// text displayed as title of copy indicator.
  @published String copytitle = 'Copy';

  /// text displayed as title of remove checkbox..
  @published String removetitle = 'Remove';

  /// text displayed as title of editable cell.
  @published String edittitle = 'Edit';

  /// sortedColumn: sorted column name
  @published String sortedColumn;

  /// current editing row
  @published AhaRow editingRow = null;

  /// if filtering has been performed.
  @published bool filtered = false;

  /// current rows in display/view
  @published ObservableList<AhaRow> viewingRows = toObservable([]);

  /// descending: current sorting order
  @published bool descending = false;

  /// the number of items to show per page
  @published int pagesize = 10;

  /// currentpage: the current active page in view
  @published int currentpage = 1;

  //pageCount: the number of paginated pages
  @published int pageCount = 0;

  /// itemCount: the number of visible items
  @published int itemCount = 0;

  /// firstItemIndex: the index number of first item in the page, start from 1
  @published int firstItemIndex = 1;

  /// lastItemIndex: the index number of last item in the page, start from 1
  @published int lastItemIndex = 1;

  /// sizelist: range list to adjust page size.
  @published List sizelist = [5, 10, 20, 50, 100];

  /// previous: label for the Previous button
  @published String previous = "<";

  /// next: label for the Next button
  @published String next = ">";

  /// first: label for the First page button
  @published String first = "<<";

  /// last: label for the Last page button
  @published String last = ">>";

  /// pagesizetitle: label for page size box
  @published String pagesizetitle = "";

  /// summarytitle: label for table summary area
  @published String summarytitle = "";

  /// Tooltip for first button
  @published String firsttitle,

  /// Tooltip for next button
  nexttitle,

  /// Tooltip for previous button
  previoustitle,

  /// Tooltip for last button
  lasttitle,

  /// Tooltip for page textbox
  pagetext,

  /// Tooltip for pageof textbox
  pageoftext,

  /// Tooltip for pagezie text
  pagesizetext,

  /// Tooltip for summary
  summarytext,

  /// Tooltip for itemof
  itemoftext;

  final asInt = new StringToInt();

  ready() {
    //Show element when it's ready.
    $['aha_table_main'].attributes.remove('unresolved');

    currentpage = 1;
  }

  //=========
  //internal methods
  dataRowsChanged() {
//      if (meta.length == 0)  {
//        $['aha_table_main'].setAttribute('unresolved', '');
//        // generate meta from data if meta is not provided from aha-column.
//        meta = [];
//        for (var prop in data[0]) {
//          if (prop.indexOf('_') != 0) {//skip internal field
//            meta.add({
//              'name': prop,
//              'label': prop.charAt(0).toUpperCase() + prop.slice(1), 
//              'type': [true, false].indexOf(data[0][prop]) > -1 ? "boolean" : "string", 
//              'sortable': true, 
//              'searchable': true, 
//              'editable': true, 
//              'required': false
//            });
//          }
//        }
//        $['aha_table_main'].setAttribute('resolved', '');
//        $['aha_table_main'].removeAttribute('unresolved');
//      }
    var i = 1;
    _dataRowsAux = dataRows.map((dr) =>
    new AhaRow()
      ..index = i++
      ..value = dr
      ..modified = modifiedRows.contains(dr)
      ..selected = selectedRows.contains(dr)
    ).toList();

    refreshPagination(true);
  }

//  modifiedRowsChanged() {
//  }

  //translate value to labels for select
  translate2(value, options, blank) {
    if (value != "" && options) {
      for (var i = options.length - 1; i >= 0; i--) {
        if (options[i].value == value) {
          return options[i].label;
        }
      };
    }
    value = value == null ? '' : value;
    return value == "" ? blank : value;
  }

  capitalize(value) {
//      if (value is! String || value.length == 0) 
//        return value;
//      return value.charAt(0).toUpperCase() + value.slice(1);
    return value;
  }

  edited(e) {
    var row = nodeBind(e.target).templateInstance.model['row'];
    row.editing = true;
    if (editingRow != null && editingRow != row) {
      editingRow.editing = false;
    }
    editingRow = row;
  }

  save(e) {
    AhaRow row = nodeBind(e.target).templateInstance.model['row'];
    AhaColumn column = nodeBind(e.target).templateInstance.model['column'];
    if (row != null) {
      if ("BOOLEAN" == column.type.toUpperCase()) {
        row.value[column.name] = e.target.checked;
      } else {
        row.value[column.name] = e.target.value;
      }
      if (modifiedRows.indexOf(row) == -1) {
        row.modified = true;
        modifiedRows.add(row);
      }

      row.editing = false;

      if (column.required != null /*&& !e.target.validity.valid*/) {
        fire('after-invalid', detail: {"event": e, "row" : row, "column" : column});
      }
    }
  }

  handleSort(Event e) {
    AhaColumn column = nodeBind(e.target).templateInstance.model['column'];
    if (column != null && column.sortable) {
      var sortingColumn = column.name;
      if (sortingColumn == sortedColumn) {
        descending = !descending;
      } else {
        sortedColumn = sortingColumn;
      }
    }

    refreshPagination();
  }

  @observable ObservableMap<String, dynamic> searchMap = toObservable({});

  List<AhaRow> _filteredRows;

  search(event, details, target) {
    AhaColumn column = nodeBind(target).templateInstance.model['column'];

    searchMap[column.name] = "BOOLEAN" == column.type.toUpperCase() ? target.checked : target.value;

    refreshPagination();
  }

  //============
  //pagination
  firstPage() {
    currentpage = 1;
  }

  prevPage() {
    if (currentpage == null) {
      currentpage = 1;
    }
    if (currentpage > 1) {
      currentpage--;
    }
  }

  nextPage() {
    if (currentpage == null) {
      currentpage = pageCount;
    }
    if (currentpage < pageCount) {
      currentpage++;
    }
  }

  lastPage() {
    currentpage = pageCount;
  }

  currentpageChanged() {
    if (currentpage != null) {
      currentpage = currentpage < 1 ? 1 : currentpage;
      currentpage = pageCount > 0 && currentpage > pageCount ? pageCount : currentpage;
      filterPage();
      firstItemIndex = (currentpage - 1) * pagesize + 1;
    }
  }

  /// called when pagesize dropdown is changed
  pagesizeChanged() {
    refreshPagination();
  }

  /// refresh the values of current page and viewing rows
  refreshPagination([keepInTheCurentPage = false]) {
    // We need to check this for the first time table is loaded
    // and attributes like pageSize has been setted.
    if(_dataRowsAux == null) return;

    if (!keepInTheCurentPage) {
      // Usually go to the first page is the best way to avoid chaos.
      currentpage = 1;
    }

    // Update model bound to UI with filtered range
    filterPage();
  }

  /// call this when total count is no changed.
  filterPage() {
    var from = (currentpage - 1) * pagesize;
    var to = from + pagesize;

    _filteredRows = _dataRowsAux.where((row) {
      bool result = true;
      searchMap.forEach((searchedCol, searchVal) {
        var colVal = row.value[searchedCol];
        if (colVal is bool)
          result = result && colVal == searchVal;
        else
          result = result && colVal.toString().toLowerCase()
          .contains(searchVal.toString().toLowerCase());
      });
      return result;
    }).toList();

    itemCount = _filteredRows.length;
    pageCount = ( itemCount / pagesize ).ceil();

    if (currentpage == pageCount) {
      lastItemIndex = itemCount;
    } else {
      lastItemIndex = (currentpage) * pagesize;
    }


    if (sortedColumn != null) {
      _filteredRows.sort((rowA, rowB) =>
      descending
      ? rowA.value[sortedColumn].compareTo(rowB.value[sortedColumn])
      : rowB.value[sortedColumn].compareTo(rowA.value[sortedColumn]));
    }

    var _viewingRows;

    if (_filteredRows.length > to)
      _viewingRows = _filteredRows.getRange(from, to);
    else
      _viewingRows = _filteredRows.getRange(from, _filteredRows.length);

    viewingRows = toObservable(_viewingRows);

    selectedRowsChanged();
  }

  //data manipulation//

  handleTdClick(e) {
    var column = nodeBind(e.target).templateInstance.model['column'];
    var row = nodeBind(e.target).templateInstance.model['row'];
    var detail = {"row" : row, "column" : column};
    if (column.editable) {
      edited(e);
    }
    fire('after-td-click', detail: detail);
  }

  handleTdDblClick(e, p) {
    var column = nodeBind(e.target).templateInstance.model['column'];
    var row = nodeBind(e.target).templateInstance.model['row'];
    var detail = {"row" : row, "column" : column};
    fire('after-td-dbclick', detail: detail);
  }

  @observable bool allSelected;

  select(e) {
    if (selectable) {
      AhaRow row = nodeBind(e.target).templateInstance.model['row'];
      if (selectedRows.contains(row.value)) {
        selectedRows.remove(row.value);
        row.selected = false;
      } else {
        selectedRows.add(row.value);
        row.selected = true;
      }
    }
  }

  selectall(e) {
    selectedRows.clear();
    if (e.target.checked) {
      viewingRows.forEach((vr) { 
        vr.selected = true;
        selectedRows.add(vr.value);
      });
    } else {
      viewingRows.forEach((vr) => vr.selected = false);
    }
  }

  selectedRowsChanged() {
    allSelected = viewingRows.fold(true, (_allSelected, row) {
      return _allSelected && row.selected;
    });
  }

  create(obj) {
    fire('before-create', detail: obj);
    var _default = {'_editing': true, '_modified': true};
    var _new = obj != null ? obj : _default;
    meta.forEach((column) {
      if (column.defaultVal && _new[column.name] == null) {
        _new[column.name] = column.defaultVal;
      }
    });
    dataRows.insert(0, _new);
    modifiedRows.add(_new);
    fire('after-create', detail: _new);
  }

  copyRow(e, detail, sender) {
    AhaRow row = nodeBind(e.target).templateInstance.model['row'];
    fire('before-copy', detail: row);
    var _new = toObservable(new Map.from(row.value));
    if (_new['id'] != null) {
      _new['id'] = null;
    }
    dataRows.insert(row.index, _new);
    modifiedRows.add(_new);
    fire('after-copy', detail: _new);
  }

  removeRow(e, detail, target) {
    AhaRow row = nodeBind(target).templateInstance.model['row'];
    fire('before-remove', detail: row);
    if (dataRows.remove(row.value)) {
      deleted.add(row.value);
    }
    fire('after-remove', detail: row);
  }

  toggleFilters() {
    searchable = !searchable;
    searchMap.clear();
    filterPage();
  }

}