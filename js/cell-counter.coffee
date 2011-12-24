markingsIdCounter = 0
class Marking
  constructor:(@x, @y) ->
    @id = markingsIdCounter++
    pos = {left:@x - 4, top:@y - 4}
    @el = jq('<div/>').addClass('marking').css(pos).attr('id',@id)


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
    canvas.ondragover = ->
    this.className = 'ondragover'
    return false

    canvas.ondragleave = ->
      this.className = ''
      return false

    canvas.ondrop = (e) ->
      this.className = ''
      e.preventDefault()
      loadLocalImage(e.dataTransfer.files[0])

  initManualCounter = ->
    $markings.click((e) ->
        if e.ctrlKey and markings.length>0
          removeMarking(e.offsetX, e.offsetY)
        else
          addMarking(e.offsetX, e.offsetY)
    )

  addMarking = (x, y) ->
    marking = new Marking(x, y)
    markings.push(marking)
    $markings.append(marking.el)
    showCellCount()

  removeMarking = (x, y) ->
    marking = findNearestMarking(x, y)
    markings = _.without(markings,marking)
    marking.el.remove()
    showCellCount()

  showCellCount = ->
    jq('#cellCount').text(markings.length)

  findNearestMarking = (x, y) ->
    _.min(markings, (marking) ->
      dx = marking.x-x
      dy = marking.y-y
      dx*dx+dy*dy
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
