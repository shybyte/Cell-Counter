(function() {
  var IMAGES, createFilterButtonCall, filter;
  IMAGES = ['peaktest.png', 'nora1.png', 'nora1-grey.png', 'dummy.png'];
  $(function() {
    var $canvas, $filterButton, $image, $row, $tableBody, $tds, image, _i, _len, _results;
    $tableBody = $('#examples tbody');
    _results = [];
    for (_i = 0, _len = IMAGES.length; _i < _len; _i++) {
      image = IMAGES[_i];
      $row = $('<tr><td></td><td></td><td></td><td></td></tr>');
      $tds = $row.children().map(function() {
        return $(this);
      });
      $tableBody.append($row);
      $image = $("<img src='images/" + image + "' style='min-width:100px'>");
      $tds[0].append($image);
      $canvas = $('<canvas style="border: 1px solid red;"/>');
      $tds[2].append($canvas);
      $filterButton = $('<button>Filter</button>');
      $filterButton.click(createFilterButtonCall($image, $canvas, $tds[3]));
      _results.push($tds[1].append($filterButton));
    }
    return _results;
  });
  createFilterButtonCall = function($imagePara, $canvasPara, $timeCellPara) {
    var f;
    f = function() {
      return filter($imagePara, $canvasPara, $timeCellPara);
    };
    return f;
  };
  filter = function($image, $canvas, $timeCell) {
    var canvas, cgs, ctx, filteredCGS, filteredImage, image, neededTime, timeStart;
    image = $image.get(0);
    canvas = $canvas.get(0);
    ctx = canvas.getContext('2d');
    canvas.width = image.width;
    canvas.height = image.height;
    timeStart = new Date().getTime();
    cgs = Filters.compressedGrayScaleFromRed(Filters.getPixels(image));
    filteredCGS = cgs;
    filteredCGS = Filters.meanCGSRepeated(filteredCGS, 5, 5);
    filteredImage = Filters.imageDataFromCompressedGrayScale(filteredCGS);
    neededTime = (new Date().getTime()) - timeStart;
    ctx = canvas.getContext('2d');
    ctx.putImageData(filteredImage, 0, 0);
    return $timeCell.text("Time: " + neededTime);
  };
}).call(this);
