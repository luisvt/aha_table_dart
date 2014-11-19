import 'package:polymer/polymer.dart';
import 'dart:convert';
import 'package:template_binding/template_binding.dart';

@CustomTag('aha-table')
class AhaTable extends PolymerElement {
  
  AhaTable.created() : super.created();

    //data: instance of the model data
    @published List data = [];
    //meta: instance of the model meta
    @published List meta = [];
    /**
     * modified: all created or modified row will be referenced here.
     * it's hard to determine if it's created or modified after multiple
     * operations, because the element doesn't assume there's an id column,
     * so you need to determine if by yourself, like check
     * if the id exists if your model has an id column.
     */
    @published List modified = [];
    //deleted: all deleted row will be moved here.
    @published List deleted = [];
    //selected: all selected row will be referenced here.
    @published List selected = [];
    //all visiable rows are reference here.
    @published List viewingRow = []; 
    //selectable: if table row is selectable
    @published bool selectable = false;
    //copyable: if table row is copyable
    @published bool copyable = false;
    //removable: if table row is removable
    @published bool removable = false;
    //searchable: if table row is searchable
    @published bool searchable = false;
    // text displayed in first column of search row.
    @published String searchtitle = "";
    // text displayed as title of select checkbox.
    @published String selecttitle = "";
    // text displayed as title of selectall checkbox.
    @published String selectalltitle = "";
    // text displayed as title of sorting column.
    @published String sorttitle = "";
    // text displayed as title of column name.
    @published String columntitle = "";
    // text displayed as title of copy indicator.
    @published String copytitle = "";
    // text displayed as title of remove checkbox..
    @published String removetitle = "";
    // text displayed as title of editable cell.
    @published String edittitle = "";
    //sortedColumn: sorted column name
    @published String sortedColumn = "";
    //editingRow: current editing row
    //@type {Object}
    @published Map editingRow = null;
    //if filtering has been performed.
    @published bool filtered = false;
    //editingRow: current rows in display/view
    @published List viewingRows = [];
    //descending: current sorting order
    @published bool descending = false;
    //pagesize: the number of items to show per page
    @published int pagesize = 10;
    //currentpage: the current active page in view
    @published int currentpage = 0;
    //pageCount: the number of paginated pages
    @published int pageCount = 0;
    //itemCount: the number of visible items
    @published int itemCount = 0;
    //firstItemIndex: the index number of first item in the page, start from 1
    @published int firstItemIndex = 1;
    //lastItemIndex: the index number of last item in the page, start from 1
    @published int lastItemIndex = 1;
    //sizelist: range list to adjust page size.
    @published List sizelist = [5, 10, 20, 50, 100];
    //previous: label for the Previous button
    @published String previous = "<";
    //next: label for the Next button
    @published String next = ">";
    //first: label for the First page button
    @published String first = "<<";
    //last: label for the Last page button
    @published String last = ">>";
    //pagesizetitle: label for page size box
    @published String pagesizetitle = "";
    //summarytitle: label for table summary area
    @published String summarytitle = "";
    @published String firsttitle, 
            nexttitle,
            previoustitle, 
            lasttitle,
            pagetext, 
            pageoftext, 
            pagesizetext, 
            summarytext, 
            itemoftext;

    ready() {
//      var children = this.children || this.impl.children;
//      if (children.length) {
//        this.meta = children.array();
//      }
//      if (this.dataset.sizelist) {
//        this.sizelist = JSON.parse(this.dataset.sizelist);
//      }
      //Show element when it's ready.
      $['aha_table_main'].setAttribute('resolved', '');
      $['aha_table_main'].removeAttribute('unresolved');

      this.currentpage = 1;
    }

     //=========
    //internal methods
    dataChanged() {
      if (this.meta.length == 0)  {
        $['aha_table_main'].setAttribute('unresolved', '');
        // generate meta from data if meta is not provided from aha-column.
        this.meta = [];
        for (var prop in this.data[0]) {
          if (prop.indexOf('_') != 0) {//skip internal field
            this.meta.add({
              'name': prop,
              'label': prop.charAt(0).toUpperCase() + prop.slice(1), 
              'type': [true, false].indexOf(this.data[0][prop]) > -1 ? "boolean" : "string", 
              'sortable': true, 
              'searchable': true, 
              'editable': true, 
              'required': false
            });
          }
        }
        $['aha_table_main'].setAttribute('resolved', '');
        $['aha_table_main'].removeAttribute('unresolved');
      }
      this.refreshPagination(true);
    }

    modifiedChanged() {}

    //translate value to labels for select
    _translate(value, options, blank){
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
      if (value is! String || value.length == 0) 
        return value;
      return value.charAt(0).toUpperCase() + value.slice(1);
    }

    edited(e) {
      var row = nodeBind(e.target).templateInstance.model['row'];
      row._editing = true;
      if (this.editingRow != null && this.editingRow != row) {
        this.editingRow['_editing'] = false;
      }
      this.editingRow = row;
    }

    save(e) {
      var row    = nodeBind(e.target).templateInstance.model['row'];
      var column = nodeBind(e.target).templateInstance.model['column'];
      if(row){
        if ("CHECKBOX" == e.target.type.toUpperCase()) {
          row[column.name] = e.target.checked;
        } else {
          row[column.name] = e.target.value;
        }
        if (this.modified.indexOf(row) == -1) {
          row._modified = true;
          this.modified.add(row);
        }

        if (!e.relatedTarget 
          || !e.relatedTarget.templateInstance
          || e.relatedTarget.templateInstance.model.row != nodeBind(e.target).templateInstance.model['row']) {
          row._editing = false;
        }

        if (column.required && !e.target.validity.valid) {
          this.fire('after-invalid', detail: {"event": e, "row" : row, "column" : column});
        }
      }
    }

    sort(e, p) {
      var column = nodeBind(e.target).templateInstance.model['column'];
      if(column && column.sortable){
        var sortingColumn = column.name;
        if (sortingColumn == this.sortedColumn){
          this.descending = !this.descending;
        } else {
          this.sortedColumn = sortingColumn;
        }
      }

      this.refreshPagination();
    }

    search(e, p) {
      if(nodeBind(e.target).templateInstance.model['column']){
        var searchedColumn = nodeBind(e.target).templateInstance.model['column'].name;
        this.data.forEach((row){
          var matched = false;
          row._not_matched_columns = row._not_matched_columns != null ? row._not_matched_columns : [];

          //checkbox will only filter checked rows.
          if ("CHECKBOX" == e.target.type.toUpperCase()) {
            matched = !e.target.checked || row[searchedColumn];
          } else if (
            // empty search means it always match
            e.target.value == "" 
            || 
            // non-empty search and the content matches.
            row[searchedColumn] 
            && row[searchedColumn].toString().indexOf(e.target.value.toString().toLowerCase()) > -1) {
            matched = true;
          }

          if (matched) {
            if (row._not_matched_columns.indexOf(searchedColumn) > -1) {
              // then we remove matched column from _not_matched_columns list.
              row._not_matched_columns.splice(row._not_matched_columns.indexOf(searchedColumn), 1);
            }
            // update _filtered state
            // true if there's other not-matched_column
            // false if all column matches.
            row._filtered = row._not_matched_columns.length > 0;
          } else {
            // Not matched!
            row._filtered = true;
            if (row._not_matched_columns.indexOf(searchedColumn) == -1) {
              row._not_matched_columns.add(searchedColumn);
            }
          }
        });

        this.filtered = this.data.any((row){return row._filtered;});

        this.refreshPagination();
      }
    }

     //============
    //pagination
    firstPage() {
      this.currentpage = 1;
    }

    prevPage() {
      if ( this.currentpage > 1 ) {
        this.currentpage--;
      }
    }

    nextPage() {
      if ( this.currentpage < this.pageCount ) {
        this.currentpage++;
      }
    }

    lastPage() {
      this.currentpage = this.pageCount;
    }

    currentpageChanged(){
//      this.currentpage = this.currentpage != null ? int.parse(this.currentpage) : 0;
      this.currentpage = this.currentpage < 1 ? 1 : this.currentpage;
      this.currentpage = this.pageCount > 0 && this.currentpage > this.pageCount ? this.pageCount : this.currentpage;
      this.filterPage();
      this.firstItemIndex = (this.currentpage-1) * this.pagesize+1;
      if (this.currentpage == this.pageCount) {
        this.lastItemIndex = this.itemCount;
      } else {
        this.lastItemIndex = (this.currentpage)* this.pagesize;
      }
    }

    pagesizeChanged(){
//      this.pagesize = parseInt(this.pagesize);
      this.refreshPagination();
    }

    // call this when total count is no changed.
    filterPage() {
      var from = (this.currentpage-1) * this.pagesize;
      var to   = from + this.pagesize;
      var filteredRows = this.filtered 
          ? this.data.where((r){return !r['_filtered'];})
          : this.data;
      if (this.sortedColumn != null) {
        // sorting map: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort#Sorting_maps
        var i = 0;
        filteredRows = 
        filteredRows
        .map((e){
          var v = e[this.sortedColumn];
          return {
            'index': i++, 
            'value': v is String ? v.toLowerCase() : v
          };
        })
        .sort((a, b) {
          return this.descending 
          ? (a.value < b.value ? 1 : -1)
          : (a.value > b.value ? 1 : -1);
        })
        .map((e){
          return filteredRows[e.index];
        });
      }
      this.viewingRows = filteredRows.getRange(from, to);
    }

    // call this when total count is change.
    refreshPagination([keepInTheCurentPage = false]) {
      if (!keepInTheCurentPage) {
        // Usually go to the first page is the best way to avoid chaos.
        this.currentpage = 1;
      }
      // Cache the total page count and item count
      var count = 0;
      this.data.forEach((row) {
        if (!row._filtered) {
          count++;
        }
      });
      this.itemCount = count;
      this.pageCount = ( count / this.pagesize ).ceil();

      // Update model bound to UI with filtered range
      this.filterPage();
    }

    //data manipulation//
    clicked(e) {
      var column = nodeBind(e.target).templateInstance.model['column'];
      var row = nodeBind(e.target).templateInstance.model['row'];
      var detail = {"row" : row, "column" : column};
      if (column.editable) {
        this.edited(e);
      }
      this.fire('after-td-click', detail: detail);
    }

    dbclick(e,p) {
      var column = nodeBind(e.target).templateInstance.model['column'];
      var row = nodeBind(e.target).templateInstance.model['row'];
      var detail = {"row" : row, "column" : column};
      this.fire('after-td-dbclick', detail: detail);
    }

    select(e,p){
      if (this.selectable) {
        var row = nodeBind(e.target).templateInstance.model['row'];
        var index = this.selected.indexOf(row);
        if (index > -1) {
          if(row._selected){
            this.selected.removeAt(index);
            row._selected = false;
          }
        } else {
          if(!row._selected){
            this.selected.add(row);
            row._selected = true;
          }
        }
        if (!row._editing) {
          e.preventDefault();
        }
      }
    }

    selectall(e,p){
      if(e.target.checked){
        this.viewingRows.forEach((row){
          if(this.selected.indexOf(row)==-1) {
            this.selected.add(row);
          }
          row._selected = true;
        });
      }else{
        this.data.forEach((row) {
          row._selected = false;
        });
      }
    }

    create(obj) {
      this.fire('before-create', detail: obj);
      var _default = {'_editing': true, '_modified': true};
      var _new = obj != null ? obj : _default;
      this.meta.forEach((column) {
        if (column.defaultVal && _new[column.name] == null) {
          _new[column.name] = column.defaultVal;
        }
      });
      this.data.insert(0,_new);
      this.modified.add(_new);
      this.fire('after-create', detail: _new);
    }

    copy(e, detail, sender) {
      var obj = nodeBind(e.target).templateInstance.model['row'];
      this.fire('before-copy', detail: obj);
      var _new = JSON.decode(JSON.encode(obj));
      if (_new.id) {
        _new.id = null;
      }
      if (_new._selected) {
        _new._selected = false;
      }
      _new._modified = true;
      _new._editing = false;
      this.data.insert(0,_new);
      this.modified.add(_new);
      this.fire('after-copy', detail: _new);
    }

    removed(e, detail, sender) {
      var obj = nodeBind(e.target).templateInstance.model['row'];
      this.fire('before-remove', detail:  obj);
      var found_index = this.data.indexOf(obj);
      if (found_index != -1) {
        this.data.removeAt(found_index);
        this.deleted.add(obj);
      }
      var found_index_in_modified = this.modified.indexOf(obj);
      if (found_index_in_modified != -1) {
        obj._modified = false;
        this.modified.removeAt(found_index_in_modified);
      }
      this.fire('after-remove', detail: obj);
    }

    toggleFilters() {
      this.searchable = !this.searchable;
    }

}