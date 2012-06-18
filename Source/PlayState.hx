package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;
import org.flixel.FlxGroup;
import org.flixel.FlxEmitter;
import org.flixel.FlxParticle;
import org.flixel.FlxSound;
import org.flixel.FlxPoint;
import org.flixel.FlxObject;

import nme.Lib;

import nme.ui.Accelerometer;

class PlayState extends FlxState
{
	private var bg1:FlxSprite;
	private var bg2:FlxSprite;

	private var player:FlxSprite;
	private var obstacles:FlxGroup;
	private var fences:FlxGroup;
	private var rocks:FlxGroup;
	private var gates:FlxGroup;

	private var lost:Bool;
	private var endSprite:FlxSprite;
	public var dist:Float;
	private var win:Bool;
	private var winDistance:Float;

	private var avalancheEmitter:FlxEmitter;
	private var grayPixel:FlxParticle;
	public var avalancheEvolution:Float;
	private var avalancheAccel:Float;

	private var particleLimit:Float;

	private var notifier:FlxSprite;
	private var jumpNotifier:FlxSprite;
		
	private var maxXSpeed:Float;
	private var maxSpeed:Float;
	private var stdAccel:Float;

	public var ySpeed:Float;
	private var xSpeed:Float;

	private var boost:Bool;
	private var maxBoostSpeed:Float;
	public var distanceTraveled:Float;

	private var obstacleInterval:Float;
	private var obstacleIntDeviation:Float;

	private var nextInterval:Float;

	private var gravity:Float;
	public var jumpHeight:Float;
	private var jumpSpeed:Float;
	private var jumping:Bool;

	override public function create():Void
	{
		lost = false;
		dist = 35;
		winDistance = 20000;
		avalancheEvolution = 0;
		avalancheAccel = 3;

		particleLimit = 1000;

		maxXSpeed = 200;
		maxSpeed = 500;
		stdAccel = 40;

		ySpeed = 100;
		xSpeed = 0;

		boost = false;
		maxBoostSpeed = 600;
		distanceTraveled = 0;

		obstacleInterval = 800;
		obstacleIntDeviation = 100;

		nextInterval = 0;

		gravity = -70;
		jumpHeight = 0;
		jumpSpeed = 0;
		jumping = true;

		/*REAL CODE FROM HERE*/
		#if flash
		Assets.getSound("assets/music.mp3").play(0.0,-1);
		#else
		Assets.getSound("assets/music.wav").play(0.0, -1);
		#end
		fences = new FlxGroup();
		obstacles = new FlxGroup();
		rocks = new FlxGroup();



		bg1 = new FlxSprite(0,0,"assets/bg.png");
		bg2 = new FlxSprite(0,320, "assets/bg.png");
		this.add(bg1);
		this.add(bg2);

		setupFences();
		add(obstacles);
		add(fences);
		add(rocks);

		avalancheEmitter = new FlxEmitter(0,5, cast(particleLimit, Int));
		for(i in 0...cast(avalancheEmitter.maxSize/4, Int)){
			grayPixel = new SnowParticle();
			grayPixel.makeGraphic(32, 32, 0xFFEEEEEE);
			grayPixel.visible = false;
			avalancheEmitter.add(grayPixel);

			grayPixel = new SnowParticle();
			grayPixel.makeGraphic(32, 32, 0xFFEEEEEE);
			grayPixel.visible = false;
			avalancheEmitter.add(grayPixel);

			grayPixel = new SnowParticle();
			grayPixel.makeGraphic(2, 2, 0xFF333333);
			grayPixel.visible = false;
			avalancheEmitter.add(grayPixel);

			grayPixel = new SnowParticle();
			grayPixel.makeGraphic(32, 32, 0xFF666666);
			grayPixel.visible = false;
			avalancheEmitter.add(grayPixel);
		}
		

		notifier = new FlxSprite(34,295);
		notifier.makeGraphic(16,5, 0xFFFFFFFF);
		notifier.color = 0xFFFF0000;
		notifier.visible = false;
		add(notifier);

		jumpNotifier = new FlxSprite(34, 295);
		jumpNotifier.makeGraphic(16,5,0xFFFFFFFF);
		jumpNotifier.color = 0xFFFF9900;
		jumpNotifier.visible = false;
		add(jumpNotifier);

		player = new Player(110,75);
		FlxG.watch(this, "ySpeed");
		FlxG.watch(this, "avalancheEvolution");
		FlxG.watch(this, "dist");
		FlxG.watch(this, "distanceTraveled");
		FlxG.watch(this, "jumpSpeed");
		FlxG.watch(FlxG, "elapsed");

		add(player);

		this.add(avalancheEmitter);
		avalancheEmitter.start(false, 0.5, .005);

		super.create();
	}

	private function setupFences():Void
	{
		for(i in 0...40){
			var img:String = "assets/fence.png";
			if(i%20 == 0){
				img = "assets/fenceBlock.png";
			}
			var fenceLeft:FlxSprite = new FlxSprite(0,16*i, img);
			var fenceRight:FlxSprite = new FlxSprite(224,16*i, img);

			fences.add(fenceLeft); fences.add(fenceRight);
		}
	}

	private function updateBg():Void
	{
		bg2.y -= ySpeed*FlxG.elapsed;
		bg1.y -= ySpeed*FlxG.elapsed;

		if(bg2.y <= 0){
				bg1.y = bg2.y;
				bg2.y += 320;
		}

		
	}

	private function updatePlayer():Void
	{
		if((FlxG.keys.justPressed("SPACE") || FlxG.mouse.justPressed()) && !jumping){
			jumping = true;
			jumpSpeed = 30;
		}

		if(jumping){
			jumpHeight += jumpSpeed*FlxG.elapsed;
			jumpSpeed += gravity*FlxG.elapsed;

			var sc:Float = 1 + jumpHeight / 20;
			player.scale.x = sc;
			player.scale.y = sc;

			if(jumpHeight <= 0){
				jumpHeight = 0;
				jumping = false;
				//FlxG.play(LandSnd,0.5);
				Assets.getSound("assets/Land.mp3").play(0.0,0);
				player.scale.x = 1;
				player.scale.y = 1;
			}
		}

		if(!jumping){
				if(FlxG.keys.justPressed("LEFT")) Assets.getSound("assets/turn_sound.mp3").play(0.0,0);
				if(FlxG.keys.justPressed("RIGHT")) Assets.getSound("assets/turn_sound.mp3").play(0.0,0);

			if(FlxG.keys.LEFT)
			{
				xSpeed -=5;
				player.facing = FlxObject.LEFT;
				//player.velocity.x -= 5;
			}
			else if(FlxG.keys.RIGHT)
			{
				player.facing = FlxObject.RIGHT;
				xSpeed +=5;
				//player.velocity.x += 5;
			
			}
			#if !flash
			else if(nme.sensors.Accelerometer.isSupported){
				xSpeed = Accelerometer.get().x * 300;
			}
			#end
			else {
				if(xSpeed > 10 || xSpeed < -10){
					xSpeed -= xSpeed*FlxG.elapsed*2;
				}
			}
		}

		if(xSpeed > maxXSpeed) xSpeed = maxXSpeed;
		if(xSpeed < -maxXSpeed) xSpeed = -maxXSpeed;

		player.x += xSpeed*FlxG.elapsed;
		player.angle = -xSpeed/maxXSpeed * 9;
	}
	
	override public function destroy():Void
	{	
		super.destroy();
	}

	private function updateObstacles():Void
		{
			nextInterval -= ySpeed*FlxG.elapsed;
			var usedNotifier:Bool = false;
			var usdJumpNotifier:Bool = false;

			var rockCount:Int = 0;
			var topHeight:Int = -1;
			var notifierStart:Int = 0;
			for(i in 0...rocks.length){
				var rock:FlxSprite = cast(rocks.members[i], FlxSprite);
				rock.y -= ySpeed*FlxG.elapsed;
				if(rock.y < 16) rock.kill();
				if(rock.y < 300) continue;

				if(rockCount == 0){
					rockCount++;
					topHeight = Math.round(rock.y);
					notifierStart = Math.round(rock.x);
				}else{
					//FlxG.log(topHeight +","+ int(rocks.members[i].y));
					if(topHeight == Math.floor(rock.y)){
						rockCount++;
					}else{
						jumpNotifier.x = notifierStart;
						jumpNotifier.visible = true;
						//FlxG.log(rockCount);
						jumpNotifier.scale.x = rockCount;
						usdJumpNotifier = true;
						//jumpNotifier.makeGraphic(16*rockCount, 5);
					}
				}
			}

			if(rockCount == 0){
				jumpNotifier.visible = false;
			}else if(!usdJumpNotifier){
				jumpNotifier.x = notifierStart;
				jumpNotifier.visible = true;
				//FlxG.log(rockCount);
				jumpNotifier.makeGraphic(16*rockCount, 5, 0xFFFF9900);
				usdJumpNotifier = true;
			}

			for(i in 0...obstacles.length){
				var obstacle:FlxSprite = cast(obstacles.members[i], FlxSprite);
				if(obstacle.y < 16) obstacle.kill();				
				obstacle.y -= ySpeed*FlxG.elapsed;

				if(obstacle.y > 300){
					notifier.visible = true;
					usedNotifier = true;
					notifier.x = obstacle.x;
				}

				if(!usedNotifier) notifier.visible = false;
			}

			if(nextInterval <= 0){
				var treeOffs:Float = FlxG.random()*(obstacleIntDeviation/2) - obstacleIntDeviation;
				obstacles.add(new FlxSprite(FlxG.random()*192 + 16, player.y + obstacleInterval + treeOffs, "assets/pinetree.png"));

				if(FlxG.random() >= 0.75){
					var s:Int = Math.round(FlxG.random()*5 + 2);
					var rockStart:Int = 0;
					var offs:Float = FlxG.random()*200 - 400;
					do{
						rockStart = Math.round(FlxG.random()*192 + 16);
					}while(rockStart > 224 - 16*s);

					for(j in 0...s)
					{
						rocks.add(new FlxSprite(rockStart+16*j, player.y + obstacleInterval + offs, "assets/rock.png" ));
					}
				}

				nextInterval = 400;
			}
		}

	private function updateFences():Void
	{
		for(i in 0...fences.length){
			var fence:FlxSprite = cast(fences.members[i], FlxSprite);
			fence.y -= ySpeed*FlxG.elapsed;
			if(fence.y < -16) fence.y += 640;
		}
	}

	override public function update():Void
	{
		if(lost){
				avalancheEmitter.y += 300*FlxG.elapsed;
				endSprite.alpha += (400/500) * FlxG.elapsed;

				if(endSprite.alpha >= 1) FlxG.switchState( new EndState(false) );
				super.update();
				return;
			}

			if(win){
				if(ySpeed <= 0){
					endSprite.alpha += 0.25 * FlxG.elapsed;
					FlxG.music.volume = 1 - endSprite.alpha;
					if(endSprite.alpha >= 1) FlxG.switchState(new EndState(true));
					return;
				}else{
					ySpeed -= FlxG.elapsed*stdAccel*2;
					player.y += FlxG.elapsed*ySpeed/16;
				}
			}
			ySpeed += FlxG.elapsed*stdAccel;
			distanceTraveled += FlxG.elapsed*ySpeed;

			if(!boost){
				if(ySpeed > maxSpeed) ySpeed = maxSpeed;
			}else{
				if(ySpeed > maxBoostSpeed) ySpeed = maxBoostSpeed;
			}

		updateBg();
		updatePlayer();

		updateObstacles();
		updateFences();

		if(!jumping || jumpHeight < 1.5)
			FlxG.overlap(player, rocks, hit);
			
		FlxG.overlap(player, obstacles, hit);

		FlxG.overlap(player, fences, hitFence);

		if(!win){

			avalancheEmitter.y = 25 - (ySpeed/maxBoostSpeed)*(100 - avalancheEvolution);

			player.y = 50 + ((ySpeed - 50 - avalancheEvolution)/maxBoostSpeed)*30;
			
			dist = player.y - avalancheEmitter.y;

			avalancheEvolution += (avalancheAccel/(dist/50))*FlxG.elapsed;

		}

		if(dist < 30 && !win){
				lost = true;
				FlxG.shake();
				endSprite = new FlxSprite(0,0);
				endSprite.makeGraphic(240, 320, 0xFFFFFFFF);
				endSprite.alpha = 0;
				add(endSprite);
		}

		if(distanceTraveled>=winDistance && !win){
				win = true;
				endSprite = new FlxSprite(0,0);
				endSprite.makeGraphic(240, 320, 0xFFFFFFFF);
				endSprite.alpha = 0;
				add(endSprite);
		}

		super.update();
	}

	private function hitFence(player:FlxObject, obstacle:FlxObject):Void
		{
			player.x -= xSpeed * FlxG.elapsed;

			xSpeed /= 2;
			xSpeed = -xSpeed;
			
			if(!player.flickering){
				Assets.getSound("assets/hurt_sound.mp3").play(0.0,0);
				ySpeed -= 50;
			}

			player.flicker();
		}

	function hit(player:FlxObject, obstacle:FlxObject):Void
	{
		if(player.flickering) return;
		ySpeed /= 2;
		Assets.getSound("assets/hurt_sound.mp3").play(0.0,0);
		if(ySpeed < 10) ySpeed = 10;

		player.flicker();
	}
}