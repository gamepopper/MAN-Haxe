package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxSlider;
import flixel.addons.tile.FlxCaveGenerator;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class DiamondState extends FlxState
{
	//Tilemap Properties
	var tileSize:Int = 8;
	var width:Int;
	var height:Int;
	
	//Tilemap Data
	var map:FlxTilemap;
	var mapString:String;
	
	//Perlin Noise Parameters
	var rangeModifer:Float = 0.5;
	
	//UI
	var title:FlxText;
	var processTime:FlxText;
	var midpointButton:FlxButton;
	var worleyButton:FlxButton;
	var perlinButton:FlxButton;
	var uiGroup:FlxGroup;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xffe5e500;
		width = Std.int(FlxG.width / tileSize);
		height = Std.int(FlxG.height / tileSize);
		
		uiGroup = new FlxGroup();
		
		title = new FlxText(500, 5, 140, "Midpoint Displacement", 9);
		title.alignment = "center";
		title.color = 0xFF000000;
		
		processTime = new FlxText(500, 180, 140, "");
		processTime.alignment = "center";
		processTime.color = 0xFF000000;
		
		map = new FlxTilemap();
		generateMap();
		add(map);
		
		var uiBG:FlxSprite = new FlxSprite(500, 0);
		uiBG.makeGraphic(140, 220, FlxColor.WHITE);
		uiBG.alpha = 0.85;
		uiGroup.add(uiBG);
		
		var rangeModiferSlider:FlxSlider = new FlxSlider(this, "rangeModifer", 520, 40, 0, 1, 100, 10);
		uiGroup.add(rangeModiferSlider);
		
		var button:FlxButton = new FlxButton(530, 195, "[G]enerate", generateMap);
		uiGroup.add(button);
		
		midpointButton = new FlxButton(0, 450, "Midpoint", toMidpoint);
		//add(midpointButton);
		
		var buttonWidth:Int = Std.int(midpointButton.width);
		midpointButton.x = 15;
		
		worleyButton = new FlxButton(width + 25, 450, "Worley Noise", toWorley);
		add(worleyButton);
		
		perlinButton = new FlxButton((width*2) + 35, 450, "Perlin Noise", toPerlin);
		add(perlinButton);
		
		uiGroup.add(title);
		uiGroup.add(processTime);
		add(uiGroup);
		
		super.create();
	}
	
	function toWorley() { FlxG.switchState(new WorleyState());}
	function toPerlin() { FlxG.switchState(new PerlinState()); }
	function toMidpoint() { FlxG.switchState(new DiamondState());}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	function generateMap():Void
	{
		var timeStart:Date = Date.now();
		mapString = FlxMidpointDisplacement.generateMatrixString(width, height, rangeModifer, 256);
		map.loadMapFromCSV(mapString, "assets/images/" + tileSize + "PixelStrip.png", tileSize, tileSize);
		map.updateBuffers();
		var timeFinish:Date = Date.now();
		processTime.text = "Time: " + ((timeFinish.getTime() - timeStart.getTime()) / 1000) + "s";
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.G)
		{
			generateMap();
		}
		
		uiGroup.visible = FlxG.mouse.overlaps(uiGroup);
		
		midpointButton.alpha = 0.5;
		worleyButton.alpha = 0.5;
		perlinButton.alpha = 0.5;
		if (FlxG.mouse.overlaps(midpointButton)) midpointButton.alpha = 1;
		if (FlxG.mouse.overlaps(worleyButton)) worleyButton.alpha = 1;
		if (FlxG.mouse.overlaps(perlinButton)) perlinButton.alpha = 1;
		
		super.update(elapsed);
	}
}