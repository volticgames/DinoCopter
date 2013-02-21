package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Ben Follington
	 */
	 
	public class objPlayer extends FlxSprite {
		
		[Embed(source = "data/player.png")] protected var imgPlayer:Class;
		
		protected var _jumpPower:int;
		protected var _aim:uint;
		public var playing:Boolean;
		public var test:uint;
		protected var shooting:Boolean;
		protected var bulletType:uint;
		public var shootTimer:uint;
		
		public function objPlayer(X:uint,Y:uint) {
			x = X;
			y = Y;
			loadGraphic(imgPlayer, true, true,33,32);
			playing = true;
			
			width = 12;
			height = 12;
			offset.x = 10;
			offset.y = 20;
			
			//animations
			addAnimation("idle", [0,1,2,3],8,true);
			addAnimation("shooting", [4,5,6,7],8,true);
			
			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 320;
			_jumpPower = 200;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower/2;
		}
		
		override public function update():void {
			
			if (playing) {
				
				moves = true;
				
				//MOVEMENT
				acceleration.x = 0;
				if(FlxG.keys.A)
				{
					acceleration.x -= drag.x;
				}
				else if(FlxG.keys.D)
				{
					acceleration.x += drag.x;
				}
				if(FlxG.keys.W)
				{
					velocity.y += -_jumpPower/8;
				}
				
				if (FlxG.mouse.x > x) {
					facing = RIGHT;
				} else {
					facing = LEFT;
				}
				
				//ANIMATION
				if (FlxG.mouse.pressed()) {
					play("shooting");
				} else {
					play("idle");
				}
				
			} else {
				moves = false;
			}
			
		}
	}
		
}