(function() {
  var checkAPIsAvailable, initCellCounter;
  initCellCounter = function() {
    var canvas, ctx, init, loadImage, loadLocalImage;
    canvas = $('mainCanvas');
    ctx = canvas.getContext('2d');
    init = function() {
      canvas.ondragover = function() {
        this.className = 'ondragover';
        return false;
      };
      canvas.ondragleave = function() {
        this.className = '';
        return false;
      };
      canvas.ondrop = function(e) {
        this.className = '';
        e.preventDefault();
        return loadLocalImage(e.dataTransfer.files[0]);
      };
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
    loadLocalImage = function(file) {
      var reader;
      reader = new FileReader();
      reader.onload = function(event) {
        return loadImage(event.target.result);
      };
      return reader.readAsDataURL(file);
    };
    return init();
  };
  checkAPIsAvailable = function() {
    if (typeof window.FileReader === 'undefined') {
      return alert("No local file reading possible. Please use a newer version of firefox or google chrome");
    }
  };
  jq(function() {
    checkAPIsAvailable();
    return initCellCounter();
  });
}).call(this);
