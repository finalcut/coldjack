# Purpose

This is a very simple coldfusion component wrapper for the java jacksess library.
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
code and you want to read the "account" table of hte database you could do this:

```cfm
coldjack = createObject("component", "coldjack");
db = getDirectoryFromPath(getCurrentTemplatePath()) & "\my_acccess_db.accdb";
q = coldjack.readTable(db, "account");
```

# Exception Handling
There are a few exceptions that coldjack can throw and each has it's own custom type:

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
