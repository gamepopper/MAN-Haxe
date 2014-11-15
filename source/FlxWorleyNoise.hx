package ;

/**
 * This class uses the cell (Worley) noise algorithm to generate a procedural pattern to a grid.
 * @author Tim Stoddard
 */

enum DistanceCalculator
{
	Euclidean;
	Manhattan;
	Chebyshev;
	Minkowski;
}

class FlxWorleyNoise
{
	/**
	 * Convert a matrix generated via generateCaveMatrix() into data 
	 * that is usable by FlxTilemap.
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param 	Matrix		A matrix of data
	 * @return 	A string that is usuable for FlxTilemap.loadMap()
	 */
	public static function convertMatrixToString(Matrix:Array<Array<Int>>):String
	{
		var mapString:String = "";
		
		for (y in 0...Matrix.length)
		{
			for (x in 0...Matrix[y].length)
			{
				mapString += Std.string(Matrix[y][x]) + ",";
			}
			
			mapString += "\n";
		}
		
		return mapString;
	}
	
	/**
	 * Generates float matrix using the Worley Noise algoritm.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	PointCount				Number of points to randomly generated
	 * @param	F						The Fst closest point to calculate each pixel to
	 * @param	DistanceMethod			Method of calculate the distance between pixels and point
	 * @return	A float value matrix from [0,1]
	 * */
	public static function generateWorleyMatrix(Columns:Int, Rows:Int, PointCount:Int, F:Int, DistanceMethod:DistanceCalculator):Array<Array<Float>>
	{
		var matrix:Array<Array<Float>> = InitFloatMatrix(Columns, Rows);
		
		var points:Array<Point> = new Array<Point>();
		
		if (F < 0) F = 0;
		
		for (i in 0...PointCount)
		{
			points.push(new Point( (Math.random()%1) * Columns, (Math.random()%1) * Rows));
		}
		
		var distanceFunc:Float->Float->Float->Float->Float = EuclideanDistance;
		if (DistanceMethod == Manhattan) distanceFunc = ManhattanDistance;
		else if (DistanceMethod == Chebyshev) distanceFunc = ChebyshevDistance;
		else if (DistanceMethod == Minkowski) distanceFunc = MinkowskiDistance;
		
		var maxDistance:Float = 0;
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				var distance:Array<Float> = new Array<Float>();
				for (i in 0...PointCount)
				{
					var d:Float = distanceFunc(x, y, points[i].x, points[i].y);
					distance.push(d);
				}
				distance.sort(DistanceSort);
				matrix[y][x] = distance[F];
				maxDistance = Math.max(maxDistance,distance[F]);
			}
		}
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				if (!Math.isNaN(matrix[y][x]))
				{
					matrix[y][x] /= maxDistance;
				}
				else
				{
					matrix[y][x] = 0.95;
				}
			}
		}
		
		return matrix;
	}
	
	public static function generateWorleyMatrixSlice(Columns:Int, Rows:Int, PointCount:Int, F:Int, DistanceMethod:DistanceCalculator):Array<Array<Float>>
	{
		var matrix:Array<Array<Float>> = InitFloatMatrix(Columns, Rows);
		var points:Array<Array<Array<Point>>> = new Array<Array<Array<Point>>>();
		
		if (F < 0) F = 0;
		
		var nodeWidth:Float = Columns/8;
		var nodeHeight:Float = Rows/8;
		
		for (y in 0...8)
		{
			points.push(new Array<Array<Point>>());
			for (x in 0...8)
			{
				points[y].push(new Array<Point>());
			}
		}
		
		for (i in 0...PointCount)
		{
			var p:Point = new Point( (Math.random() % 1) * Columns, (Math.random() % 1) * Rows);
			
			points[Std.int(p.y / nodeHeight)][Std.int(p.x / nodeWidth)].push(p);
		}
		
		var distanceFunc:Float->Float->Float->Float->Float = EuclideanDistance;
		if (DistanceMethod == Manhattan) distanceFunc = ManhattanDistance;
		else if (DistanceMethod == Chebyshev) distanceFunc = ChebyshevDistance;
		else if (DistanceMethod == Minkowski) distanceFunc = MinkowskiDistance;
		
		var minDistance:Float = Columns * Rows;
		var maxDistance:Float = 0;
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				var nodeY:Int = Std.int(y / nodeHeight);
				var nodeX:Int = Std.int(x / nodeWidth);
				var distance:Array<Float> = new Array<Float>();
				
				var pointsForNode:Array<Point>;
				
				var range:Int = 1;
				var limit:Int = 5;
				if (PointCount < limit) limit = PointCount;
				
				while (distance.length < limit && range < Columns && range < Rows)
				{
					for (posY in -range...range)
					{
						for (posX in -range...range)
						{
							if ((nodeY + posY) >= 0 && (nodeY + posY) < 8 && (nodeX + posX) >= 0 && (nodeX + posX) < 8)
							{
								pointsForNode = points[nodeY + posY][nodeX + posX];
								
								for (i in 0...pointsForNode.length)
								{
									var d:Float = distanceFunc(x, y, pointsForNode[i].x, pointsForNode[i].y);
									distance.push(d);
								}
							}
						}
					}
					range++;
				}
				distance.sort(DistanceSort);
				
				matrix[y][x] = distance[F];
				if (!Math.isNaN(distance[F]))
				{
					minDistance = Math.min(minDistance, distance[F]);
					maxDistance = Math.max(maxDistance, distance[F]);
				}
			}
		}
		
		trace("Min: " + minDistance);
		trace("Max: " + maxDistance);
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				if (!Math.isNaN(matrix[y][x]))
				{
					matrix[y][x] /= maxDistance;
				}
				else
				{
					matrix[y][x] = 0.95;
				}
			}
		}
		
		return matrix;
	}
	
	/**
	 * Generates int tilemap using the Worley Noise algoritm.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	PointCount				Number of points to randomly generated
	 * @param	F						The Fst closest point to calculate each pixel to
	 * @param	DistanceMethod			Method of calculate the distance between pixels and point
	 * @param	NumLevels				Amount of levels in the tilemap to convert to.
	 * @return	A cave matrix that is usable by FlxTilemap.loadMap()
	 * */
	public static function generateWorleyMapMatrix(Columns:Int, Rows:Int, PointCount:Int, F:Int, DistanceMethod:DistanceCalculator, NumLevels:Int = 2):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows);
		var map:Array<Array<Float>> = generateWorleyMatrix(Columns, Rows, PointCount, F, DistanceMethod);
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				var level:Int = Math.floor(map[y][x] * NumLevels);
				if (level < 0) level = 0;
				if (level > NumLevels - 1) level = NumLevels - 1;
				matrix[y][x] = level;
			}
		}
		
		return matrix;
	}
	
	/**
	 * Generates string tilemap using the Worley Noise algoritm.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	PointCount				Number of points to randomly generated
	 * @param	F						The Fst closest point to calculate each pixel to
	 * @param	DistanceMethod			Method of calculate the distance between pixels and point
	 * @param	NumLevels				Amount of levels in the tilemap to convert to.
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	public static function generateWorleyMapString(Columns:Int, Rows:Int, PointCount:Int, F:Int, DistanceMethod:DistanceCalculator, NumLevels:Int = 2):String
	{
		return convertMatrixToString(generateWorleyMapMatrix(Columns, Rows, PointCount, F, DistanceMethod, NumLevels));
	}
	
	/**
	 * Generates a blank 2-Dimensional Array of type Int.
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	private static function InitIntMatrix(Columns:Int, Rows:Int):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = new Array<Array<Int>>();
		
		for (y in 0...Rows)
		{
			matrix.push(new Array<Int>());
			
			for (x in 0...Columns) 
			{
				matrix[y].push(0);
			}
		}
		
		return matrix;
	}
	
	/**
	 * Generates a blank 2-Dimensional Array of type Float.
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	private static function InitFloatMatrix(Columns:Int, Rows:Int):Array<Array<Float>>
	{
		var matrix:Array<Array<Float>> = new Array<Array<Float>>();
		
		for (y in 0...Rows)
		{
			matrix.push(new Array<Float>());
			
			for (x in 0...Columns) 
			{
				matrix[y].push(0.0);
			}
		}
		
		return matrix;
	}
	
	private static function EuclideanDistance(p0X:Float, p0Y:Float, p1X:Float, p1Y:Float): Float
	{
		var distance:Float = 0;
		var xDifference:Float = p0X - p1X;
		var yDifference:Float = p0Y - p1Y;
		
		distance = Math.sqrt((xDifference * xDifference) + (yDifference * yDifference));
		
		return distance;
	}
	
	private static function ManhattanDistance(p0X:Float, p0Y:Float, p1X:Float, p1Y:Float): Float
	{
		var distance:Float = 0;
		var xDifference:Float = p0X - p1X;
		var yDifference:Float = p0Y - p1Y;
		
		distance = Math.abs(xDifference) + Math.abs(yDifference);
		
		return distance;
	}
	
	private static function ChebyshevDistance(p0X:Float, p0Y:Float, p1X:Float, p1Y:Float): Float
	{
		var distance:Float = 0;
		var xDifference:Float = p0X - p1X;
		var yDifference:Float = p0Y - p1Y;
		
		if (Math.abs(xDifference) == Math.abs(yDifference) || Math.abs(xDifference) < Math.abs(yDifference))
		{
			distance = Math.abs(xDifference);
		}
		else 
		{
			distance = Math.abs(yDifference);
		}
		
		return distance;
	}
	
	private static function MinkowskiDistance(p0X:Float, p0Y:Float, p1X:Float, p1Y:Float): Float
	{
		var distance:Float = 0;
		var xDifference:Float = p0X - p1X;
		var yDifference:Float = p0Y - p1Y;
		
		distance = Math.pow(Math.pow(Math.abs(xDifference), 3) + Math.pow(Math.abs(yDifference), 3), 1/3);
		
		return distance;
	}
	
	private static function DistanceSort(x:Float, y:Float):Int
	{
		if (x == y) return 0;
		else if (x < y) return -1;
		
		return 1;
	}
	
}

class Point
{
	public var x:Float = 0;
	public var y:Float = 0;
	
	public function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}
}