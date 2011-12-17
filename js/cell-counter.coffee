initCellCounter = () ->
  canvas = $('mainCanvas')
  ctx = canvas.getContext('2d')

  init = ->
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


    loadImage('images/nora1.jpg')

  loadImage = (src) ->
    img = new Image();
    img.onload = ->
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0)
    img.src = src;

  loadLocalImage = (file) ->
    reader = new FileReader();
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
