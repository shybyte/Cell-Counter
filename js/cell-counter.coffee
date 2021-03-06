markingsIdCounter = 0
draggedMarking = null

ALL_MARKING_TYPES = ['0', '1', '2', '3', '4']
enabledMarkingTypes = ['0','1']

TOOL_MODE =
  MARKING:"marking"
  CROP:"crop"
toolMode = TOOL_MODE.MARKING


class Marking
  constructor:(@pos, @type) ->
    self = this
    @id = markingsIdCounter++
    @el = jq('<div/>').addClass('marking markingType' + @type).attr(
      id:@id
      draggable:false
    ).bind('dragend',
      ->
        log('dragend')
    ).bind('dragstart', ->
        self.el.css('opacity', '0.4')
        draggedMarking = self
        log("dragstart")
    )
    @move(pos)

  move:(pos) ->
    @pos = pos

  updateScreenPos:(canvas, $canvas, cropWindowPos) ->
    screenPos = {
      left: (@pos.x-cropWindowPos.x) / canvas.width * $canvas.width(),
      top: (@pos.y-cropWindowPos.y) / canvas.height * $canvas.height()
    }
    @el.css(screenPos)


initCellCounter = () ->
  $threshold = jq('#threshold')
  $fadeThresholdImage = jq('#fadeThresholdImage')
  $markingsSize = jq('#markingsSize')
  $restoreOriginalImageLink = $('#restoreOriginalImageLink')
  $restoreSavedCroppingLink = $('#restoreSavedCroppingLink')
  currentImg = null
  $canvas = jq('#mainCanvas')
  canvas = $canvas.get(0)
  filteredCanvas = jq('#filteredCanvas').get(0)
  ctx = canvas.getContext('2d')
  ctxFiltered = filteredCanvas.getContext('2d')
  cropWindow = {
    x: 0,
    y: 0
  }
  savedCropWindow = null
  markings = []
  $markings = jq('#markings')
  currentFilename = ""

  init = ->
    warnIfNoFileReaderAvailable()
    loadSettings()
    initConfigureDialog(configureEnabledMarkingTypes)
    initHelp()
    configureEnabledMarkingTypes()
    initReadFile()
    initDragAndDrop()
    initManualCounter()
    initAutoCounter()
    initCropTool()
    initSliders()
    loadImage('images/nora1.jpg')
    initOnResize()
    $('#removeAllMarkings').click(onRemoveAllMarkings)
    $('#filterButton').click(filterImage2)

  initHelp = ->
    $("#helpLink").overlay({
      mask:{
      color:'#ebecff',
      loadSpeed:200,
      opacity:0.7
      },
      closeOnClick:false
      })


  initCropTool = ->
    $canvasAndHelpContainer = $('#canvasAndHelpContainer')
    loadSavedCropWindow()
    $helpText = $('#helpText')
    $cropSelection = $('#cropSelection')
    points = null
    cropStartPosInCanvas = null
    $('#cropImageLink').click ->
      points = []
      toolMode = TOOL_MODE.CROP
      $helpText.text("Click the top left point! Press the ESC key to cancel cropping.")
      $helpText.show("slow")
      $canvasAndHelpContainer.expose({
        color: '#333',
        onClose: ->
          $helpText.hide()
          $cropSelection.hide('slow')
          toolMode = TOOL_MODE.MARKING
      })
    $markings.mousemove( (e)->
        if toolMode == TOOL_MODE.CROP and points.length == 1
          pos = eventPosInCanvas(e)
          w = pos.x-cropStartPosInCanvas.x
          h = pos.y-cropStartPosInCanvas.y
          $cropSelection.css({width: w+'px',height:h+'px'})
    )
    $markings.click( (e)->
      if toolMode == TOOL_MODE.CROP
        posInCanvas = eventPosInCanvas(e)
        $cropSelection.css({top:posInCanvas.y,left:posInCanvas.x,width:'5px',height:'5px'}).show()
        cropStartPosInCanvas = posInCanvas;
        points.push(eventPosInImage(e))
        if points.length == 1
          $helpText.text("Click the bottom right point! Press the ESC key to cancel cropping.")
        else if points.length>1
          $.mask.close();
          fixPointOrder()
          cropImage({x:points[0].x,y:points[0].y,width:points[1].x-points[0].x,height:points[1].y-points[0].y})
    )
    fixPointOrder = ->
      if points[1].x<points[0].x
        tempX = points[0].x
        points[0].x = points[1].x
        points[1].x = tempX
      if points[1].y<points[0].y
        tempY = points[0].y
        points[0].y = points[1].y
        points[1].y = tempY
    cropImage = (newCropWindow)->
      imageData = ctx.getImageData(newCropWindow.x-cropWindow.x, newCropWindow.y-cropWindow.y,
        newCropWindow.width, newCropWindow.height)
      cropWindow = newCropWindow
      canvas.width = newCropWindow.width
      canvas.height = newCropWindow.height
      #ctx.drawImage(canvasClone, points[0].x, points[0].y, newW, newH, 0, 0, newW, newH);
      ctx.putImageData(imageData, 0, 0);
      filterImage()
      cropMarkins()
      $restoreOriginalImageLink.show('slow')
      saveForCurrentImage('cropWindow',cropWindow)

    cropMarkins = ->
      for marking in markings
        pos = marking.pos
        if (cropWindow.x<=pos.x<cropWindow.x+canvas.width and
            cropWindow.y<=pos.y<cropWindow.y+canvas.height)
          marking.updateScreenPos(canvas,$canvas,cropWindow)
        else
          marking.el.remove()
          marking.removed = true
      markings =  (m for m in markings when !m.removed)
      saveMarkings()
      showCellCount()
      $restoreSavedCroppingLink.hide('slow')

    $restoreOriginalImageLink.click ( ->
      $restoreOriginalImageLink.hide('slow')
      onImageLoaded(currentImg)
    )

    $restoreSavedCroppingLink.click ( ->
      cropImage(savedCropWindow)
    )

  loadSavedCropWindow = ->
    savedCropWindow = loadForCurrentImage('cropWindow',null)
    if savedCropWindow
      $restoreSavedCroppingLink.show('slow')
    else
      $restoreSavedCroppingLink.hide('slow')

  initAutoCounter =->
    $autoCountButton = $('#autoCountButton')
    $countingMessage =  $('#countingMessage')
    $countingProgress = $('#countingProgress')
    setCountingProgress = (p) ->
      log(Math.round(p*100).toString())
      $countingProgress.text(Math.round(p*100).toString())
    worker = new Worker('js/webworkers.js');
    worker.addEventListener('message', (e) ->
      log('Worker said: ')
      log(e.data)
      switch e.data.cmd
        when 'autocountProgress'
          setCountingProgress(e.data.result)
        when 'autocount'
          setTimeout( ->
            selectedMarkingType = getSelectedMarkingType()
            for peak in e.data.result
              addMarking({
              x: peak.x+cropWindow.x
              y: peak.y+cropWindow.y
              }, selectedMarkingType)
            saveMarkings()
            $countingMessage.hide('slow')
            $autoCountButton.attr("disabled", false)
          ,7)
    , false)
    worker.postMessage({cmd:'start',msg:'bla'});
    autoCount = ->
      $autoCountButton.attr("disabled", true)
      removeAllMarkings()
      setCountingProgress(0)
      $countingMessage.show()
      imageType = $('#imageTypeSelector').val()
      threshold = $threshold.val()
      setTimeout( ->
        imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        ua = $.browser;
        if  ua.mozilla && ua.version.slice(0,3) == "1.9"
          imageData = Filters.cloneImageDataAsNormalObject(imageData)
        worker.postMessage({cmd:'autocount',imageData:imageData,threshold:threshold,imageType:imageType})
      ,7)
    $autoCountButton.click(autoCount)

  initOnResize = ->
    jq(window).resize((e)->
        #updateMarkingsScreenPos
        for marking in markings
          marking.updateScreenPos(canvas, $canvas,cropWindow)
    )

  saveSettings = ->
    settings = {
    markingsSize:$markingsSize.val()
    threshold:$threshold.val()
    fadeThresholdImage:$fadeThresholdImage.val()
    enabledMarkingTypes:enabledMarkingTypes
    }
    localStorage['cell_counter_settings'] = JSON.stringify(settings)


  loadSettings = ->
    settingsString = localStorage['cell_counter_settings']
    if settingsString
      settings = JSON.parse(settingsString)
      enabledMarkingTypes = settings.enabledMarkingTypes || ["0", "1"]
      $threshold.val(settings.threshold)
      $markingsSize.val(settings.markingsSize)
      $fadeThresholdImage.val(settings.fadeThresholdImage)
    onChangeMarkingsSize()
    changeFading()
    configureEnabledMarkingTypes()

  configureEnabledMarkingTypes = ->
    saveSettings()
    $markingTypeSelectors = $('#markingTypeSelectors')
    prevSelectedMarkingType = getSelectedMarkingType()
    $markingTypeSelectors.empty()
    for markingType in enabledMarkingTypes
      row = """<div>
                      <input id="markingTypeSelector#{markingType}" type="radio" name="markingType" value="#{markingType}">
                      <label for="markingTypeSelector#{markingType}" class="markingLabel#{markingType}">Count: <span id="cellCount#{markingType}">0</span></label>
                      </div>"""
      $markingTypeSelectors.append(row)
    selectedMarkingType = if prevSelectedMarkingType in enabledMarkingTypes
      prevSelectedMarkingType
    else
      enabledMarkingTypes[0]
    $("#markingTypeSelector#{selectedMarkingType}").prop('checked', true)
    showCellCount()


  loadMarkings = ()->
    removeAllMarkings()
    markingsData = loadForCurrentImage('markings_data',[])
    for markingData in markingsData
      addMarking(markingData.pos, markingData.type)

  saveMarkings = () ->
    markingsData = ({pos:marking.pos, type:marking.type} for marking in markings)
    saveForCurrentImage('markings_data',markingsData)

  loadForCurrentImage = (key,defaultValue)->
    loadedJSON = localStorage["cell_counter_#{key}_#{currentFilename}"]
    return loadedJSON && JSON.parse(loadedJSON) ? defaultValue


  saveForCurrentImage = (key,data)->
    localStorage["cell_counter_#{key}_#{currentFilename}"] = JSON.stringify(data)



  initReadFile = ->
    $openFile = jq('#openFile')
    $openFile.change(->
        files = $openFile.get(0).files
        loadLocalImage(files[0])
    )


  initDragAndDrop = ->
    $markings.bind('dragover',
      ->
        #canvas.className = 'ondragover'
        return false
    ).bind('dragleave',
      ->
        canvas.className = ''
        return false
    ).bind('drop', (e) ->
        canvas.className = ''
        e.preventDefault()
        if e.originalEvent.dataTransfer.files.length > 0
          loadLocalImage(e.originalEvent.dataTransfer.files[0])
        else if draggedMarking
          nada = 1
      #draggedMarking.move(eventPosInCanvas(e.originalEvent))
      #draggedMarking.el.css('opacity', '1.0')
      #draggedMarking = null
    )

  initSliders = ->
    bindSliderChange = ($slider, onChange)->
      $slider.hide().rangeinput().change(->
          saveSettings()
          onChange()
      )
    bindSliderChangeAndSlide = ($slider, onChange)->
      bindSliderChange($slider, onChange).bind('onSlide', onChange)
    $markingsSize = bindSliderChangeAndSlide($markingsSize, onChangeMarkingsSize)
    $threshold = bindSliderChange($threshold, filterImage)
    $fadeThresholdImage = bindSliderChangeAndSlide($fadeThresholdImage, changeFading)


  onChangeMarkingsSize = ->
    cssRule = getCSSRule('.marking')
    if cssRule
      newMarkingsSize = $markingsSize.val()
      cssRule.style.width = newMarkingsSize + 'px'
      cssRule.style.height = newMarkingsSize + 'px'
      cssRule.style.marginLeft = -newMarkingsSize / 2 + 'px'
      cssRule.style.marginTop = -newMarkingsSize / 2 + 'px'
    else
      log('Try again to change marking size ...')
      setTimeout(onChangeMarkingsSize,1000)

  initManualCounter = ->
    $markings.click((e) ->
        if toolMode == TOOL_MODE.MARKING
          pos = eventPosInImage(e)
          if e.ctrlKey and markings.length > 0
            removeMarking(pos)
          else
            addMarkingWithSelectedType(pos)
    )
    $markings.bind('contextmenu', (e)->
        e.preventDefault()
        removeMarking(eventPosInImage(e))
    )

  eventPosInCanvas = (e)->
    canvasOffset = $canvas.offset()
    return {x:e.pageX - canvasOffset.left, y:e.pageY - canvasOffset.top}

  eventPosInImage = (e)->
    p = eventPosInCanvas(e)
    return {
    x:Math.round(p.x / $canvas.width() * canvas.width)+cropWindow.x
    y:Math.round(p.y / $canvas.height() * canvas.height)+cropWindow.y
    }


  changeFading = ->
    v = $fadeThresholdImage.val()
    v = v / 128
    if v < 1
      v1 = 1
      v2 = v
    else
      v1 = 2 - v
      v2 = 1
    jq('#mainCanvas').css('opacity', v1)
    jq('#filteredCanvas').css('opacity', v2)

  addMarkingWithSelectedType = (pos) ->
    addMarking(pos, getSelectedMarkingType())
    saveMarkings()

  getSelectedMarkingType = -> jq('input:radio[name=markingType]:checked').val()

  addMarking = (pos, type) ->
    marking = new Marking(pos, type)
    markings.push(marking)
    $markings.append(marking.el)
    marking.updateScreenPos(canvas, $canvas,cropWindow)
    showCellCount()

  removeMarking = (pos) ->
    marking = findNearestMarking(pos.x, pos.y)
    if marking
      markings = _.without(markings, marking)
      marking.el.remove()
      showCellCount()
      saveMarkings()

  onRemoveAllMarkings = ->
    removeAllMarkings()
    saveMarkings()

  removeAllMarkings = ->
    for marking in markings
      marking.el.remove()
    markings = []
    showCellCount()


  showCellCount = ->
    groupedMarkings = _.groupBy(markings, 'type')
    countByCellType = (type2) ->
      (groupedMarkings[type2]?.length) ? 0
    for markingType in enabledMarkingTypes
      jq("#cellCount#{markingType}").text(countByCellType(markingType))

  findNearestMarking = (x, y) ->
    _.min(markings, (marking) ->
        dx = marking.pos.x - x
        dy = marking.pos.y - y
        dx * dx + dy * dy
    )

  loadLocalImage = (file) ->
    reader = new FileReader()
    reader.onload = (event) ->
      loadImage(event.target.result)
      currentFilename = file.name
    reader.readAsDataURL(file)

  loadImage = (src) ->
    $restoreOriginalImageLink.hide('slow')
    img = new Image()
    img.onload = ->
      onImageLoaded(img)
    img.src = src

  onImageLoaded = (img)->
    cropWindow = {x: 0, y: 0, width:img.width, height:img.height}
    currentImg = img
    canvas.width = img.width
    canvas.height = img.height
    ctx.drawImage(img, 0, 0)
    loadMarkings()
    loadSavedCropWindow()
    filterImage()


  filterImage = ->
    filteredCanvas.width = canvas.width
    filteredCanvas.height = canvas.height
    filteredImage = Filters.filterCanvas(Filters.thresholdRG, canvas, {threshold:$threshold.val()})
    ctxFiltered.putImageData(filteredImage, 0, 0)

  filterImage2 = ->
    convolutionMatrix = [  0, -1, 0,
      -1, 5, -1,
      0, -1, 0 ]
    filteredImage = Filters.filterCanvas(Filters.fastGaussian, canvas, convolutionMatrix)
    ctx.putImageData(filteredImage, 0, 0)

  warnIfNoFileReaderAvailable = ->
    if(!window.FileReader)
      noFileReader = "No local file reading possible. "
      alert(noFileReader + BROWSER_TO_OLD_MESSAGE)
      jq('#openFile').replaceWith(noFileReader + $canvas.html())
    ;

  init()


initConfigureDialog = (onNewEnabledMarkingTypes)->
  $box = $('#enabledMarkingTypesSelector')
  $("#configureLink").click(
    ->
      $box.empty()
      for markingType in ALL_MARKING_TYPES
        checked = if markingType in enabledMarkingTypes then "checked" else ""
        markingRow =
          """<div>
              <input id="enableMarkingType#{markingType}" type="checkbox" value="#{markingType}" #{checked}>
              <label for="enableMarkingType#{markingType}" class="markingLabel#{markingType}">Cell Type #{markingType}</label>
                                           </div>
                                        """
        $box.append(markingRow)
  ).overlay({
    mask:{
    color:'#ebecff',
    loadSpeed:200,
    opacity:0.7
    },
    closeOnClick:false
    })

  jq('#configureOKButton').click(->
      enabledMarkingTypes = []
      $('input:checked', $box).each((i, el)->
          enabledMarkingTypes.push($(el).val())
      )
      onNewEnabledMarkingTypes()
  )


BROWSER_TO_OLD_MESSAGE = "Your browser is too old. Please use a newer version of firefox, google chrome or opera."

initUpdateMessage = ->
  window.applicationCache.addEventListener('updateready', ->
      if window.applicationCache.status == window.applicationCache.UPDATEREADY
        window.applicationCache.swapCache()
        if confirm('A new version of "Marcos Cell Counter" is available. Load it now?')
          window.location.reload()
    ,false)


jq ->
  if (isCanvasSupported())
    initUpdateMessage()
    initCellCounter()
  else
    jq('#openFile').hide()
    alert(BROWSER_TO_OLD_MESSAGE)

