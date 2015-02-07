package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import man.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;


using man.HxWorleyNoise.DistanceCalculator;

/**
 * ...
 * @author 
 */

class Main extends Sprite 
{
	var inited:Bool;

	private var midpointMap:Array<Array<Int>>;
	private var valueMap:Array<Array<Int>>;
	private var worleyMap:Array<Array<Int>>;
	private var primMap:Array<Array<Int>>;
	
	private var midpointBitmap:Bitmap;
	private var valueBitmap:Bitmap;
	private var worleyBitmap:Bitmap;
	private var primBitmap:Bitmap;
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		midpointBitmap = new Bitmap();
		valueBitmap = new Bitmap();
		worleyBitmap = new Bitmap();
		primBitmap = new Bitmap();
		
		primBitmap.scaleX = 9.09;
		primBitmap.scaleY = 9.09;
		
		GenerateMaps();
		
		addChild(midpointBitmap);
		addChild(valueBitmap);
		addChild(worleyBitmap);
		addChild(primBitmap);
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}
	
	public function GenerateMaps()
	{
		midpointMap = HxMidpointDisplacement.generateIntMatrix(300, 300, 0.65, 32);
		valueMap = HxValueNoise.generateIntMatrix(300, 300, 7, 0.65, 32);
		worleyMap = HxWorleyNoise.generateIntMatrix(300, 300, 12, 1, DistanceCalculator.Euclidean, 32);
		primMap = HxPrimMaze.generateIntMatrix(33, 33);
		
		SetupBitmap(midpointMap, 50, 50, midpointBitmap, 32);
		SetupBitmap(valueMap, 450, 50, valueBitmap, 32);
		SetupBitmap(worleyMap, 50, 450, worleyBitmap, 32);
		SetupBitmap(primMap, 450, 450, primBitmap, 1);
	}
	
	public function SetupBitmap(array:Array<Array<Int>>, x:Int, y:Int, bitmap:Bitmap, numLevels:Int)
	{
		bitmap.x = x;
		bitmap.y = y;
		
		var data:BitmapData = new BitmapData(array.length, array[0].length);
		
		for (y in 0...array.length)
		{
			for (x in 0...array[0].length)
			{
				var value:Int = array[y][x];
				
				var color:Int = 255 - Std.int((value / numLevels) * 255);
				
				var rgb:Int = 255;
				rgb = (rgb << 8) + color;
				rgb = (rgb << 8) + color;
				rgb = (rgb << 8) + color;
				
				data.setPixel32(x, y, rgb);
			}
		}
		
		bitmap.bitmapData = data;
	}

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}