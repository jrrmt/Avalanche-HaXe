package;

import org.flixel.FlxState;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxText;

class EndState extends FlxState{
	var win:Bool;

	public function new(Win:Bool){
		super();
		win = Win;
	}

	override public function create():Void
	{
		var sp:FlxSprite = new FlxSprite(0,0);

		sp.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		add(sp);

		var t:FlxText;
		if(win){
			t = new FlxText(0,FlxG.height/2-40,FlxG.width,"You escaped the mighty Avalanche!\nThank you so much for playing!");
		}else{
			t = new FlxText(0,FlxG.height/2-30,FlxG.width,"You were caught in the avalanche!\nTry again!");
		}

		t.size = 16;
		t.color = 0xFF000000;
		t.alignment = "center";
		add(t);
		t = new FlxText(FlxG.width/2-50,FlxG.height-60,100,"Art, Code and Music by\njrrt\nfor LD21 (Escape)");
		t.alignment = "center";
		add(t);
		t.color = 0xFF000000;

		if(win){
			//FlxG.music.stop();
			//FlxG.play(WinSnd,1);
		}else{
			//FlxG.music.stop();
			//FlxG.play(LoseSnd,1);
		}
			
		FlxG.mouse.show();
	}

	override public function update():Void{
		super.update();

		if(FlxG.mouse.justPressed()){
			if(!win){
				FlxG.mouse.hide();
				FlxG.switchState(new PlayState());
			}
		}
	}

}