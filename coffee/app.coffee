window.BizzBuzzApp = exports? and exports or window.BizzBuzzApp = {}

$ ->
  class Coordinate
    constructor: (@coordStr) ->
      @coordinates = null
    
    getCoordinates: ->
      return @coordinates unless @coordinates is null
      tmpCoords = @coordStr.split(",")
      return @coordinates = tmpCoords if tmpCoords.length > 4
      @coordinates = @handleTwoPointers(tmpCoords)
  
    handleTwoPointers: (coords) ->
      return coords unless coords.length is 4
      x1 = coords[0]
      y1 = coords[1]
      x2 = coords[2]
      y2 = coords[3]
      return [x1,y1,x2,y1,x2,y2,x1,y2]
    
    getXs: ->
      coords = @getCoordinates()
      xs = []
      xs.push c for c in coords by 2
      xs
      
    getYs: ->
      coords = @getCoordinates()
      ys = []
      for c,i in coords by 2
        ys.push coords[i+1]
      ys
      
    getMaxY: ->
      Math.max.apply Math, @getYs()
      
    getMinY: ->
      Math.min.apply Math, @getYs()
    
    getMaxX: ->
      Math.max.apply Math, @getXs()
      
    getMinX: ->
      Math.min.apply Math, @getXs()
  
  class Page
    constructor: (@url, @coordinates) ->
      console.log "running ...."
    currentPanelIdx: 0
    getCurrentPanel: ->
      @coordinates[@currentPanelIdx]
      
    getNextPanel: ->
      @currentPanelIdx++ if @currentPanelIdx < @coordinates.length-1
      @getCurrentPanel()
    getPreviousPanel: ->
      @currentPanelIdx-- if @currentPanelIdx > 0
      @getCurrentPanel()
  
  class PageManagerOld
    instance = null
    currentPage = 0
    maxPage = 0
  
    @init = () ->
      console.log "init PM..."
  
    @getInstance = () ->
      instance ?= @init()
    
    @setPage = (pageObj) ->
      maxPage = pageObj.pages.length or 0
      console.log "maxPage", maxPage

  class BookManager
    constructor: (@bookObj) ->
      console.log "init PM"
      @setBook(@bookObj)
    setBook: (@bookObj) ->
      @pages = @bookObj.pages
      @currentPageIdx = 0
    currentPageIdx: 0,
    getMaxPage: ->
      @bookObj.pages.length
    getCurrentPage: ->
      @pages[@currentPageIdx]
    getNextPage: ->
      @currentPageIdx++ if @currentPageIdx < @getMaxPage()-1
      @getCurrentPage()
    getPreviousPage: ->
      @currentPageIdx-- if @currentPageIdx > 0
      @getCurrentPage()
      
  
  class ProjectorHelper
    instance = null
    projectorWidth = 0
    projectorHeight = 0
    pageWidth = 0
    pageHeight = 0
    pageCoordinates = []
    projectorCoordinates = []
  
    @init = (projectorWidth, projectorHeight, pageWidth, pageHeight, pageCoordinates) ->
      console.log "init ProjectorHelper"
  
    @getInstance = (projectorWidth, projectorHeight, pageWidth, pageHeight, pageCoordinates) ->
      return instance unless instance is null
      instance = @init(projectorWidth, projectorHeight, pageWidth, pageHeight, pageCoordinates)
  
    @getProjectorCoordinates: ->
      return projectorCoordinates unless projectorCoordinates.length is 0
  
  #c = new Coordinate("1,2,3,4").getCoordinates()
  #console.log c
  #p = new Page()
  
  bookObj =
    title: "Some Title",
    writer: "A Writer",
    illustrator: "An Illustrator",
    pages: [
      new Page("https://cde6dc9e64e2615158334e81fa60a42a7025dcd4.googledrive.com/host/0B55OYxnBow_9ZE1FRnJCdXNheXc/bizzbuzztest1.png", [
        new Coordinate "244,4,256,88,-4,38,24,10,98,6"
        new Coordinate "268,176,4,174,10,48,256,110,258,114"
        new Coordinate "8,192,116,188,156,300,-6,282"
        new Coordinate "254,202,274,316,168,310,144,184"])
        
      new Page("https://cde6dc9e64e2615158334e81fa60a42a7025dcd4.googledrive.com/host/0B55OYxnBow_9ZE1FRnJCdXNheXc/bizzbuzztest2.jpg", [
        new Coordinate "11,12,13,14"])
        
      new Page("https://cde6dc9e64e2615158334e81fa60a42a7025dcd4.googledrive.com/host/0B55OYxnBow_9ZE1FRnJCdXNheXc/bizzbuzztest3.jpg", [
        new Coordinate "10,10,10,10"])
    ]
  
  bm = new BookManager(bookObj)
  console.log bm.getMaxPage()
  console.log bm.getCurrentPage().getCurrentPanel().getCoordinates()
  console.log bm.getCurrentPage().getCurrentPanel().getMaxX()
  console.log bm.getCurrentPage().getCurrentPanel().getMinX()
  console.log bm.getCurrentPage().getCurrentPanel().getMaxY()
  console.log bm.getCurrentPage().getCurrentPanel().getMinY()


  
  # ph = ProjectorHelper.getInstance(1,1,1,1,[1,2,3,4])
  
  $("#info").append "mooo"
  
  window.BizzBuzzApp =
    Coordinate: Coordinate
    Page: Page
    BookManager: BookManager
    ProjectorHelper: ProjectorHelper

