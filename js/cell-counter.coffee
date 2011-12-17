initCellCounter = () ->
  canvas = $('mainCanvas')
  ctx = canvas.getContext('2d')

  init = ->
    loadImage('images/nora1.jpg')

  loadImage = (src) ->
    img = new Image();
    img.onload = ->
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0);
    img.src = src;

  init()







jq ->
  initCellCounter()
