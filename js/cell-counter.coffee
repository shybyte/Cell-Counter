markingsIdCounter = 0
draggedMarking = null

class Marking
  constructor:(@x, @y) ->
    self = this
    @id = markingsIdCounter++
    pos = {left:@x - 4, top:@y - 4}
    @el = jq('<div/>').addClass('marking').css(pos).attr(
      id:@id
      draggable:true
    ).bind('dragend',
      ->
        log('dragend')
    ).bind('dragstart', ->
        self.el.css('opacity','0.4')
        draggedMarking = self
        log("dragstart")
    )

  move: (x,y) ->
    pos = {left:x - 4, top:y-4}
    @el.css(pos)


initCellCounter = () ->
  canvas = $('mainCanvas')
  ctx = canvas.getContext('2d')
  markings = []
  $markings = jq('#markings')

  init = ->
    initDragAndDrop()
    initManualCounter()
    loadImage('images/nora1.jpg')

  initDragAndDrop = ->
    $markings.bind('dragover',
      ->
        canvas.className = 'ondragover'
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
          log(draggedMarking)
          draggedMarking.move(e.layerX, e.layerY)
          draggedMarking.el.css('opacity','1.0')
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
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0)
    img.src = src

  loadLocalImage = (file) ->
    reader = new FileReader()
    reader.onload = (event) ->
      loadImage(event.target.result)
    reader.readAsDataURL(file)

  init()


checkAPIsAvailable = ->
  if( typeof window.FileReader == 'undefined')
    alert("No local file reading possible. Please use a newer version of firefox or google chrome")

jq ->
  checkAPIsAvailable()
  initCellCounter()
