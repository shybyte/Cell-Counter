Filters.grayscale = function (pixels, args) {
    var d = pixels.data;
    for (var i = 0; i < d.length; i += 4) {
        var r = d[i];
        var g = d[i + 1];
        var b = d[i + 2];
        // CIE luminance for the RGB
        // The human eye is bad at seeing red and blue, so we de-emphasize them.
        var v = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        d[i] = d[i + 1] = d[i + 2] = v
    }
    return pixels;
};

Filters.thresholdRG = function (pixels, args) {
    var d = pixels.data;
    var v;
    for (var i = 0; i < d.length; i += 4) {
        var r = d[i];
        var g = d[i + 1];
        var b = d[i + 2];
        if ((r + g )>>1 > args.threshold) {
            v = 255
        } else {
            v = 0
        }
        d[i] = 0;
        d[i + 1] = v ;
        d[i + 2] = 0 ;
        d[i + 3] = v
    }
    return pixels;
}