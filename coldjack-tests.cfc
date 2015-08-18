
component hint="runs some MXUnit Tests on the coldjack component" output="false" extends="mxunit.framework.testcase" {

  public void function testReadSimpleDb(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    q = coldjack.readTable(db, "People");
    assertEquals(1,q.recordCount,"should get back one row");
    assertEquals("Bill",q.firstName);
    assertEquals(1,q.subscribe);
  }

  public void function testReadMoreComplexDb(){
    // not much more complex; but does have a computed column in it
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    q = coldjack.readTable(db, "ComputedPeople");
    assertEquals(1,q.recordCount,"should get back one row");
    assertEquals("Bill",q.firstName);
    assertEquals(1,q.subscribe);
    assertEquals(42,q.DoubleAge);
  }

  public void function testReadWithColumnMap(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    colMap = {"FirstName":"PersonName","Bio":"Biography"};

    q = coldjack.readTable(db, "People",colMap);

    assertTrue(ListFindNoCase(q.columnList,"FirstName") EQ 0); // first name is gone
    assertEquals("Bill",q.personName); //replaced by PersonName

    // bio in the db is a "memo" so it has some built in formatting which is
    // where the <div> comes from
    expectedBio = "<div>a long time ago in a galaxy far far away</div>";

    assertEquals(expectedBio,q.biography);
  }

  public void function testBadDbPath(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\db\non-existantDb.accdb";
    try{
      q = coldjack.readTable(db, "BogusTableName");
      fail("the table BogusTableName doesnt exist and this shouldnt have worked");
    } catch( any e){
      assertEquals("ColdJack-Missing DB File", e.type);
    }
  }

  public void function testBadTableName(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    try{
      q = coldjack.readTable(db, "BogusTableName");
      fail("the table BogusTableName doesnt exist and this shouldnt have worked");
    } catch( any e){
      assertEquals("ColdJack-BadTable", e.type);
    }
  }

  public void function testUnsupportedAccessColumnType(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    try{
      q = coldjack.readTable(db, "BadPeople");
      fail("the attachment column isn't supported so this table shouldn't work");
    } catch( any e){
      assertEquals("ColdJack-Unsupported ColumnType", e.type);
    }
  }



}
