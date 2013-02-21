package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ME
	 */
	public class objPlayerBullet extends FlxSprite
	{
		
		[Embed(source = "data/Fire.png")] public var imgFire:Class;
		
		public function objPlayerBullet(x:uint,y:uint,xspeed:Number,yspeed:Number) 
		{
			super(x,y);
			loadGraphic(imgFire, false, false, 4, 4);
			
			velocity.x = xspeed;
			velocity.y = yspeed;
			exists = false;
			
		}
		
		override public function update():void {
			super.update();
			
			if (!onScreen()) {
				kill();
				trace("leftscreen");
			}
		}
		
	}

}