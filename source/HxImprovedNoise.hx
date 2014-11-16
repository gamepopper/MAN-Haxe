package ;

/**
 * This class uses Ken Perlin's Improved Noise algorithm to generate a procedural pattern to a grid.
 * @author Tim Stoddard
 */
class HxImprovedNoise
{
	private static var p:Array<Int> = [151, 160, 137, 91, 90, 15, 
	131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
	190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
	88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
	102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
	135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
	5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
	223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
	129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
	251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
	49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180];
	
	private static function noise(x:Float, y:Float, z:Float):Float
	{
		var X:Int = Std.int(Math.floor(x) & 255);
		var Y:Int = Std.int(Math.floor(y) & 255);
		var Z:Int = Std.int(Math.floor(z) & 255);
		
		x -= Math.floor(x);
		y -= Math.floor(y);
		z -= Math.floor(z);
		
		var u:Float = fade(x);
		var v:Float = fade(y);
		var w:Float = fade(z);
		
		var A:Int = p[X  ] + Y; var AA:Int = p[A] + Z; var AB:Int = p[A+1] + Z;
		var B:Int = p[X + 1] + Y; var BA:Int = p[B] + Z; var BB:Int = p[B + 1] + Z;
		
		return  lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z), 
										grad(p[BA], x - 1, y, z)),
								lerp(u, grad(p[AB], x, y - 1, z),
										grad(p[BB], x - 1, y - 1, z))),
						lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1),
										grad(p[BA + 1], x - 1, y, z - 1)),
								lerp(u, grad(p[AB + 1], x, y - 1, z - 1),
										grad(p[BB + 1], x - 1, y - 1, z - 1))));
	}
	
	private static function fade(t:Float):Float { return t * t * t * (t * (t * 6 - 15) + 10); }
	private static function lerp(t:Float, a:Float, b:Float):Float { return a + t * (b - a); }
	private static function grad(hash:Int, x:Float, y:Float, z:Float):Float
	{
		var h:Int = hash & 15;
		var u:Float = (h < 8 ? x : y);
		var v:Float = (h < 4 ? y : (h == 12 || h == 14 ? x : z));
		return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
	}
	
	public static function generateFloatMatrix(Columns:Int, Rows:Int, Seed:Int):Array<Array<Float>>
	{
		var matrix:Array<Array<Float>> = InitFloatMatrix(Columns, Rows);
		
		if (Seed < 0) Seed = 0;
		else if (Seed > 256) Seed = 256;
		
		var z:Float = Seed / 256;
		
		for (y in 0...Rows)
		{
			for (x in 0...Columns)
			{
				var X:Float = (x / Columns) + (Math.random()-0.5);
				var Y:Float = (y / Rows) + (Math.random() - 0.5);
				var Z:Float = z + (Math.random() - 0.5);
				var length:Float = Math.sqrt((X*X) + (Y*Y) + (Z+Z));
				matrix[y][x] = (noise(X/length, Y/length, Z/length) + 1) / 2;
			}
		}
		
		return matrix;
	}
	
	public static function generateIntMatrix(Columns:Int, Rows:Int, Seed:Int, NumLevels:Int = 2):Array<Array<Int>>
	{
		var map:Array<Array<Float>> = generateFloatMatrix(Columns, Rows, Seed);
		var matrix:Array<Array<Int>> = InitIntMatrix(Columns, Rows);
		
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
	
	public static function generateMatrixString(Columns:Int, Rows:Int, Seed:Int, NumLevels:Int = 2):String
	{
		return convertMatrixToString(generateIntMatrix(Columns, Rows, Seed, NumLevels));
	}
	
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