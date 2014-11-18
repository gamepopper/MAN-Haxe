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
class MazeState extends FlxState
{
	//Tilemap Properties
	var tileSize:Int = 8;
	var width:Int;
	var height:Int;
	
	//Tilemap Data
	var map:FlxTilemap;
	var mapString:String;
	
	//UI
	var title:FlxText;
	var processTime:FlxText;
	var midpointButton:FlxButton;
	var worleyButton:FlxButton;
	var valueButton:FlxButton;
	var mazeButton:FlxButton;
	var rangeButton:FlxButton;
	var landButton:FlxButton;
	var uiGroup:FlxGroup;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.camera.flash(0);
		FlxG.camera.bgColor = FlxColor.WHITE;
		width = Std.int(FlxG.width / tileSize);
		height = Std.int(FlxG.height / tileSize);
		
		uiGroup = new FlxGroup();
		
		title = new FlxText(500, 5, 140, "Randomized Prim Maze", 9);
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
		
		var button:FlxButton = new FlxButton(530, 195, "[G]enerate", generateMap);
		uiGroup.add(button);
		
		midpointButton = new FlxButton(0, 450, "Midpoint", toMidpoint);
		add(midpointButton);
		
		var buttonWidth:Int = Std.int(midpointButton.width);
		midpointButton.x = 15;
		
		worleyButton = new FlxButton(width + 25, 450, "Worley Noise", toWorley);
		add(worleyButton);
		
		valueButton = new FlxButton((width*2) + 35, 450, "Value Noise", toValue);
		add(valueButton);
		
		mazeButton = new FlxButton((width*3) + 45, 450, "Maze", toImproved);
		add(mazeButton);
		
		uiGroup.add(title);
		uiGroup.add(processTime);
		add(uiGroup);
		
		super.create();
	}
	
	function toWorley() { FlxG.switchState(new WorleyState());}
	function toValue() { FlxG.switchState(new ValueState()); }
	function toMidpoint() { FlxG.switchState(new DiamondState()); }
	function toImproved() { FlxG.switchState(new MazeState()); }
	
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
		mapString = HxPrimMaze.generateMatrixString(width, height);
		var timeFinish:Date = Date.now();
		map.loadMapFromCSV(mapString, "assets/images/BasicWorldStrip.png", tileSize, tileSize);
		map.updateBuffers();
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
		valueButton.alpha = 0.5;
		mazeButton.alpha = 0.2;
		if (FlxG.mouse.overlaps(midpointButton)) midpointButton.alpha = 1;
		if (FlxG.mouse.overlaps(worleyButton)) worleyButton.alpha = 1;
		if (FlxG.mouse.overlaps(valueButton)) valueButton.alpha = 1;
		if (FlxG.mouse.overlaps(mazeButton)) mazeButton.alpha = 0.5;
		
		super.update(elapsed);
	}
}