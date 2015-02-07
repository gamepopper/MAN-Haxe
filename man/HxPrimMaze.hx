package man ;

class Point2D
{
	public var x:Int;
	public var y:Int;
	public var parent:Point2D;
	
	public function new(X:Int, Y:Int, Parent:Point2D)
	{
		x = X;
		y = Y;
		parent = Parent;
	}
	
	public function GetOpposite():Point2D
	{
		var diffX:Int = x - parent.x;
		var diffY:Int = y - parent.y;
		
		if (diffX != 0) return new Point2D(x + diffX, y, parent);
		if (diffY != 0) return new Point2D(x, y + diffY, parent);
		
		return null;
	}
}

/**
 * This class uses Prim's algorithm to generate a procedural maze to a grid.
 * @author Tim Stoddard
 */
class HxPrimMaze
{	
	public static function generateIntMatrix(Columns:Int, Rows:Int):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows, 1);
		
		var start:Point2D = new Point2D(Std.random(Columns), Std.random(Rows), null);
		matrix[start.y][start.x] = 0;
		
		var walls:Array<Point2D> = new Array<Point2D>();
		
		for (j in -1...2)
		{
			for (i in -1...2)
			{
				if (!(i == 0 && j == 0) && !(i != 0 && j != 0)) 
				{
					if (start.y + j >= 0 && start.y + j < Rows && 
						start.x + i >= 0 && start.x + i < Columns)
					{
						if (matrix[start.y + j][start.x + i] == 1)
							walls.push(new Point2D(start.x + i, start.y + j, start));
					}
				}
			}
		}
		
		var last:Point2D = null;
		while (walls.length != 0)
		{
			var pi:Point2D = walls.splice(Std.random(walls.length), 1)[0];
			var op = pi.GetOpposite();
			
			if (op.y >= 0 && op.y < Rows && 
					op.x >= 0 && op.x < Columns)
			{
				if (matrix[pi.y][pi.x] == 1)
				{
					if (matrix[op.y][op.x] == 1)
					{
						matrix[pi.y][pi.x] = 0;
						matrix[op.y][op.x] = 0;
						
						last = op;
						
						for (j in -1...2)
						{
							for (i in -1...2)
							{
								if (!(i == 0 && j == 0) && !(i != 0 && j != 0)) 
								{
									if (op.y + j >= 0 && op.y + j < Rows && 
										op.x + i >= 0 && op.x + i < Columns)
									{
										if (matrix[op.y + j][op.x + i] == 1) 
											walls.push(new Point2D(op.x + i, op.y + j, op));
									}
								}
							}
						}
					}
				}
			}
		}
		
		matrix[start.y][start.x] = 2;
		matrix[last.y][last.x] = 3;
		
		return matrix;
	}
	
	public static function generateMatrixString(Columns:Int, Rows:Int):String
	{
		return convertMatrixToString(generateIntMatrix(Columns, Rows));
	}
	
	/**
	 * Convert a matrix generated via generateCaveMatrix() into data 
	 * that is usable by FlxTilemap.
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
	 * Generates a blank 2-Dimensional Array of type Int.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	InitValue				Determines the value each element will be set at initialization
	 * @return	A 2D Array of Int.
	 * */
	private static function InitIntMatrix(Columns:Int, Rows:Int, InitValue:Int):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = new Array<Array<Int>>();
		
		for (y in 0...Rows)
		{
			matrix.push(new Array<Int>());
			
			for (x in 0...Columns) 
			{
				matrix[y].push(InitValue);
			}
		}
		
		return matrix;
	}
}