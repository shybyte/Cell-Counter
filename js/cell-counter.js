(function() {
  var initCellCounter;
  initCellCounter = function() {
    var canvas, ctx, init, loadImage;
    canvas = $('mainCanvas');
    ctx = canvas.getContext('2d');
    init = function() {
      return loadImage('images/nora1.jpg');
    };
    loadImage = function(src) {
      var img;
      img = new Image();
      img.onload = function() {
        canvas.width = img.width;
        canvas.height = img.height;
        return ctx.drawImage(img, 0, 0);
      };
      return img.src = src;
    };
    return init();
  };
  jq(function() {
    return initCellCounter();
  });
}).call(this);
