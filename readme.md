# Purpose

This is a very simple coldfusion component wrapper for the java jackcess library.
currently this wrapper can do one thing - it can read a database table and return
the contents as a cf query object.  


# Installation
you do need to [download jacksess from sourceforge](http://jackcess.sourceforge.net/).
Once you've downloaded the library put it in your Coldfusion servers java class path
and then restart Coldfusion server.  Your java class path for CF is, by default at
{coldfusion_install_home}/cfusion/lib/

You put the jar file in that directory, restart CF, and you'll be good to go.

Finally, just put the coldjack component wheverer you need it and look at the Usage
below.

# Usage

```cfm
coldjack = createObject("component", "coldjack");
db = getDirectoryFromPath("{full_path_to_the_database}");
q = coldjack.readTable(db, tableName);
```

So, let's say you have an acccess database in the same directory as your calling
code and you want to read the "account" table of the database you could do this:

```cfm
coldjack = createObject("component", "coldjack");
db = getDirectoryFromPath(getCurrentTemplatePath()) & "\my_acccess_db.accdb";
q = coldjack.readTable(db, "account");
```

## Advanced Usage
There is one little extra bit that the `readTable` method can do and that is you can map column names from the access database table into different column names in the cfquery object. To do so you need to pass in the optional third argument of `colMap` which is a cf structure organized with the access column name as a key and the desired query column name as the value.  Like so:

```cfm
myColumnMap = {"ProductIdNumber":"ProductId","MediaId":"PublicationId"}
coldjack = createObject("component", "coldjack");
db = getDirectoryFromPath(getCurrentTemplatePath()) & "\my_acccess_db.accdb";
q = coldjack.readTable(db, "product", myColumnMap);
```

By passing in the column map now the resultant query will have a column called "productId" and another called "PublicationId" instead of the original column names of "ProductIdNumber" and "MediaId".

If you were to do a dump on the query object without using the column map you'd see this:

<table>
  <thead>
    <tr style="background: #AA66AA;">
      <th colspan="5">query</th>
    </tr>
    <tr bgcolor="#eeaaaa">
      <th style="background: #FFDDFF; color: black;">ProductIdNumber</th>
      <th style="background: #FFDDFF; color: black;">MediaId</th>
      <th style="background: #FFDDFF; color: black;">Title</th>
      <th style="background: #FFDDFF; color: black;">Author</th>
      <th style="background: #FFDDFF; color: black;">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background: white; color: black;">
      <td>123</td>
      <td>9</td>
      <td>ColdJack - The Basics</td>
      <td>Bill Rawlinson</td>
      <td>A barely useful document on using ColdJack</td>
    </tr>
  </tbody>
</table>

However, with the `colMap` provided you would get this result:

<table>
  <thead>
    <tr style="background: #AA66AA;">
      <th colspan="5">query</th>
    </tr>
    <tr bgcolor="#eeaaaa">
      <th style="background: #FFDDFF; color: black;">ProductId</th>
      <th style="background: #FFDDFF; color: black;">PublicationId</th>
      <th style="background: #FFDDFF; color: black;">Title</th>
      <th style="background: #FFDDFF; color: black;">Author</th>
      <th style="background: #FFDDFF; color: black;">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background: white; color: black;">
      <td>123</td>
      <td>9</td>
      <td>ColdJack - The Basics</td>
      <td>Bill Rawlinson</td>
      <td>A barely useful document on using ColdJack</td>
    </tr>
  </tbody>
</table>

I personally find the `colMap` useful for scenarios where I am importing the access data into a different database and the access database that I was given to import has poor column names that don't really reflect the data very well.


# Exception Handling
I'm not really sure what the best practice is for defining custom exceptions in CF but I sort of name-spaced mine using the "type" attribute.  There are a few exceptions that coldjack can throw and each has it's own custom type:

### ColdJack-Missing DB File
If you pass in an invalid path to the access database

### ColdJack-BadTable
If you ask for the contents of a table that doesn't exist in the database

### ColdJack-Unsupported ColumnType
If the access database contains data types that coldfusion query objects can't support.

#### Supported Datatypes

| MS Access Column Type | CF Column Type  |
| --------------------- | --------------- |
| AUTONUMBER  | CF_SQL_INTEGER |
| NUMBER | CF_SQL_BIGINT |
| CURRENCY | CF_SQL_DECIMAL |
| DATE/TIME | CF_SQL_TIMESTAMP |
| YES/NO  | CF_SQL_BINARY |
| MEMO | CF_SQL_VARCHAR |
| HYPERLINK | CF_SQL_VARCHAR |
| CALCULATED  | CF_SQL_DECIMAL |
| ATTACHMENT | **UNSUPPORTED** |
| OLE OBJECT | **UNSUPPORTED** |
| LOOKUP WIZARD | **UNSUPPORTED** |


To be honest, this part needs to be tested a bit more becuase these are my best guess understandings and are not all guaranteed yet.  It might even be possible to support the last three but there is, at the moment, no direct correlation.
