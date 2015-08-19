/**
* @output false
* @author Bill Rawlinson
* @date 18 Aug 2015
* @version 0.0.1
*/

component displayname="Cold Jack" hint="A CF wrapper around the Java Jackcess Library" {

  // simple constructor.. here for convention only
  public any function init(){
    return this;
  }

  /**
  * takes in three arguments:
  * @param dbPath required - the fully qualified path to the MS Access database file
  * @param tableName required - the case insensitive name of the table you want to read
  * @param colMap optional - a structure that defines the way you wan to rename columns
  *                          from the Access table to your CF table.  For example, if there
  *                          is a column in the access table called "ProductIdNumber" but
  *                          just want it called "ProductId" in the resultant cfquery object
  *                          you would pass in
  *
  *                          {"ProductIdNumber":"ProductId"}
  *
  *                          you can also do complex mappings where a single column in the source
  *                          can be split into multiple columns in the destination.  The source
  *                          column has to contain a delimiter and your mapping would define the
  *                          source the various destinations and the delimiter like this:
  *
  *                          {"source":"destination1,destination2,destination3|delimiter"}
  *
  *                          ex: {"MediaItem":"ChapterId,SectionId|."}
  *
  *                          This would split the MediaItem in the source and treat it like a period
  *                          delimited list.  The first item in the list would go into chapterId, the second
  *                          item would go into sectionid. If there are more items in the list they would
  *                          be lost.
  *
  * @return query - a coldfusion query object that contains the data from the requested table
  * @output false
  */
  public query function readTable(required string dbPath, required string tableName, struct colMap={} ){
    var finalQuery = "";
    try {
      builder = CreateObject("java", "com.healthmarketscience.jackcess.DatabaseBuilder");
    } catch (any e){
      throw (message="You need to install Jackcess in the Java Class Path of ColdFusion.", type="ColdJack-Missing Jackcess");
    }
    if(fileExists(arguments.dbPath)){
      dbFile = CreateObject("java", "java.io.File").init(arguments.dbPath);
      db = builder.open(dbFile);
      try {
        if(tableExists(db, arguments.tableName)){
          table = db.getTable(arguments.tableName);
          cursor = table.getDefaultCursor();
          accessColumns = table.getColumns();
          columnList = "";
          columnTypeList = "";

          for(col in accessColumns){
            columnName =col.getName();
            colName = columnName;
            if(structKeyExists(colMap,colName)){
              colName = colMap[colName];
            }
            if( (colName NEQ columnName) AND ListLen(colName,"|") GT 1){ // splitting a source into multiple columns!


              splitColumns = GetToken(colName,1, "|");

              for(idx=1;idx LTE ListLen(splitColumns);idx=idx+1){
                columnList = ListAppend(columnList, GetToken(splitColumns,idx,","));
                columnTypeList = ListAppend(columnTypeList, getCfColumnType(col.getType()));
              }

            } else {
              columnList = ListAppend(columnList, colName);
              columnTypeList = ListAppend(columnTypeList, getCfColumnType(col.getType()));
            }
          }

          finalQuery=QueryNew(columnList, columnTypeList);
          rowCount = table.getRowCount();
          //reset the cursor so we are sure to be in the right place
          cursor.beforeFirst();

          for(rowIndex=1;rowIndex LTE rowCount;rowIndex=rowIndex+1){
            queryAddRow(finalQuery);
            row=cursor.getNextRow();
            for(column in accessColumns){
              columnName = column.getName();
              colName = columnName;
              if(structKeyExists(colMap,colName)){
                colName = colMap[colName];
              }
              if(colName NEQ columnName AND ListLen(colName,"|") EQ 2){ // splitting a source into multiple columns!
                splitColumns = GetToken(colName,1, "|");
                delim = GetToken(colName,2,"|");
                originalValue = row.get(columnName);

                for(idx=1;idx LTE ListLen(splitColumns);idx=idx+1){
                  col = GetToken(splitColumns,idx,",");
                  if(listLen(originalValue,delim) GTE idx){
                    value = GetToken(originalValue, idx, delim);
                    querySetCell(finalQuery, col, value);
                  }
                }

              } else {
                value = row.get(columnName);
                querySetCell(finalQuery, colName, TRIM(row.get(columnName)));
              }
            }
          }

        } else {
          throw(message="Table #arguments.tablename# does not exist in the database.", type="ColdJack-BadTable");
        }

      } catch (any e){
        rethrow;
      } finally {
        db.close();
      }


    } else {
      throw(message="The database file you're trying to open, #arguments.dbPath# is invalid.  Make sure you provide the right absolute path.", type="ColdJack-Missing DB File");
    }

    return finalQuery;

  }

  private boolean function tableExists(any database, string tableName){
    tableNames = database.getTableNames();
    // we have a java.util.Set of string (tablenames) at this point.
    // so we use the built in contains method to see if our desired tablename
    // exists.

    // this is a NON-CASE sensitive comparison

    return tableNames.contains(tableName);

  }

  private string function getCfColumnType(required any accessDbType){
    switch(arguments.accessDbType){
      case "BINARY":
        return "CF_SQL_BINARY";
        break;
      case "BOOLEAN":
        return "CF_SQL_BIT";
        break;
      case "DOUBLE":
        return "CF_SQL_DECIMAL";
        break;
      case "FLOAT":
        return "CF_SQL_FLOAT";
        break;
      case "GUID":
        return "CF_SQL_VARCHAR";
        break;
      case "INT":
        return "CF_SQL_INTEGER";
        break;
      case "LONG":
        return "CF_SQL_INTEGER";
        break;
      case "MEMO":
        return "CF_SQL_VARCHAR";
        break;
      case "MONEY":
        return "CF_SQL_DECIMAL";
        break;
      case "NUMERIC":
        return "CF_SQL_BIGINT";
        break;
      case "SHORT_DATE_TIME":
        return "CF_SQL_TIMESTAMP";
        break;
      case "TEXT":
        return "CF_SQL_VARCHAR";
        break;
      default:
        throw(message="#arguments.accessdbType# is an unsupported type and can not be processed.", type="ColdJack-Unsupported ColumnType")
    }

  }

}
