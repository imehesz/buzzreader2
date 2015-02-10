window.BizzBuzzApp = exports? and exports or window.BizzBuzzApp = {}

$ ->
  # Coordinate - handles all the coordinates related tasks
  class Coordinate
    constructor: (@coordStr) ->
      @coordinates = null
    
    # returns coordinates, also calls 2 point handler if needed
    # @return Array of Numbers
    getCoordinates: ->
      return @coordinates unless @coordinates is null
      tmpCoords = @coordStr.split(",")
      return @coordinates = tmpCoords if tmpCoords.length > 4
      @coordinates = @handleTwoPointers(tmpCoords)
  
    # converts coordinates array to array of objects
    # return Array of Objects
    getCoordinateObjects: ->
      xs = @getXs()
      ys = @getYs()
      retArr = []
      
      for x, i in xs
        retArr.push x:x, y:ys[i]

      retArr        
      
      
    # handles 2 point coordinates (old school BizzBuzz slicing)
    # @return Array of Numbers (4 point coordinates)
    handleTwoPointers: (coords) ->
      return coords unless coords.length is 4
      x1 = coords[0]
      y1 = coords[1]
      x2 = coords[2]
      y2 = coords[3]
      return [x1,y1,x2,y1,x2,y2,x1,y2]
    
    # gets all the X coordinates
    # @return Array of Numbers
    getXs: ->
      coords = @getCoordinates()
      xs = []
      xs.push c for c in coords by 2
      xs
      
    # gets all the Y coordinates
    # @return Array of Numbers
    getYs: ->
      coords = @getCoordinates()
      ys = []
      for c,i in coords by 2
        ys.push coords[i+1]
      ys
    
    # gets the max value from the Y coordinates
    # @return Number
    getMaxY: ->
      Math.max.apply Math, @getYs()
    
    # gets the min value from the Y coordinates
    # @return Number
    getMinY: ->
      Math.min.apply Math, @getYs()
    
    # gets the max value from the X coordinates 
    # @return Number
    getMaxX: ->
      Math.max.apply Math, @getXs()

    # gets the min value from the X coordinates 
    # @return Number      
    getMinX: ->
      Math.min.apply Math, @getXs()
  
  class Page
    constructor: (@url, @coordinates) ->
      console.log "running ...."
    currentPanelIdx: 0
    getUrl: -> @url
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
      @c = null
      @ctx = null
      @width = @getWidth()
      @height = @getHeight()
    setPage: (@page) ->
      proj = document.getElementById @projectorId
      proj.style.backgroundImage = "url(" + @page.getUrl() + ")";
    setPanel: (@panel) ->
    getPage: -> @page
    getPanel: -> @panel
    getWidth: -> document.getElementById(@projectorId).offsetWidth
    getHeight: -> document.getElementById(@projectorId).offsetHeight
    adjustBackground: () ->
    render: (coords) ->
      
      @c = $("#projector-overlay")[0] if @c is null
      @ctx = @c.getContext "2d" if @ctx is null
      
      @ctx.clearRect(0,0,@c.width,@c.height)
      
      
      @ctx.fillStyle = "black"
      @ctx.fillRect 0, 0, @c.width, @c.height
  
      @ctx.fillStyle = "rgba(0,0,0,1)"
      @ctx.globalCompositeOperation = "destination-out"
  
      @ctx.beginPath()
      
      # test for rhombus dimond in the middle of the projector
      #@ctx.moveTo @c.width/2,0
      #@ctx.lineTo @c.width,@c.height/2
      #@ctx.lineTo @c.width/2,@c.height
      #@ctx.lineTo 0,@c.height/2
      
      for coord, i in coords
        @ctx.moveTo coord.x,coord.y if i is 0
        @ctx.lineTo coord.x,coord.y if i > 0
      
      @ctx.fill()
      
      @ctx.globalCompositeOperation = "source-over";
      
      console.log "RENDERING", coords
      
    calculateProjectorCoordinates: (coords) ->
      t = @
      
      panelCoords = new Coordinate(coords.join(","))
      panelCoordObjs = panelCoords.getCoordinateObjects();
      
      console.log("HEYOOOO",@page.width,@page.height)
      projCoordObjs = []
      projCoords = []
      pageWidth = @page.width
      pageHeight = @page.height
      
      #origPanelWidth = @panel.getMaxX() - @panel.getMinX()
      #origPanelHeight = @panel.getMaxY() - @panel.getMinY()
      origPanelWidth = panelCoords.getMaxX() - panelCoords.getMinX()
      origPanelHeight = panelCoords.getMaxY() - panelCoords.getMinY()
      
      isLandscape = origPanelWidth > origPanelHeight
      isPortrait = !isLandscape
      
      projectorWidth = @width
      projectorHeight = @height
      
      widthZoom = projectorWidth/origPanelWidth
      heightZoom = projectorHeight/origPanelHeight
      zoomer = widthZoom
      
      panelWidth = Math.floor origPanelWidth*zoomer
      panelHeight = Math.floor origPanelHeight*zoomer
      
      centerX = Math.floor projectorWidth/2
      centerY = Math.floor projectorHeight/2
      
      # xCorrection = Math.floor @panel.getMinX()*zoomer
      # yCorrection = Math.floor((@panel.getMinY()*zoomer)-((projectorHeight-panelHeight)/2))
      
      xCorrection = Math.floor panelCoords.getMinX()*zoomer
      yCorrection = Math.floor((panelCoords.getMinY()*zoomer)-((projectorHeight-panelHeight)/2))
      
      panelCoordObjs.forEach (coord) ->
        tmpX = coord.x
        tmpY = coord.y
        
        tmpX = 0 if tmpX < 0
        tmpX = pageWidth if tmpX > pageWidth
        
        tmpY = 0 if tmpY < 0
        tmpY = pageHeight if tmpY > pageHeight
        
        if isPortrait or panelHeight > projectorHeight
          # console.log "panelHeight > projectorHeight ? ", panelHeight, projectorHeight
          zoomer = heightZoom
          panelWidth = Math.floor origPanelWidth*zoomer
          panelHeight = Math.floor origPanelHeight*zoomer

          xCorrection = Math.floor((panelCoords.getMinX()*zoomer)-((projectorWidth-panelWidth)/2))
          yCorrection = Math.floor panelCoords.getMinY()*zoomer
          
          if panelWidth > projectorWidth
            zoomer = widthZoom
            panelWidth = Math.floor origPanelWidth*zoomer
            panelHeight = Math.floor origPanelHeight*zoomer
          
            xCorrection = Math.floor panelCoords.getMinX()*zoomer
            yCorrection = Math.floor((panelCoords.getMinY()*zoomer)-((projectorHeight-panelHeight)/2))
        
        
        tmpX *= zoomer
        tmpY *= zoomer

        # console.log tmpX, tmpY, zoomer, xCorrection, yCorrection
        
        # console.log "panelWidth", panelWidth
        # console.log "panelHeight", panelHeight
        
        #projCoords.push tmpX
        #projCoords.push tmpY
        
        projCoords.push x:(Math.floor(tmpX)-xCorrection),y:(Math.floor(tmpY)-yCorrection)
        #projCoords.push x:Math.floor(coord.x),y:Math.floor(coord.y)
        
      
      bgMoveX = centerX - (panelCoords.getMinX()*zoomer) - (panelWidth/2)
      bgMoveY = centerY - (panelCoords.getMinY()*zoomer) - (panelHeight/2)
      
      if  @bookManager.getViewLevel() is @bookManager.PANEL_VIEW
        $("#" + @projectorId).css("background-position", bgMoveX+"px "+bgMoveY+"px")
      else
        $("#" + @projectorId).css("background-position", "center")
        
      $("#" + @projectorId).css("background-size", (pageWidth*zoomer)+"px "+(pageHeight*zoomer)+"px")
      
      projCoords
      
    project: () ->
      # console.log "Projector With", @getWidth()
      # console.log "Projector Height", @getHeight()
      # console.log "View Mode", @bookManager.getViewLevel()
      # console.log "Page", @getPage()
      
      if @bookManager.getViewLevel() == @bookManager.PANEL_VIEW
        @render(@calculateProjectorCoordinates @getPanel().getCoordinates())
      else
        @render(@calculateProjectorCoordinates new Coordinate("0,0," + @page.width + "," + @page.height).getCoordinates())
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
      
  
  #c = new Coordinate("1,2,3,4").getCoordinates()
  #console.log c
  #p = new Page()
  
  bookObj =
    title: "Some Title",
    writer: "A Writer",
    illustrator: "An Illustrator",
    pages: [
      new Page("https://5590b350b8e8612362e86b9426c7815b2a13a98a.googledrive.com/host/0B55OYxnBow_9UG5HbW1fWGhkR2c/bizzbuzzpaneltest.png",[
        new Coordinate "10,9,114,118"
        new Coordinate "12,125,114,175"
        new Coordinate "130,9,236,175"
        new Coordinate "12,188,236,251"
        new Coordinate "20,284,10,304,10,334,25,354,65,371,100,355,121,326,112,281,81,261,29,266,22,277,22,277,14,287,14,287,26,273"
        new Coordinate "172,284,140,305,131,345,140,360,149,365,142,385,146,399,194,400,213,375,202,345,230,328,238,296,211,267,173,276"
        new Coordinate "9,427,13,481,234,486,230,485"
        new Coordinate "13,406,230,474,229,407"
      ])
      
      new Page("http://i.imgur.com/uf7miIB.jpg",[
        new Coordinate "34,32,460,786"
        new Coordinate "506,50,984,142"
        new Coordinate "512,174,666,178,678,278,698,310,828,320,824,414,642,418,614,664,486,658,500,172"
        new Coordinate "716,146,998,144,996,782,906,640,842,644,774,672,762,752,642,742,650,562,700,474,798,442,834,368,810,312,716,302"
        new Coordinate "462,668,644,664,650,750,764,766,776,672,838,642,892,688,918,772,938,824,634,824,634,872,458,868"
      ])
    ]
  
  bm = new BookManager(bookObj)
  # bm.setViewLevel bm.PAGE_VIEW
  
  #console.log bm.getMaxPage()
  #console.log bm.getCurrentPage().getCurrentPanel().getCoordinates()


  ph = new ProjectorHelper "projector1", bm
  
  bm.getCurrentPage ph.project, ph
  
  document.getElementById("back").onclick = -> ph.prev()
  document.getElementById("next").onclick = -> ph.next()
  
  # ph = ProjectorHelper.getInstance(1,1,1,1,[1,2,3,4])
  
  $("#info").append "mooo"

  window.BizzBuzzApp =
    Coordinate: Coordinate
    Page: Page
    BookManager: BookManager
    ProjectorHelper: ProjectorHelper