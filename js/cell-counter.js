(function() {
  var Marking, checkAPIsAvailable, initCellCounter, markingsIdCounter;
  markingsIdCounter = 0;
  Marking = (function() {
    function Marking(x, y) {
      var pos;
      this.x = x;
      this.y = y;
      this.id = markingsIdCounter++;
      pos = {
        left: this.x - 4,
        top: this.y - 4
      };
      this.el = jq('<div/>').addClass('marking').css(pos).attr('id', this.id);
    }
    return Marking;
  })();
  initCellCounter = function() {
    var $markings, addMarking, canvas, ctx, findNearestMarking, init, initDragAndDrop, initManualCounter, loadImage, loadLocalImage, markings, removeMarking, showCellCount;
    canvas = $('mainCanvas');
    ctx = canvas.getContext('2d');
    markings = [];
    $markings = jq('#markings');
    init = function() {
      initDragAndDrop();
      initManualCounter();
      return loadImage('images/nora1.jpg');
    };
    initDragAndDrop = function() {
      canvas.ondragover = function() {};
      this.className = 'ondragover';
      return false;
      canvas.ondragleave = function() {
        this.className = '';
        return false;
      };
      return canvas.ondrop = function(e) {
        this.className = '';
        e.preventDefault();
        return loadLocalImage(e.dataTransfer.files[0]);
      };
    };
    initManualCounter = function() {
      return $markings.click(function(e) {
        if (e.ctrlKey && markings.length > 0) {
          return removeMarking(e.offsetX, e.offsetY);
        } else {
          return addMarking(e.offsetX, e.offsetY);
        }
      });
    };
    addMarking = function(x, y) {
      var marking;
      marking = new Marking(x, y);
      markings.push(marking);
      $markings.append(marking.el);
      return showCellCount();
    };
    removeMarking = function(x, y) {
      var marking;
      marking = findNearestMarking(x, y);
      markings = _.without(markings, marking);
      marking.el.remove();
      return showCellCount();
    };
    showCellCount = function() {
      return jq('#cellCount').text(markings.length);
    };
    findNearestMarking = function(x, y) {
      return _.min(markings, function(marking) {
        var dx, dy;
        dx = marking.x - x;
        dy = marking.y - y;
        return dx * dx + dy * dy;
      });
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
