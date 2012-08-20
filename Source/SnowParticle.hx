package;

import org.flixel.FlxG;
import org.flixel.FlxParticle;
import org.flixel.FlxSprite;

class SnowParticle extends FlxParticle
{
	override public function onEmit():Void
	{
		x = FlxG.random()*240;

		super.onEmit();
	}
}