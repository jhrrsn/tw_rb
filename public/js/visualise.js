var cellSize = $("div#visualisation").width() / 11.3;
var cells = []

var testData = [[56.1022, 0.1234], [51.9653, -3.9231], [55.0192, 1.0499], [51.0202, -3.7234], [53.0495, -5.2309]]
var minX = -8;
var minY = 49;
var nRows = 11;
var nCells = 143;

for (var i = 0; i < nCells; i++) {
  cells.push([]);
}

for (var i = 0; i < testData.length; i++) {
  var x = Math.floor(testData[i][1]);
  var y = Math.floor(testData[i][0]);

  normX = x - minX;
  normY = y - minY;

  var gridPosition = nCells - ((normY + 1) * nRows - normX);
  cells[gridPosition].push([i]);
}

var cellMax = 0;

for (var i = 0; i < cells.length; i++) {
  cellCount = cells[i].length;
  if (cellCount > cellMax) cellMax = cellCount;
}

console.log(cellMax);

var color = d3.scale.linear()
    .domain([0, cellMax])
    .range([240, 0])
    .clamp(true);

var svg = d3.select("div#visualisation").selectAll("svg")
    .data(cells)
    .enter()
      .append("svg")
      .attr("width", cellSize)
      .attr("height", cellSize)
      .attr("class", "cell")
      .style("background-color", function(d) {
        var level = color(d.length);
        return "rgb(" + level + ", " + level + ", " + level + ")";
      });
