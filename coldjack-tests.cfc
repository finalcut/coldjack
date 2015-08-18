
component hint="runs some MXUnit Tests on the coldjack component" output="false" extends="mxunit.framework.testcase" {

  public void function testReadSimpleDb(){
    coldjack = createObject("component", "coldjack");
    db = getDirectoryFromPath(getCurrentTemplatePath()) & "\test.accdb";
    q = coldjack.readTable(db, "People");
    assertEquals(2,q.recordCount,"should get back one row");


    rownum = 1;
    assertEquals("Bill",q.firstName[rownum]);
    assertEquals(1,q.subscribe[rownum]);
    assertEquals(24332.21,q.salary[rownum]);
    // a hyperlink column wraps the value with pound signs.  Not sure why access does that.
    assertEquals("##http://google.com##",q.website[rownum]);



    rownum = 2;
    assertEquals("Ted",q.firstName[rownum]);
    assertEquals(0,q.subscribe[rownum]);
    assertEquals(92923.22,q.salary[rownum]);
    assertEquals("",q.website[rownum]);
    assertEquals("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, nibh. Quisque volutpat condimentum velit. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam nec ante. Sed lacinia, urna non tincidunt mattis, tortor neque adipiscing diam, a cursus ipsum ante quis turpis. Nulla facilisi. Ut fringilla. Suspendisse potenti. Nunc feugiat mi a tellus consequat imperdiet. Vestibulum sapien. Proin quam. Etiam ultrices. Suspendisse in justo eu magna luctus suscipit. Sed lectus. Integer euismod lacus luctus magna. Quisque cursus, metus vitae pharetra auctor, sem massa mattis sem, at interdum magna augue eget diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Morbi lacinia molestie dui. Praesent blandit dolor. Sed non quam. In vel mi sit amet augue congue elementum. Morbi in ipsum sit amet pede facilisis laoreet. Donec lacus nunc, viverra nec.",q.story[rownum]);

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

    //notice the third item in this mapping is a complex mapping; meaning the ChapterSection
    // column will be split into two columns Chapter and Section
    // this means each ChapterSection in the access database will be in the format Chapter.Section
    colMap = {"FirstName":"PersonName","Bio":"Biography","ChapterSection":"Chapter,Section|."};

    q = coldjack.readTable(db, "People",colMap);

    assertTrue(ListFindNoCase(q.columnList,"FirstName") EQ 0); // first name is gone
    assertEquals("Bill",q.personName); //replaced by PersonName

    // bio in the db is a "memo" so it has some built in formatting which is
    // where the <div> comes from
    expectedBio = "<div>a long time ago in a galaxy far far away</div>";

    assertEquals(expectedBio,q.biography);

    // special type of mapping where a column is split into multi columns on output:
    assertEquals("10",q.chapter[1]);
    assertEquals("24",q.section[1]);

    assertEquals("2",q.chapter[2]);
    assertEquals("9",q.section[2]);

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
