TARGET=../shybyte-github/cell-counter
mkdir $TARGET
echo "Copy stuff..."
cp -r css $TARGET
cp -r images $TARGET
cp -r js $TARGET
cp -r libs $TARGET
cp index.html $TARGET
cp index-dev.html $TARGET
cp manifest.appcache $TARGET
echo "Compress javascripts..."
java -jar buildtools/closure/compiler.jar libs/common.js js/utils.js js/filters.js js/filters-fast.js js/cell-counter.js --js_output_file $TARGET/js/cell-counter.min.js
echo "Combine javascripts..."
cat libs/jquery.min.js libs/jquery.tools.min.js libs/underscore-min.js $TARGET/js/cell-counter.min.js >$TARGET/js/cell-counter-with-libs.min.js