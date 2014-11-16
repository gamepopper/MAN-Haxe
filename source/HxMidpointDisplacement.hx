package ;

/**
 * This class uses the Midpoint Displacement algorithm to generate a procedural pattern to a grid.
 * @author Tim Stoddard
 */
class HxMidpointDisplacement
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
	 * @param	RangeModifier			The rate at which to decrease the value range of the midpoint.
	 * @return	A float value matrix from [0,1]
	 * */
	public static function generateFloatMatrix(Columns:Int, Rows:Int, RangeModifier:Float = 0.65):Array<Array<Float>>
	{
		var length = Rows;
		if (length < Columns) length = Columns;
		
		length--;
		length |= length >> 1;
		length |= length >> 2;
		length |= length >> 4;
		length |= length >> 8;
		length |= length >> 16;
		length += 2;
		
		//Blank 2D Array
		var matrix:Array<Array<Float>> = InitFloatMatrix(length, length);
		var range:Float = 1;
		
		//Set Values for all four corners
		matrix[0][0] = Math.random();
		matrix[Rows-1][0] = Math.random();
		matrix[0][Columns-1] = Math.random();
		matrix[Rows - 1][Columns - 1] = Math.random();
		
		//Stores largest calculated value for normalization
		var max:Float = 0;
		
		var width:Float = length;
		var height:Float = length;
		
		var i:Int = 1;
		while (i < length)
		{
			//Segment Size
			width = length / i;
			height = length / i;
			
			for (y in 0...i)
			{
				for (x in 0...i)
				{
					//Top Left Coordinates per segment
					var left:Int = Math.floor(width * x);
					var top:Int = Math.floor(height * y);
					
					if (left < Columns && top < Rows)
					{
						//Find Midpoint
						var xMid:Int = Math.floor(width * (x + 0.5));
						var yMid:Int = Math.floor(height * (y + 0.5));
						
						//Make sure right and bottom do not go out of bounds
						var right:Int = Math.floor(width * (x +1));
						var bottom:Int = Math.floor(height * (y + 1));
						
						//Make sure right and bottom do not go out of bounds
						if (right > Columns - 1) right = Columns - 1;
						if (bottom > Rows - 1) bottom = Rows - 1;
						
						//Sets midpoint value to average of all four corners.
						matrix[yMid][xMid] = 
							(matrix[top][left] + 
								matrix[bottom][left] + 
								matrix[bottom][right] + 
								matrix[top][right]) / 4;
						
						
						//Adds random value to midpoint
						matrix[yMid][xMid] += ((Math.random()-0.5) * range);
						
						//Set side values to average of adjacent corners
						matrix[top][xMid] = ((matrix[top][left] + matrix[top][right]) / 2) + ((Math.random()-0.5) * range);
						matrix[bottom][xMid] = ((matrix[bottom][left] + matrix[bottom][right]) / 2) + ((Math.random()-0.5) * range);
						matrix[yMid][left] = ((matrix[top][left] + matrix[bottom][left]) / 2) + ((Math.random()-0.5) * range);
						matrix[yMid][right] = ((matrix[top][right] + matrix[bottom][right]) / 2) + ((Math.random()-0.5) * range);
						
						max = Math.max(matrix[yMid][xMid], max);
					}
				}
			}
			
			//Reduces range
			range *= RangeModifier;
			i *= 2;
		}
		
		//Normalizes all values in matrix
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				matrix[y][x] /= max;
			}
		}
		
		return matrix;
	}
	
	public static function generateIntMatrix(Columns:Int, Rows:Int, RangeModifier:Float = 0.65, NumLevels:Int = 2):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows);
		var map:Array<Array<Float>> = generateFloatMatrix(Columns, Rows, RangeModifier);
		NumLevels--;
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				var level:Int = Math.floor(map[y][x] * NumLevels);
				if (level > NumLevels - 1) level = NumLevels - 1;
				if (level < 1) level = 1;
				matrix[y][x] = level;
			}
		}
		
		return matrix;
	}
	
	public static function generateMatrixString(Columns:Int, Rows:Int, RangeModifier:Float = 0.65, NumLevels:Int = 2):String
	{
		return convertMatrixToString(generateIntMatrix(Columns, Rows, RangeModifier, NumLevels));
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
}