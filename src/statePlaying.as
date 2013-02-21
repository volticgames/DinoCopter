package
{
	import org.flixel.*;
	//For access to clipboard
	import flash.system.System;

	public class statePlaying extends FlxState
	{
		//World objects
		public var coins:FlxGroup;
		public var player:objPlayer;
		public var HUD:FlxGroup;
		public var levelData:Array; 
		public var fireDot:objFireParticle;
		public var background:FlxSprite;
		public var arrowSprite:FlxSprite;
		public var singleBullet:objPlayerBullet;
		public var playerBullets:FlxGroup;
		public var poofs:FlxGroup;
		public var timer:FlxTimer;
		
		//The grid we are working on, applies to tileset etc.
		public static const GRID:Number  = 16;
		
		public var emitter:FlxEmitter = new FlxEmitter(200, 200, 100);
		
		//Global vars
		public var camX:Number = 0;
		public var camY:Number = 0;
		
		//HUD
		public var score:FlxText;
		public var status:FlxText;
		public var framesDisplay:FlxText;
		
		//Tilemaps
		public var level:FlxTilemap;
		
		//Images
		[Embed(source = "data/autotiles.png")] protected var imgTiles:Class;
		[Embed(source = "data/coin.png")] protected var imgCoin:Class;
		[Embed(source = "data/fire.png")] protected var imgFire:Class;
		[Embed(source = "data/BG.png")] protected var imgBG:Class;
		[Embed(source = "data/Arrow.png")] protected var imgArrow:Class;
		[Embed(source = "data/level1.csv", mimeType = "application/octet-stream")] private var level1CSV:Class;
		
		//Autotiler
		public var autovals:Array = new Array;
		
		//Autotiler groups
		public var floorTile:Array = [184, 248, 232, 252, 249, 253];
		public var ceilingTile:Array = [143, 159, 207, 139, 142, 223];
		public var rightWallTile:Array = [243, 226, 227, 231, 247, 230];
		public var leftWallTile:Array = [63, 62, 126, 127];
		public var bottomLeftCorner:Array = [15, 14, 30, 31, 94];
		public var topLeftCorner:Array = [120, 60, 121, 124, 56];
		public var topRightCorner:Array = [240, 241, 224, 225];
		public var bottomRightCorner:Array = [131, 199, 195];
		
		//Autotiler flag
		public var levelChanged:Boolean = true;
		
		public var testPath:FlxPath;
		
		public function createHUD():void {
			score = new FlxText(2,2,80);
			score.shadow = 0xff000000;
			score.text = "SCORE: " + (coins.countDead() * 100);
			
			framesDisplay = new FlxText(2, 22, 80);
			framesDisplay.shadow = 0xff000000;
			framesDisplay.text = "COL: " + level.getTile(FlxG.mouse.x / GRID, FlxG.mouse.y / GRID);
			
			status = new FlxText(FlxG.width-160-2,2,160);
			status.shadow = 0xff000000;
			status.alignment = "right";
			switch(FlxG.score)
			{
				case 0: status.text = "Collect coins."; break;
				case 1: status.text = "Aww, you died!"; break;
			}
			
			HUD = new FlxGroup;
			
			HUD.add(status);
			HUD.add(score);
			HUD.add(framesDisplay);
			HUD.setAll("scrollFactor", new FlxPoint(0, 0));
			add(HUD);
		}
		
		public function setupCoins():void {
			//Create coins to collect (see createCoin() function below for more info)
			coins = new FlxGroup();
			
			for (var i:uint = 0; i < level.widthInTiles; i++) {
				for (var j:uint = 0; j < level.heightInTiles; j++) {
					if (level.getTile(i,j) > 0) {		
						if (floorTile.indexOf(updateAutotileValues(i,j)) >= 0) { // Floor tiles
							createCoin(i, (j - 1));
						}
					}
				}
			}
			
			add(coins);
		}
		
		//Magic number degree and radian functions
		public function degToRadFast(deg:Number):Number {
			return deg * 0.0174532925;
		}
		
		public function radtoDegFast(rad:Number):Number {
			return rad / 0.0174532925;
		}
		
		override public function create():void
		{
			var i:Number;
			var j:Number;
			
			//Set the background color to light gray (0xAARRGGBB)
			FlxG.bgColor = 0xffab34fe; 
			
			background = new FlxSprite(0, 0, imgBG);
			background.scrollFactor.x = 0;
			background.scrollFactor.y = 0;
			add(background);
			
			//levelData = new Array;
			//levelData.push(new Array(15,15,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,9,0,0,0,0,0,0,12,14,14,14,14,14,14,14,14,14,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,14,14,9,0,0,12,15,15,11,11,11,11,11,11,11,11,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,15,14,14,15,15,13,0,0,0,0,0,0,0,0,7,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,7,15,15,15,11,11,11,6,0,0,0,0,0,0,0,0,3,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,7,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,7,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,14,9,0,12,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,9,0,0,0,0,7,15,15,15,14,14,14,9,0,0,0,0,0,0,0,0,0,7,15,15,15,15,14,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,9,0,0,7,15,15,11,15,15,15,15,14,14,14,14,14,9,0,0,0,7,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,9,0,7,15,6,0,3,11,11,15,15,15,11,11,11,6,0,0,0,7,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,14,15,13,0,0,0,0,0,3,15,13,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,13,0,12,14,14,14,14,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,15,14,9,0,0,0,0,3,6,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,14,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,11,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,11,15,15,9,0,0,0,0,0,0,0,0,0,0,0,12,15,15,15,15,15,15,15,15,15,13,0,7,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,7,15,6,0,0,0,0,0,0,0,0,0,12,14,15,15,15,15,15,15,15,15,15,15,15,14,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,7,13,0,0,0,0,0,0,0,0,0,0,3,11,11,11,15,15,15,15,11,11,11,15,15,15,15,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,15,6,0,7,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,15,13,0,0,0,3,15,15,15,15,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,0,7,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,6,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,0,7,15,13,0,0,0,0,0,0,12,9,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,15,15,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,15,6,0,0,3,15,13,0,0,0,0,0,0,7,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,0,0,0,7,15,9,0,12,14,14,14,15,15,15,14,9,0,0,0,0,0,0,0,0,0,0,0,3,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,0,0,0,3,15,15,14,15,15,15,15,15,15,15,15,15,14,9,0,0,0,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,15,6,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,13,0,0,0,0,0,0,3,15,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,12,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,14,9,0,0,0,0,0,7,15,11,15,15,15,15,15,15,15,15,15,15,15,9,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,15,14,14,9,0,12,15,13,0,15,11,15,15,15,15,15,15,15,15,15,15,14,9,0,0,0,12,14,15,15,15,15,15,15,15,15,15,15,15,15,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,11,6,0,3,11,15,14,13,0,3,11,11,15,15,15,15,15,15,15,15,15,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,6,0,0,0,0,3,11,11,11,11,11,11,11,11,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,15,15,15,11,15,15,15,15,15,15,15,15,15,15,15,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,15,6,0,3,11,11,11,11,11,11,11,11,11,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,15,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,15,15,14,14,14,14,14,14,14,14,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,11,11,11,11,11,11,11,15,15,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,11,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
			//Create a new tilemap using our level data
			level = new FlxTilemap();
			level.loadMap(new level1CSV,imgTiles,16,16);
			add(level);
			
			//Place coins
			setupCoins();
			
			//Set up HUD
			createHUD();
			
			//Set up camera
			FlxG.camera.setBounds(0,0,1280,1280,true);
			
			for (i = 0; i < 100; i++) {
				emitter.add(new objFireParticle);
			}
			
			add(emitter);
			emitter.setXSpeed( -100, 100)
			emitter.setYSpeed(50, 150);
			
			arrowSprite = new FlxSprite(0,0,imgArrow);
			add(arrowSprite);
						
			//Set up player
			player = new objPlayer(160,90);
			add(player);
			
			singleBullet = new objPlayerBullet(170,100,70,70);
			add(singleBullet);
			
			poofs = new FlxGroup;
			for (i = 0; i < 25; i++) {
				var poof:objPoof = new objPoof();
				poofs.add(poof);
			}
			add(poofs);
			
			playerBullets = new FlxGroup;
			for (i = 0; i < 100; i++) {
				var bullet:objPlayerBullet = new objPlayerBullet(0,0,0,0);
				playerBullets.add(bullet);
			}
			add(playerBullets);
		}
		
		//creates a new coin located on the specified tile
		public function createCoin(X:uint,Y:uint):void
		{
			var coin:FlxSprite = new FlxSprite(X*GRID+3,Y*GRID+2,imgCoin);
			coins.add(coin);
		}
		
		public function getVal(arr:Array, width:uint, x:uint, y:uint):uint {
			return arr[x + y * width];
		}
		
		public function setVal(arr:Array, width:uint, x:uint, y:uint, val:uint):uint {
			arr[x + width * y] = val;
			return val;
		}
		
		public function updateAutotileValues(i:uint, j:uint):uint {
			return setVal(autovals, 40, i, j, 
				int(level.getTile(i-1, j-1) > 0) +
				int(level.getTile(i, j-1) > 0)*2 +
				int(level.getTile(i+1, j-1) > 0)*4 +
				int(level.getTile(i+1, j) > 0)*8 +
				int(level.getTile(i+1, j+1) > 0)*16 +
				int(level.getTile(i, j+1) > 0)*32 +
				int(level.getTile(i-1, j+1) > 0)*64 +
				int(level.getTile(i-1, j) > 0)*128
			);
		}
		
		public function refreshTiles():void {
			
			var i:Number;
			var j:Number;
			
			for (i = 0; i < level.widthInTiles; i++) {
				for (j = 0; j < level.heightInTiles; j++) {
					if (level.getTile(i,j) > 0) {		
						if (floorTile.indexOf(updateAutotileValues(i,j)) >= 0) { // Floor tiles
							level.setTile(i, j, 14);
						} else if (ceilingTile.indexOf(updateAutotileValues(i,j)) >= 0) { // Ceiling tiles
							level.setTile(i, j, 11);
						} else if (rightWallTile.indexOf(updateAutotileValues(i,j)) >= 0) { // Right wall tiles
							level.setTile(i, j, 13);
						} else if (leftWallTile.indexOf(updateAutotileValues(i,j)) >= 0) { // Left wall tiles
							level.setTile(i, j, 7);
						} else if (bottomLeftCorner.indexOf(updateAutotileValues(i,j)) >= 0) { // Left wall tiles
							level.setTile(i, j, 3);
						} else if (topLeftCorner.indexOf(updateAutotileValues(i,j)) >= 0) { // Left wall tiles
							level.setTile(i, j, 12);
						} else if (topRightCorner.indexOf(updateAutotileValues(i,j)) >= 0) { // Left wall tiles
							level.setTile(i, j, 9);
						} else if (bottomRightCorner.indexOf(updateAutotileValues(i,j)) >= 0) { // Left wall tiles
							level.setTile(i, j, 6);
						} else {
							level.setTile(i, j, 15); // Fill tiles
						}
					}
				}
			}
		}
		
		public function exportLevel():void {
			var i:Number;
			var j:Number;
			var levelString:String = "";
			
			for (j = 0; j < level.heightInTiles; j++) {
				for (i = 0; i < level.widthInTiles; i++) {
					if((i == level.widthInTiles - 1) && (j == level.heightInTiles -1)) {
						levelString += String(level.getTile(i, j)) + "";
					} else {
						levelString += String(level.getTile(i, j)) + ",";
					}
				}
				levelString += "\n";
			}
			trace (levelString);
			System.setClipboard(levelString);
		}
		
		public function playerEmitterControl():void {
			if (FlxG.keys.W) {
				emitter.setXSpeed( -100, 100)
				emitter.setYSpeed(50, 150);
			} else {
				emitter.setXSpeed( -50, 50)
				emitter.setYSpeed(10, 70);
			}
		
			if (!emitter.on) {
				emitter.start(true, 0, 0.1, 2);
			}
			
			emitter.x = player.x+6;
			emitter.y = player.y + 4;
		}
		
		override public function update():void
		{
			
			var i:Number;
			var j:Number;
			
			if (FlxG.keys.justPressed("TAB")) {
				player.playing = !player.playing;
			}
			
			
			//Player movement and controls
			if (!player.playing) {
				if (FlxG.mouse.pressed()) {
					if (FlxG.keys.SPACE) {
						level.setTile(FlxG.mouse.x / GRID, FlxG.mouse.y / GRID, 0);
					} else {
						level.setTile(FlxG.mouse.x / GRID, FlxG.mouse.y / GRID, 17);
						level.setTile(FlxG.mouse.x / GRID - 1, FlxG.mouse.y / GRID -1, 17);
						level.setTile(FlxG.mouse.x / GRID -1, FlxG.mouse.y / GRID, 17);
						level.setTile(FlxG.mouse.x / GRID, FlxG.mouse.y / GRID -1, 17);
					}
					levelChanged = true;
				}
				
				// Update Autotiler Values
				if (levelChanged) {
					refreshTiles();
					levelChanged = false;
				}

				//Export level data to clipboard
				if (FlxG.keys.justPressed("S")) {
					exportLevel();
				}
			} else {
				if (FlxG.mouse.pressed()) {
					player.shootTimer += 1;
					
					if (player.shootTimer > 5) {
						if (playerBullets.countLiving() < playerBullets.length-1){
							var currBullet:objPlayerBullet = playerBullets.getFirstAvailable() as objPlayerBullet;
							if (currBullet != null) {
								currBullet.exists = true;
							
								var ang:Number = FlxU.getAngle(FlxG.mouse.getScreenPosition(), player.getScreenXY()) + 180 + Math.random()*10-5
								
								if (FlxG.mouse.x > player.x) {
									currBullet.x = player.x+15;
									currBullet.y = player.y - 6;
								} else {
									currBullet.x = player.x-10;
									currBullet.y = player.y - 6;
								}
								currBullet.velocity.x = Math.cos(degToRadFast(ang - 90)) * 150; 
								currBullet.velocity.y = Math.sin(degToRadFast(ang - 90)) * 150; 
							}
						}
						
						player.shootTimer = 0;
					}
				}
			}
			
			//Update emitter stats
			playerEmitterControl();
			
			arrowSprite.x = player.x - 12 + 32 * Math.cos(degToRadFast(arrowSprite.angle));
			arrowSprite.y = player.y - 16 + 32*Math.sin(degToRadFast(arrowSprite.angle));
			arrowSprite.angle = FlxU.getAngle(FlxG.mouse.getScreenPosition(),player.getScreenXY()) +90;
				
			camX += (player.x - camX)/8;
			camY += (player.y - camY) / 8;
			
			FlxG.camera.focusOn(new FlxPoint(camX, camY));
			
			//Updates all the objects appropriately
			super.update();
			
			//Update the COL text
			framesDisplay.text = "COL: " + getVal(autovals, 40, FlxG.mouse.x / GRID, FlxG.mouse.y / GRID);
		
			//Check if player collected a coin or coins this frame
			FlxG.overlap(coins, player, getCoin);
			FlxG.collide(playerBullets, level, bulletHit);
			
			//Finally, bump the player up against the level
			FlxG.collide(level, player);

			
			//Check for player lose conditions
			if(player.y > 640)
			{
				FlxG.score = 1; //sets status.text to "Aww, you died!"
				FlxG.resetState();
			}
			
		}
		
		//Called whenever the player touches a coin
		public function getCoin(Coin:FlxSprite,Player:FlxSprite):void
		{
			Coin.kill();
			score.text = "SCORE: "+(coins.countDead()*100);
		}
		
		public function bulletHit(one:objPlayerBullet, two:FlxTilemap):void {
			if ((one is objPlayerBullet) && (two is FlxTilemap)) {
				if (poofs.countLiving() < poofs.length-1){
							var currPoof:objPoof = poofs.getFirstAvailable() as objPoof;
							if (currPoof != null) {
								currPoof.exists = true;
								currPoof.x = one.x;
								currPoof.y = one.y;
							}
						}
				one.kill();
			}
		}
		
		//Called whenever the player touches the exit
		public function win(Exit:FlxSprite,Player:FlxSprite):void
		{
			status.text = "Yay, you won!";
			score.text = "SCORE: 5000";
			Player.kill();
		}
	}
}
