package  
{
	import org.flixel.*;
	
	public class objPoof extends FlxSprite
	{
		[Embed(source = "data/poof.png")] private var imgFire:Class;
		
		private var notPlayed:Boolean;
		
		public function objPoof() 
		{
			super();
			
			//	There are 2 sorts of coin you can emit - a chunky 32x32 one and a smaller 16x16
			
			//	32x32 coin - uncomment the following 3 lines (and comment-out the 16x16 loadGraphic line) to see it
			//loadGraphic(coin32x32PNG, true, false, 32, 32);
			//width = 18; //	Do this just because the 32x32 coin sprite has a bit of blank space around it
			//offset.x = 6;
			
			//	16x16
			loadGraphic(imgFire, true, false, 8, 8);
			
			addAnimation("spin", [0, 1, 2, 3], 10, false);
			
			exists = false;
			notPlayed = true;
		}
		
		override public function update():void
		{
			super.update();
			if (exists && notPlayed) {
				play("spin", true);
				notPlayed = false;
			}
			if (_curFrame == 3) {
				exists = false;
				notPlayed = true;
			}
		}
		
	}

}