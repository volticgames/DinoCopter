package
{
	import org.flixel.*;
	[SWF(width="640", height="480", backgroundColor="#ba45cf")]
	[Frame(factoryClass="Preloader")]

	public class gamePlatformer extends FlxGame
	{
		public function gamePlatformer()
		{
			super(320,240,statePlaying,2,60,60,true);
			forceDebugger = true;
		}
	}
}
