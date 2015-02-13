$(function(){
  
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
  
  console.log(new Coordinate("10,9,114,118").getCoordinateObjects());
  
  var page = new Page("https://5590b350b8e8612362e86b9426c7815b2a13a98a.googledrive.com/host/0B55OYxnBow_9UG5HbW1fWGhkR2c/bizzbuzzpaneltest.png", [
        new Coordinate("10,9,114,118"),
        new Coordinate("12,125,114,175"),
        new Coordinate("130,9,236,175"),
        new Coordinate("12,188,236,251"),
        new Coordinate("20,284,10,304,10,334,25,354,65,371,100,355,121,326,112,281,81,261,29,266,22,277,22,277,14,287,14,287,26,273"),
        new Coordinate("172,284,140,305,131,345,140,360,149,365,142,385,146,399,194,400,213,375,202,345,230,328,238,296,211,267,173,276"),
        new Coordinate("9,427,13,481,234,486,230,485"),
        new Coordinate("13,406,230,474,229,407")
      ]);
      
  console.log("page.isFirstPanel() should be `true` - ", page.isFirstPanel() );
  console.log("page.isLastPanelPanel() should be `false` - ", page.isLastPanel() );
  
  page.getNextPanel();
  console.log("after `next` page.isFirstPanel() should be `false` - ", page.isFirstPanel());
});