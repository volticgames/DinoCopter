package  
{
	import org.flixel.*;
	
	public class objFireParticle extends FlxParticle 
	{
		[Embed(source = "data/Fire2.png")] private var imgFire:Class;
		
		public function objFireParticle() 
		{
			super();
			
			//	There are 2 sorts of coin you can emit - a chunky 32x32 one and a smaller 16x16
			
			//	32x32 coin - uncomment the following 3 lines (and comment-out the 16x16 loadGraphic line) to see it
			//loadGraphic(coin32x32PNG, true, false, 32, 32);
			//width = 18; //	Do this just because the 32x32 coin sprite has a bit of blank space around it
			//offset.x = 6;
			
			//	16x16
			loadGraphic(imgFire, true, false, 8, 8);
			
			addAnimation("spin", [1, 2, 3, 4, 5], 10, false);
			
			exists = false;
		}
		
		override public function onEmit():void
		{
			
			play("spin");
		}
		
		override public function update():void
		{
			super.update();
			if (_curFrame == 5) {
				exists = false;
			}
		}
		
	}

}