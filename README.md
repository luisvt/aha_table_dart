aha_table_dart
==============

> A port of aha-table to dart

A Polymer element for a searchable, sortable, paginatable, inline-editable, selectable, copyable, removable, movable table/grid.

## Usage

```html
<link rel="import" href="packages/aha_table/aha_table/aha_table.html">
```

Start using it!

```html
<aha-table
      selectable
      copyable
      removable
      movable
      seachable
      pagesize="20" 
      pagesizetitle="Page Size:" 
      summarytitle="Viewing">

      <aha-column name="title" 
          type="string" 
          sortable
          searchable
          required
          placeholder="Empty Field Placeholder Text" 
          default="" 
          hint="a hint in column header">
      </aha-column>
 </aha-table>
```

## &lt;aha-table&gt;

### Options

Attribute       | Options       | Default   | Description
---             | ---           | ---       | ---
`data`          | *Array*       | []        | data for this table, need to set in JS.
`selectable`    | *Boolean*     | False     | if selection box is displayed
`searchable`    | *Boolean*     | False      | if search row is displayed
`copyable`      | *Boolean*     | False      | if copy handler is displayed
`removable`     | *Boolean*     | False      | if remove handler is displayed
`movable`       | *Boolean*     | False      | if move up/down handler is displayed
`pagesize`      | *Number*      | 10        | record set size for each page
`data-sizelist` | *Array*       | [5, 10, 20, 50, 100]      | list for page size dropdown
`selecttitle`   | *String*      | undefined | title for select checkbox
`selectalltitle`| *String*      | undefined | title for selectall checkbox
`copytitle`     | *String*      | undefined | title for copy indicator
`removetitle`   | *String*      | undefined | title for remove indicator
`movedowntitle` | *String*      | undefined | title for move down indicator
`moveuptitle`   | *String*      | undefined | title for move up indicator
`sorttitle`     | *String*      | undefined | title for sortable column
`edittitle`     | *String*      | undefined | title for editable data cell
`searchtitle`   | *String*      | undefined | title for search filter row toggler
`firsttitle`    | *String*      | undefined | title for first page clicker
`previoustitle` | *String*      | undefined | title for previous page clicker
`nexttitle`     | *String*      | undefined | title for next page clicker
`lasttitle`     | *String*      | undefined | title for last page clicker
`pagetext`      | *String*      | undefined | text before current page number
`pageoftext`    | *String*      | undefined | text between page range and total page number
`pagesizetext`  | *String*      | undefined | text before page size dropdown
`summarytitle`  | *String*      | undefined | text before pagination summary
`itemoftext`    | *String*      | undefined | text between item count range and total item number


## Events

Name                    | Arguments | Description
---                     | ---       | ---
`after-invalid`         | `Event`   | call after saving a cell by it's invalid
`after-td-click`        | `Event`   | call after user click a cell, usually after this cell is editable
`after-td-dbclick`      | `Event`   | call after user dbclick a cell
`before-create`         | `Event`   | call before a record is created internally
`after-create`          | `Event`   | call after a record is created internally
`before-copy`           | `Event`   | call before a record is copyed from another internally
`after-copy`            | `Event`   | call after a record is copyed from another internally
`before-remove`         | `Event`   | call before a record is removed internally
`after-remove`          | `Event`   | call after a record is removed internally
`before-move-down`      | `Event`   | call before a record is moved down
`after-move-down`       | `Event`   | call after a record is moved down
`before-move-up`        | `Event`   | call before a record is moved up
`after-move-up`         | `Event`   | call after a record is moved up


## &lt;aha-column&gt;

Provides you a declarative way to define column meta.

### Options

Attribute           | Options                   | Default               | Description
---                 | ---                       | ---                   | ---
`name`              | *String*                  | undefined             | name of the column
`label`             | *String*                  | undefined             | this text woll be displayed as the column name in table header.
`type`              | *String*                  | undefined             | one of: string, text, choice, boolean, date, time, datetime
`sortable`          | *bool*                    | False                  | if this column is sortable
`searchable`        | *bool*                    | False                  | if this column is searchable
`editable`          | *bool*                    | False                  | if this column is editable
`required`          | *bool*                    | False                  | if this column is required, Event 'after-invalid' will be invoked
`placeholder`       | *String*                  | undefined             | this text will be displayed when this cell is empty
`default`           | *String*                  | undefined             | default value, applied at creation
`data-choices`      | *Map*                     | {}                    | options for select dropdown, in editing and searching.
`hint`              | *String*                  | undefined             | this text will be displayed at the column header for instruction.
`searchplaceholder` | *String*                  | undefined             | this text will be displayed in search filter input box.

## Browser Compatability

![IE](https://raw.github.com/paulirish/browser-logos/master/internet-explorer/internet-explorer_48x48.png) | ![Chrome](https://raw.github.com/paulirish/browser-logos/master/chrome/chrome_48x48.png) | ![Firefox](https://raw.github.com/paulirish/browser-logos/master/firefox/firefox_48x48.png) | ![Opera](https://raw.github.com/paulirish/browser-logos/master/opera/opera_48x48.png) | ![Safari](https://raw.github.com/paulirish/browser-logos/master/safari/safari_48x48.png)
--- | --- | --- | --- | --- |
IE 10+ ✔ | Latest ✔ | Latest ✔ | Latest ✔ | Latest ✔ |

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

For detailed changelog, check [Releases](https://github.com/liuwenchao/aha-table/releases).

## License

[MIT License](http://opensource.org/licenses/MIT)

