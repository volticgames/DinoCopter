package  
{
	import org.flixel.*;
	
	public class Coin extends FlxParticle 
	{
		[Embed(source = "data/Fire.png")] private var coin16x16PNG:Class;
		
		public function Coin() 
		{
			super();
			
			//	There are 2 sorts of coin you can emit - a chunky 32x32 one and a smaller 16x16
			
			//	32x32 coin - uncomment the following 3 lines (and comment-out the 16x16 loadGraphic line) to see it
			//loadGraphic(coin32x32PNG, true, false, 32, 32);
			//width = 18; //	Do this just because the 32x32 coin sprite has a bit of blank space around it
			//offset.x = 6;
			
			//	16x16
			loadGraphic(coin16x16PNG, true, false, 16, 16);
			
			addAnimation("spin", [0, 1, 2, 3, 4], 12, true);
			
			exists = false;
		}
		
		override public function onEmit():void
		{
			elasticity = 0.8;
			drag = new FlxPoint(4, 0);
			
			play("spin");
		}
		
		override public function update():void
		{
			super.update();
		}
		
	}

}