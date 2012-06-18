package;

import nme.Lib;
import org.flixel.FlxGame;
	
class ProjectClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Float = Lib.current.stage.stageWidth;
		var stageHeight:Float = Lib.current.stage.stageHeight;

		#if !flash
		if(Lib.current.stage.dpiScale != 1){
			stageWidth *= Lib.current.stage.dpiScale;
			stageHeight *= Lib.current.stage.dpiScale;
		}
		#end
		
		trace(stageWidth);
		trace(stageHeight);
		var ratioX:Float = stageWidth / 240;
		var ratioY:Float = stageHeight / 320;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), PlayState, ratio, 60, 60);
		forceDebugger = true;

		trace(x, y);
	}
}
