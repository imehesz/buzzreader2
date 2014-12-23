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
  
  class Page
    constructor: (@url, @coordinates) ->
      console.log "running ...."
    currentPanelIdx: 0
    getCurrentPanel: ->
      console.log "getting current panel"
      @coordinates[@currentPanelIdx]
  
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
      @pages = @bookObj.pages
    setBook: (@bookObj) ->
    currentPageIdx: 0,
    getMaxPage: ->
      @bookObj.pages.length
    getCurrentPage: ->
      @pages[@currentPageIdx]
      
  
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
      new Page("https://b672919e56d941a2e7f4d07f63d3effaa6c3136c.googledrive.com/host/0B55OYxnBow_9bElhR3lSNVBGQXM/wearbg.jpg", [new Coordinate "10,10,10,10"])
    ]
  
  bm = new BookManager(bookObj)
  console.log bm.getMaxPage()
  console.log bm.getCurrentPage().getCurrentPanel().getCoordinates()
  # ph = ProjectorHelper.getInstance(1,1,1,1,[1,2,3,4])
  
  $("#info").append "mooo"
  
  window.BizzBuzzApp =
    Coordinate: Coordinate
    Page: Page
    BookManager: BookManager
    ProjectorHelper: ProjectorHelper

