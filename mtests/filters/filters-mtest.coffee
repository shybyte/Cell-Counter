IMAGES = ['peaktest.png','nora1.png','nora1-grey.png','dummy.png'] #//,'nora2-big.jpg']

$ ->
  $tableBody = $('#examples tbody')

  for image in IMAGES
    $row = $('<tr><td></td><td></td><td></td><td></td></tr>')
    $tds = $row.children().map( -> $(this))
    $tableBody.append($row)

    $image = $("<img src='images/#{image}' style='min-width:100px'>")
    $tds[0].append($image)

    $canvas = $('<canvas style="border: 1px solid red;"/>')
    $tds[2].append($canvas)


    $filterButton = $('<button>Filter</button>')
    $filterButton.click(createFilterButtonCall($image,$canvas,$tds[3]))
    $tds[1].append($filterButton)


createFilterButtonCall = ($imagePara,$canvasPara,$timeCellPara)->
  f = ->
    filter($imagePara,$canvasPara,$timeCellPara)
  return f

filter = ($image,$canvas,$timeCell)->
  image = $image.get(0)
  canvas = $canvas.get(0)
  ctx = canvas.getContext('2d')
  canvas.width = image.width
  canvas.height = image.height
  timeStart = new Date().getTime()
  cgs = Filters.compressedGrayScaleFromRed(Filters.getPixels(image))
  filteredCGS = cgs;
  #filteredCGS = Filters.thresholdCGS(filteredCGS,80)
  filteredCGS = Filters.meanCGSRepeated(filteredCGS,5,5)
#  filteredCGS = Filters.peaksCGS(filteredCGS,50,3)
#  log(filteredCGS.peaks)
  filteredImage = Filters.imageDataFromCompressedGrayScale(filteredCGS)
  #filteredImage = Filters.filterImage(Filters.fastGaussian, image)
  neededTime = (new Date().getTime())-timeStart
  ctx = canvas.getContext('2d')
  ctx.putImageData(filteredImage, 0, 0)
  $timeCell.text("Time: "+neededTime)
