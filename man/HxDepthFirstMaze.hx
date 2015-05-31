package man;
import haxe.ds.GenericStack;

private class Cell
{
	public var x:Int;
	public var y:Int;
	
	public function new(X:Int, Y:Int)
	{
		x = X;
		y = Y;
	}
}

/**
 * This class uses Depth-First Search to generate a procedural maze to a grid.
 * Based on code by Daniel Messias
 * @author Tim Stoddard
 */
class HxDepthFirstMaze
{
	public static function generateIntMatrix(Columns:Int, Rows:Int):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows, 1);
		
		var width:Int = Std.int(Columns);
		var height:Int = Std.int(Rows);
		var totalCells = (width - 1) * (height - 1) * 0.25;
		
		var cx:Int = Std.random(width);
		var cy:Int = Std.random(height);
		
		if (cx < cy)
			cx = 1;
		else
			cy = 1;
		
		var stack:GenericStack<Cell> = new GenericStack<Cell>();
		
		var cellVisitedCount:Int = 1;
		var unvisitedCells:Array<Cell> = new Array<Cell>();
		var directions:Array<Cell> = [new Cell( -1, 0), new Cell(1, 0), new Cell(0, -1), new Cell(0, 1)];
		
		var current:Cell = new Cell(cx, cy);
		var next:Cell = new Cell(0, 0);
		var neighbours:Bool;
		
		matrix[current.y][current.x] = 0;
		
		while (cellVisitedCount < totalCells)
		{
			shuffleArray(directions);
			neighbours = false;
			
			for (dir in directions)
			{
				next.x = current.x + dir.x;
				next.y = current.y + dir.y;
				
				if (next.x > 0 && next.x < width - 1 &&
				next.y > 0 && next.y < height - 1 &&
				matrix[next.y + dir.y][next.x + dir.x] != 0)
				{
					stack.add(new Cell(current.x, current.y));
					matrix[next.y][next.x] = matrix[next.y + dir.y][next.x + dir.x] = 0;
					cellVisitedCount++;
					current.x = next.x + dir.x;
					current.y = next.y + dir.y;
					neighbours = true;
					break;
				}
			}
			
			if (!neighbours)
			{
				if (!stack.isEmpty())
					current = stack.pop();
				else
				{
					unvisitedCells = [];
					for (x in 0...width)
					{
						for (y in 0...height)
						{
							if (x % 2 == 0 && y % 2 == 0 && matrix[y][x] != 0)
								unvisitedCells.push(new Cell(x, y));
						}
					}
					current = unvisitedCells[Std.random(unvisitedCells.length)];
				}
			}
		}
		
		matrix[cy][cx] = 2;
		
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
	
	private static function shuffleArray<T>(array:Array<T>)
	{
		var tmp:T;
		var j:Int;
		var i:Int = array.length;
		while (i > 0)
		{
			j = Std.random(i);
			tmp = array[--i];
			array[i] = array[j];
			array[j] = tmp;
		}
	}
}