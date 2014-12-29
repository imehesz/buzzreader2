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
    setPanelIndex: (idx) -> @.currentPanelIdx=idx
    getPanelCount: -> @coordinates.length
    getCurrentPanel: ->
      @coordinates[@currentPanelIdx]
      
    getNextPanel: ->
      @currentPanelIdx++ if @currentPanelIdx < @coordinates.length-1
      @getCurrentPanel()
      
    getPreviousPanel: ->
      @currentPanelIdx-- if @currentPanelIdx > 0
      @getCurrentPanel()
    
    isLastPanel: -> @currentPanelIdx == @coordinates.length-1
    isFirstPanel: -> @currentPanelIdx == 0
  
  class BookManager
    constructor: (@bookObj) ->
      @setBook(@bookObj)
    PAGE_VIEW: 1
    PANEL_VIEW: 2
    viewLevel: 2
    getViewLevel: -> @viewLevel
    setViewLevel: (@viewLevel) ->
    setBook: (@bookObj) ->
      @pages = @bookObj.pages
      @currentPageIdx = 0
    currentPageIdx: 0,
    getMaxPage: ->
      @bookObj.pages.length
    getCurrentPage: (cb, scope) ->
      console.log "Loading image: " + @pages[@currentPageIdx].url
      page = @pages[@currentPageIdx]
      image = new Image()
      image.src = @pages[@currentPageIdx].url
      image.onload = (e) ->
        page.width = this.width
        page.height = this.height
        cb.apply(scope) unless typeof cb != "function"
        
      page
    getNextPage: (cb, scope) ->
      @currentPageIdx++ if @currentPageIdx < @getMaxPage()-1
      @getCurrentPage(cb, scope, 0)
    getPreviousPage: (cb, scope) ->
      @currentPageIdx-- if @currentPageIdx > 0
      @getCurrentPage(cb, scope, @.pages[@.currentPageIdx].coordinates.length)
      
    isLastPage: -> @currentPageIdx == @getMaxPage()-1
    isFirstPage: -> @currentPageIdx == 0
      
  
  class ProjectorHelper
    constructor: (@projectorId, @bookManager) ->
      @setPage @bookManager.getCurrentPage()
      @setPanel @getPage().getCurrentPanel()
    setPage: (@page) ->
    setPanel: (@panel)->
    getPage: -> @page
    getPanel: -> @panel
    getWidth: -> document.getElementById(@projectorId).offsetWidth
    getHeight: -> document.getElementById(@projectorId).offsetHeight
    project: () ->
      # console.log "Projector With", @getWidth()
      # console.log "Projector Height", @getHeight()
      # console.log "View Mode", @bookManager.getViewLevel()
      # console.log "Page", @getPage()
      
      if @bookManager.getViewLevel() == @bookManager.PANEL_VIEW
        console.log "Projecting Panel Panel -> ", @getPanel().getCoordinates()
      else
        console.log "Projecting Page -> ", "0,0," + @page.width + "," + @page.height
    next: ->
      loadNextPage = false
      if @bookManager.getViewLevel() == @bookManager.PANEL_VIEW
        # if last panel, we must get the next page
        if(@getPage().isLastPanel())
          console.log "LAST PANEL, LOAD NEXT PAGE"
          loadNextPage = true
        else
          console.log "GET NEXT PANEL"
          @setPanel @getPage().getNextPanel()
          @project()
      else
        loadNextPage = true
        
      if loadNextPage
        console.log "NEXT PAGE"
        if @bookManager.isLastPage()
          console.log "LAST PAGE!!!! OVER!"
        else
          @setPage @bookManager.getNextPage(->
            @getPage().setPanelIndex 0
            @setPanel @getPage().getCurrentPanel()
            @project()
          ,@)
        
    prev: ->
      loadPreviousPage = false
      if @bookManager.getViewLevel() == @bookManager.PANEL_VIEW
        # if first panel we must get the previous page
        if @getPage().isFirstPanel()
          console.log "FIRST PANEL, LOAD PREVIOUS PAGE"
          loadPreviousPage = true
        else
          console.log "GET PREVIOUS PANEL"
          @setPanel @getPage().getPreviousPanel()
          @project()
      else
        loadPreviousPage = true

      if loadPreviousPage
        console.log "PREVIOUS PAGE"
        if @bookManager.isFirstPage()
          console.log "FIRST PAGE!!"
        else
          @setPage @bookManager.getPreviousPage(->
            @getPage().setPanelIndex @getPage().getPanelCount()-1
            @setPanel @getPage().getCurrentPanel()
            @project()
          ,@)
      
  
  class ProjectorHelper2
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
  #console.log bm.getMaxPage()
  #console.log bm.getCurrentPage().getCurrentPanel().getCoordinates()


  ph = new ProjectorHelper "projector1", bm
  
  bm.getCurrentPage ph.project, ph
  
  document.getElementById("back").onclick = -> ph.prev()
  document.getElementById("next").onclick = -> ph.next()
  
  # ph = ProjectorHelper.getInstance(1,1,1,1,[1,2,3,4])
  
  $("#info").append "mooo"
  
  # canvas cutout
  c = $("#projector-overlay")[0]
  ctx = c.getContext "2d"
  
  ctx.fillStyle = "black"
  ctx.fillRect(0, 0, c.width, c.height);
  
  ctx.fillStyle = "rgba(0,0,0,1)"
  ctx.globalCompositeOperation = "destination-out"
  
  ctx.beginPath()
  ctx.moveTo c.width/2,0
  ctx.lineTo c.width,c.height/2
  ctx.lineTo c.width/2,c.height
  ctx.lineTo 0,c.height/2
  ctx.fill()
  
  window.BizzBuzzApp =
    Coordinate: Coordinate
    Page: Page
    BookManager: BookManager
    ProjectorHelper: ProjectorHelper