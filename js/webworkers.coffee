importScripts('filtersww.js')
importScripts('filters-fast.js')

addEventListener('message', (e)->
  data = e.data;
  switch data.cmd
    when 'start'
      postMessage('WORKER STARTED: ' + data.msg)
    when 'autocount'
      if  data.imageType == 'whiteOnBlue'
        cgs = Filters.compressedGrayScaleFromRedGreen(data.imageData)
      else
        cgs = Filters.compressedGrayScaleFromRedGreenBlue(data.imageData)
      filteredCGS = cgs;
      filteredCGS = Filters.meanCGSRepeated(filteredCGS,5,4)
      filteredCGS = Filters.peaksCGS(filteredCGS,data.threshold,3)
      postMessage({cmd:'autocount',result:filteredCGS.peaks})
, false)