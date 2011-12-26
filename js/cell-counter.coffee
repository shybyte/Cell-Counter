markingsIdCounter = 0
draggedMarking = null

class Marking
  constructor:(@x, @y) ->
    self = this
    @id = markingsIdCounter++
    @el = jq('<div/>').addClass('marking').attr(
      id:@id
      draggable:true
    ).bind('dragend', ->
        log('dragend')
    ).bind('dragstart', ->
        self.el.css('opacity', '0.4')
        draggedMarking = self
        log("dragstart")
    )
    @move(@x, @y)

  move:(x, y) ->
    @x = x
    @y = y
    pos = {left:x - 4, top:y - 4}
    @el.css(pos)


initCellCounter = () ->
  $threshold = jq('#threshold')
  $fadeThresholdImage = jq('#fadeThresholdImage')
  currentImg = null
  canvas = $('mainCanvas')
  filteredCanvas = $('filteredCanvas')
  ctx = canvas.getContext('2d')
  ctxFiltered = filteredCanvas.getContext('2d')
  markings = []
  $markings = jq('#markings')

  init = ->
    initDragAndDrop()
    initManualCounter()
    loadImage('images/nora1.jpg')
    $threshold.change(filterImage)
    $fadeThresholdImage.change(changeFading)

  initDragAndDrop = ->
    $markings.bind('dragover', ->
        canvas.className = 'ondragover'
        return false
    ).bind('dragleave', ->
        canvas.className = ''
        return false
    ).bind('drop', (e) ->
        canvas.className = ''
        e.preventDefault()
        if e.originalEvent.dataTransfer.files.length > 0
          loadLocalImage(e.originalEvent.dataTransfer.files[0])
        else if draggedMarking
          log(draggedMarking)
          draggedMarking.move(e.layerX, e.layerY)
          draggedMarking.el.css('opacity', '1.0')
          draggedMarking = null
    )

  initManualCounter = ->
    $markings.click((e) ->
        if e.ctrlKey and markings.length > 0
          removeMarking(e.layerX, e.layerY)
        else
          addMarking(e.layerX, e.layerY)
    )
    $markings.bind('contextmenu', (e)->
        e.preventDefault()
        removeMarking(e.layerX, e.layerY)
    )

  changeFading = ->
    v = $fadeThresholdImage.val()/128
    if v<1
      v1 = 1
      v2 = v
    else
      v1 = 2-v
      v2 = 1
    jq('#mainCanvas').css('opacity',v1)
    jq('#filteredCanvas').css('opacity',v2)

  addMarking = (x, y) ->
    marking = new Marking(x, y)
    markings.push(marking)
    $markings.append(marking.el)
    showCellCount()

  removeMarking = (x, y) ->
    marking = findNearestMarking(x, y)
    if marking
      markings = _.without(markings, marking)
      marking.el.remove()
      showCellCount()

  showCellCount = ->
    jq('#cellCount').text(markings.length)

  findNearestMarking = (x, y) ->
    _.min(markings, (marking) ->
        dx = marking.x - x
        dy = marking.y - y
        dx * dx + dy * dy
    )

  loadImage = (src) ->
    img = new Image()

    img.onload = ->
      currentImg = img
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0)
      filterImage()

    img.src = src

  loadLocalImage = (file) ->
    reader = new FileReader()
    reader.onload = (event) ->
      loadImage(event.target.result)
    reader.readAsDataURL(file)

  filterImage = ->
    filteredCanvas.width = currentImg.width
    filteredCanvas.height = currentImg.height
    filteredImage =  Filters.filterImage(Filters.thresholdRG,currentImg,{threshold: $threshold.val()})

    ctxFiltered.putImageData(filteredImage,0,0)

  init()


checkAPIsAvailable = ->
  if( typeof window.FileReader == 'undefined')
    alert("No local file reading possible. Please use a newer version of firefox or google chrome")

jq ->
  checkAPIsAvailable()
  initCellCounter()
