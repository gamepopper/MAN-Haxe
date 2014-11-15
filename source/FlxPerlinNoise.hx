package ;

/**
 * This class uses the perlin noise algorithm to generate a procedural pattern to a grid.
 * @author Tim Stoddard
 */
class FlxPerlinNoise
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
	 * Generates a 2-Dimensional Array of Float values of range [0.0-1.0]
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param 	Columns			Amount of columns in the array.
	 * @param	Rows			Amount of rows in the array.
	 * @param	NumOctaves		The amount of passes the algorithm will go through. More octaves means more smooth results.
	 * @param	Persistance		Persistance Value for combining octaves.
	 * @return 	A string that is usuable for FlxTilemap.loadMap()
	 */
	public static function generatePerlinMatrix(Columns:Int, Rows:Int, NumOctaves:Int = 1, Persistance:Float = 0.5):Array<Array<Float>>
	{
		var noise:Array<Array<Float>> = WhiteNoiseMatrix(Columns, Rows);
		var perlin:Array<Array<Float>> = PerlinNoiseMatrix(noise, NumOctaves, Persistance);
		
		return perlin;
	}
	
	/**
	 * Generates a new PerlinMap matrix.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	Persistance				Persistance Value for combining octaves.
	 * @param	NumLevels			 	Number of different values in the final map. (ex: 5 = [0,1,2,3,4])
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 */
	public static function generatePerlinMapMatrix(Columns:Int, Rows:Int, NumOctaves:Int = 1, Persistance:Float = 0.5, NumLevels:Int = 2):Array<Array<Int>>
	{
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows);
		var map:Array<Array<Float>> = generatePerlinMatrix(Columns, Rows, NumOctaves, Persistance);
		NumLevels--;
		
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
	 * Generates a new matrix via generatePerlinMapMatrix() and returns it in a format 
	 * usable by FlxTilemap.load() via convertMatrixToString().
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @param	Persistance				Persistance Value for combining octaves.
	 * @param	NumLevels			 	Number of different values in the final map. (ex: 5 = [0,1,2,3,4])
	 * @return	A matrix string that is usable by FlxTilemap.loadMap()
	 */
	public static inline function generatePerlinMapString(Columns:Int, Rows:Int, NumOctaves:Int = 1, Persistance:Float = 0.5, NumLevels:Int = 2):String
	{
		return convertMatrixToString(generatePerlinMapMatrix(Columns, Rows, NumOctaves, Persistance, NumLevels));
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
	/**
	 * Generates a 2-Dimensional Array of pure noise values.
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	private static function WhiteNoiseMatrix(Columns:Int, Rows:Int):Array<Array<Float>>
	{
		var matrix:Array<Array<Float>> = InitFloatMatrix(Columns, Rows);
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns) 
			{
				matrix[y][x] = Math.random() % 1;
			}
		}
		
		return matrix;
	}
	/**
	 * Smoothens out an array of noise to a specified level.
	 * 
	 * Copied from FlxCaveGenerator.
	 * 
	 * @param	BaseNoise 				A matrix of noise values.
	 * @param	Octave					The level of smoothness. 1 = no smoothing
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	private static function SmoothNoiseMatrix(BaseNoise:Array<Array<Float>>, Octave:Int):Array<Array<Float>>
	{
		var width:Int = BaseNoise[0].length;
		var height:Int = BaseNoise.length;
		
		var matrix:Array<Array<Float>> = InitFloatMatrix(width, height);
		
		var samplePeriod:Int = Std.int(Math.pow(2, Octave));
		var sampleFrequencey:Float = 1 / samplePeriod;
		
		for (y in 0...height)
		{
			matrix.push(new Array<Float>());
			
			var y0:Int = Std.int(y / samplePeriod) * samplePeriod;
			var y1:Int = (y0 + samplePeriod) % height;
			var yBlend = (y - y0) * sampleFrequencey;
			
			for (x in 0...width) 
			{
				var x0:Int = Std.int(x / samplePeriod) * samplePeriod;
				var x1:Int = (x0 + samplePeriod) % width;
				var xBlend = (x - x0) * sampleFrequencey;
				
				var top:Float = Interpolate(BaseNoise[y0][x0], BaseNoise[y0][x1], xBlend);
				var bottom:Float = Interpolate(BaseNoise[y1][x0], BaseNoise[y1][x1], xBlend);
				
				matrix[y][x] = Interpolate(top, bottom, yBlend);
			}
		}
		
		return matrix;
	}
	
	/**
	 * Standard interpolation function.
	 * 
	 * @param	Columns 				Number of columns for the matrix
	 * @param	Rows					Number of rows for the matrix
	 * @return	A cave string that is usable by FlxTilemap.loadMap()
	 * */
	private static function Interpolate(x0:Float, x1:Float, alpha:Float)
	{
		return x0 * (1 - alpha) + alpha * x1;
	}
	
	private static function PerlinNoiseMatrix(BaseNoise:Array<Array<Float>>, numOctave:Int, Persistance:Float = 0.5):Array<Array<Float>>
	{
		var width:Int = BaseNoise[0].length;
		var height:Int = BaseNoise.length;
		
		var smooth:Array<Array<Array<Float>>> = new Array<Array<Array<Float>>>();
		
		var persistance:Float = Persistance;
		
		for (i in 0...numOctave)
		{
			smooth.push(SmoothNoiseMatrix(BaseNoise, i));
		}
		smooth.reverse();
		
		var matrix:Array<Array<Float>> = InitFloatMatrix(width, height);
		var amplitude:Float = 1.0;
		var totalAmplitude:Float = 0.0;
		
		for (i in 0...numOctave)
		{
			amplitude *= persistance;
			totalAmplitude += amplitude;
			
			for (y in 0...height)
			{
				for (x in 0...width) 
				{
					matrix[y][x] += smooth[i][y][x] * amplitude;
				}
			}
		}
		
		for (y in 0...height)
		{
			for (x in 0...width) 
			{
				matrix[y][x] /= totalAmplitude;
			}
		}
		
		return matrix;
	}
}