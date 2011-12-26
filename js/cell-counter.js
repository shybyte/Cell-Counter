(function() {
  var Marking, checkAPIsAvailable, draggedMarking, initCellCounter, markingsIdCounter;
  markingsIdCounter = 0;
  draggedMarking = null;
  Marking = (function() {
    function Marking(x, y) {
      var pos, self;
      this.x = x;
      this.y = y;
      self = this;
      this.id = markingsIdCounter++;
      pos = {
        left: this.x - 4,
        top: this.y - 4
      };
      this.el = jq('<div/>').addClass('marking').css(pos).attr({
        id: this.id,
        draggable: true
      }).bind('dragend', function() {
        return log('dragend');
      }).bind('dragstart', function() {
        self.el.css('opacity', '0.4');
        draggedMarking = self;
        return log("dragstart");
      });
    }
    Marking.prototype.move = function(x, y) {
      var pos;
      pos = {
        left: x - 4,
        top: y - 4
      };
      return this.el.css(pos);
    };
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
      return $markings.bind('dragover', function() {
        canvas.className = 'ondragover';
        return false;
      }).bind('dragleave', function() {
        canvas.className = '';
        return false;
      }).bind('drop', function(e) {
        canvas.className = '';
        e.preventDefault();
        if (e.originalEvent.dataTransfer.files.length > 0) {
          return loadLocalImage(e.originalEvent.dataTransfer.files[0]);
        } else if (draggedMarking) {
          log(draggedMarking);
          draggedMarking.move(e.layerX, e.layerY);
          return draggedMarking.el.css('opacity', '1.0');
        }
      });
    };
    initManualCounter = function() {
      $markings.click(function(e) {
        if (e.ctrlKey && markings.length > 0) {
          return removeMarking(e.layerX, e.layerY);
        } else {
          return addMarking(e.layerX, e.layerY);
        }
      });
      return $markings.bind('contextmenu', function(e) {
        e.preventDefault();
        return removeMarking(e.layerX, e.layerY);
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
      if (marking) {
        markings = _.without(markings, marking);
        marking.el.remove();
        return showCellCount();
      }
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
