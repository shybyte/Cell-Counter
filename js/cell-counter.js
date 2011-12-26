(function() {
  var Marking, checkAPIsAvailable, draggedMarking, initCellCounter, markingsIdCounter;
  markingsIdCounter = 0;
  draggedMarking = null;
  Marking = (function() {
    function Marking(x, y) {
      var self;
      this.x = x;
      this.y = y;
      self = this;
      this.id = markingsIdCounter++;
      this.el = jq('<div/>').addClass('marking').attr({
        id: this.id,
        draggable: true
      }).bind('dragend', function() {
        return log('dragend');
      }).bind('dragstart', function() {
        self.el.css('opacity', '0.4');
        draggedMarking = self;
        return log("dragstart");
      });
      this.move(this.x, this.y);
    }
    Marking.prototype.move = function(x, y) {
      var pos;
      this.x = x;
      this.y = y;
      pos = {
        left: x - 4,
        top: y - 4
      };
      return this.el.css(pos);
    };
    return Marking;
  })();
  initCellCounter = function() {
    var $fadeThresholdImage, $markings, $threshold, addMarking, canvas, changeFading, ctx, ctxFiltered, currentImg, filterImage, filteredCanvas, findNearestMarking, init, initDragAndDrop, initManualCounter, loadImage, loadLocalImage, markings, removeMarking, showCellCount;
    $threshold = jq('#threshold');
    $fadeThresholdImage = jq('#fadeThresholdImage');
    currentImg = null;
    canvas = $('mainCanvas');
    filteredCanvas = $('filteredCanvas');
    ctx = canvas.getContext('2d');
    ctxFiltered = filteredCanvas.getContext('2d');
    markings = [];
    $markings = jq('#markings');
    init = function() {
      initDragAndDrop();
      initManualCounter();
      loadImage('images/nora1.jpg');
      $threshold.change(filterImage);
      return $fadeThresholdImage.change(changeFading);
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
          draggedMarking.el.css('opacity', '1.0');
          return draggedMarking = null;
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
    changeFading = function() {
      var v, v1, v2;
      v = $fadeThresholdImage.val() / 128;
      if (v < 1) {
        v1 = 1;
        v2 = v;
      } else {
        v1 = 2 - v;
        v2 = 1;
      }
      jq('#mainCanvas').css('opacity', v1);
      return jq('#filteredCanvas').css('opacity', v2);
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
        currentImg = img;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        return filterImage();
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
    filterImage = function() {
      var filteredImage;
      filteredCanvas.width = currentImg.width;
      filteredCanvas.height = currentImg.height;
      filteredImage = Filters.filterImage(Filters.thresholdRG, currentImg, {
        threshold: $threshold.val()
      });
      return ctxFiltered.putImageData(filteredImage, 0, 0);
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
