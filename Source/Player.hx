package;

import org.flixel.FlxSprite;

class Player extends FlxSprite
{
	public function new(x:Float, y:Float){
		super(x, y);
		makeGraphic(10,25,0xFF666666);
		drag.x = 1000;
		maxVelocity.x = 300;
		maxVelocity.y = 0;
		antialiasing = false;
		}
	}