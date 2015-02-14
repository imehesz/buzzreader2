$(function(){
  var DEBUG = true;
  
  class QuickTest {
    constructor() {
      this.cnt = 0;
    }
    eq(msg = "Testing...", one,two) {
      this.cnt++;
      var OK = "[OK]";
      var FAIL = "[F A I L!]";
      
      one == two ? 
        console.info(this.cnt + ". " + OK, " --- ", msg) : 
        console.warn(this.cnt + ". " + FAIL, " --- ", msg, one, "vs", two);
    }
  }
  
  /**
   * Coordinate - handles all the coordinates related tasks
   */
  class Coordinate {
    constructor (coordinateStr) {
      this.coordinateStr = coordinateStr;
      this.coordinates = null;
    }
    
    /**
     * returns coordinates, also calls 2 point handler if needed
     * @return Array of Numbers
     */
    getCoordinates() {
      if (this.coordinates != null) {
        return this.coordinates;
      }
      
      var tmpCoords = this.coordinateStr.split(",");
      if (tmpCoords.length > 4) {
        this.coordinates = tmpCoords;
      } else {
        this.coordinates = this.handleTwoPointers(tmpCoords);
      }
      
      return this.coordinates;
    }
    
    /**
     * converts coordinates array to array of objects
     * return Array of Objects
     */
    getCoordinateObjects () {
      var xs = this.xs();
      var ys = this.ys();
      var retArr = [];
      
      for(let i=0; i<xs.length;i++) {
        retArr.push({
          x: xs[i], y: ys[i]
        });
      }
      
      return retArr;
    }
    
    /**
     * handles 2 point coordinates (old school BizzBuzz slicing)
     * @return Array of Numbers (4 point coordinates)
     */
    handleTwoPointers (coords) {
      if (coords.length > 4) return coords;
      
      var x1 = coords[0];
      var y1 = coords[1];
      var x2 = coords[2];
      var y2 = coords[3];
      return [x1,y1,x2,y1,x2,y2,x1,y2]
    }
    
    /**
     * gets all the X coordinates
     * @return Array of Numbers
     */
    xs () {
      var xs = [];
      var coords = this.getCoordinates();
      
      for (let i=0; i<coords.length; i+=2) {
        xs.push(coords[i]);
      }
      
      return xs;
    }
    
    /**
     * gets all the Y coordinates
     * @return Array of Numbers
     */
    ys () {
      var ys = [];
      var coords = this.getCoordinates();
      
      for (let i=1;i<coords.length; i+=2) {
        ys.push(coords[i]);
      }
      
      return ys;
    }
    
    /**
     * gets the max value from the Y coordinates
     * @return Number
     */
    maxY () {
      Math.max.apply(Math, this.ys());
    }
    
    /**
     * gets the min value from the Y coordinates
     * @return Number
     */
    minY () {
      Math.min.apply(Math, this.ys());
    }
    
    /**
     * gets the max value from the X coordinates
     * @return Number
     */
    maxX () {
      Math.max.apply(Math, this.xs());
    }
    
    /**
     * gets the min value from the X coordinates
     * @return Number
     */
    minX () {
      Math.min.apply(Math, this.xs());
    }
  }
  
  
  class Page {
    constructor (url, coordinates) {
      this.url = url;
      this.coordinates = coordinates;
      this.currentPanelIdx = 0;
    }
    
    getPanelIndex () {
      return this.currentPanelIdx;
    }
    
    setPanelIndex (idx) {
      this.currentPanelIdx = idx;
    }
    
    getPanelCount () {
      return this.coordinates.length;
    }
    
    getCurrentPanel () {
      return this.coordinates[this.getPanelIndex()];
    }
    
    getNextPanel () {
      if (!this.isLastPanel()) this.setPanelIndex(this.getPanelIndex()+1);
      return this.getCurrentPanel();
    }
    
    getPreviousPanel () {
      if (!this.isFirstPanel()) this.setPanelIndex(this.getPanelIndex()-1);
      return this.getCurrentPanel();
    }
    
    isLastPanel () {
      return this.getPanelIndex() == this.getPanelCount()-1;  
    }
    
    isFirstPanel () {
      return this.getPanelIndex() == 0;
    }
    
  }
  
  class BookManager {
    constructor (bookObj) {
      this.setBook(bookObj);
      this.PAGE_VIEW = 1;
      this.PANEL_VIEW = 2;
      this.viewLevel = this.PANEL_VIEW;
      this.currentPageIdx = 0;
    }
    
    getViewLevel () {
      return this.viewLevel;
    }
    
    setViewLevel (level) {
      this.viewLevel = level;
    }
    
    getBook () {
      return this.bookObj;  
    }
    
    setBook (bookObj) {
      this.pages = bookObj.pages;
      this.bookObj = bookObj;
      this.currentPageIdx = 0;
    }
    
    getMaxPage () {
      return this.getBook().pages.length;
    }
    
    getCurrentPage (cb, scope) {
      console.log("Loading image: " + this.pages[this.currentPageIdx].url);
      var page = this.pages[this.currentPageIdx];
      var image = new Image();
      image.src = this.pages[this.currentPageIdx].url;
      image.onload = function(e) {
        page.width = this.width
        page.height = this.height
        if(typeof cb == "function") cb.apply(scope);
      }
      
      return page;
    }
    
    getNextPage (cb, scope) {
      if (!this.isLastPage()) this.currentPageIdx++;
      return this.getCurrentPage(cb, scope, 0);
    }
    
    getPreviousPage (cb, scope) {
      if (!this.isFirstPage()) this.currentPageIdx--;
      return this.getCurrentPage(cb, scope, this.pages[this.currentPageIdx].coordinates.length);
    }
    
    isLastPage () {
      return this.currentPageIdx == this.getMaxPage()-1;
    }
    
    isFirstPage () {
      return this.currentPageIdx == 0;
    }
  }
  
  // in DEBUG mode we run some tests
  if (DEBUG) {
    var book = {
      title: "Some Title",
      writer: "A Writer",
      illustrator: "An Illustrator",
      pages: [
        new Page("https://5590b350b8e8612362e86b9426c7815b2a13a98a.googledrive.com/host/0B55OYxnBow_9UG5HbW1fWGhkR2c/bizzbuzzpaneltest.png", [
          new Coordinate("10,9,114,118"),
          new Coordinate("12,125,114,175"),
          new Coordinate("130,9,236,175"),
          new Coordinate("12,188,236,251"),
          new Coordinate("20,284,10,304,10,334,25,354,65,371,100,355,121,326,112,281,81,261,29,266,22,277,22,277,14,287,14,287,26,273"),
          new Coordinate("172,284,140,305,131,345,140,360,149,365,142,385,146,399,194,400,213,375,202,345,230,328,238,296,211,267,173,276"),
          new Coordinate("9,427,13,481,234,486,230,485"),
          new Coordinate("13,406,230,474,229,407")
        ]),
        
        new Page("http://i.imgur.com/uf7miIB.jpg",[
          new Coordinate("34,32,460,786"),
          new Coordinate("506,50,984,142"),
          new Coordinate("512,174,666,178,678,278,698,310,828,320,824,414,642,418,614,664,486,658,500,172"),
          new Coordinate("716,146,998,144,996,782,906,640,842,644,774,672,762,752,642,742,650,562,700,474,798,442,834,368,810,312,716,302"),
          new Coordinate("462,668,644,664,650,750,764,766,776,672,838,642,892,688,918,772,938,824,634,824,634,872,458,868")
        ])
      ]
    }
    
    var bm = new BookManager(book);
    var page = book.pages[0];
  
    var qt = new QuickTest();
    
    // page test
    qt.eq("page.isFirstPanel() should be `true`", page.isFirstPanel(),true);
    qt.eq("page.isLastPanelPanel() should be `false`", page.isLastPanel(), false);
    page.getNextPanel();
    qt.eq("after `next` page.isFirstPanel() should be `false`", page.isFirstPanel(), false);
    
    // book test
    qt.eq("viewLevel should be same as PANEL_VIEW", bm.getViewLevel(), bm.PANEL_VIEW);
    qt.eq("currentPageIdx should be 0", bm.currentPageIdx, 0);
    qt.eq("getMaxPage should be 2", bm.getMaxPage(), 2);
    qt.eq("isFirstPage should be true", bm.isFirstPage(), true);
    qt.eq("isLastPage should be false", bm.isLastPage(), false);
    bm.getNextPage();
    qt.eq("after nextPage isLastPage should be true", bm.isLastPage(), true);
  }
});