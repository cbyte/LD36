package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

import flixel.FlxCamera;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import lime.math.Vector2;
import flixel.math.FlxVelocity;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
/**
 * ...
 * @author chocobyte, made at LD36 48h competition
 */
class Bot extends FlxSprite
{
	public var playerPositions:Array<FlxPoint> = new Array<FlxPoint>();

	private var speed:Int = 120;
	private var _arrowDecay:Float = 0;
	private var _worldReference:PlayState = null;
	public var emitter:FlxEmitter;
	
	public function new(?X:Float=0, ?Y:Float=0, worldReference:PlayState) 
	{
		super(X, Y);
		_worldReference = worldReference;
		health = 3;
		
		loadGraphic(AssetPaths.character_1__png, true, 32, 32);
		//scale.set(0.8, 0.8);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("walk", [0, 1, 2, 3, 4,3,2,1], 20);
		animation.add("walku", [5,6,7], 12);
		animation.add("walkd", [8,9,10], 12);
		animation.add("idle", [11], 12, false);
		animation.add("idleu", [6], 12);
		animation.add("idled", [12], 12);
		drag.set(speed * 4, speed * 4);
		
		setSize(16, 16);
		offset.set(8, 16);
		centerOrigin();

		
		emitter = new FlxEmitter(x, y);
		emitter.lifespan.set(0.5, 1.2);
		emitter.scale.set(0.05, 0.05, 1, 1, 1, 1, 1.3, 1.3);
		emitter.keepScaleRatio = true;
		emitter.alpha.set(0.2, 0.3, 0, 0.2);
		emitter.start(false);
		
		for (i in 0...20) {
			var p:FlxParticle = new FlxParticle();
			p.loadGraphic(AssetPaths.dust__png, false, 32, 32);
			p.exists = false;
			p.alpha = 0.5;
			emitter.add(p);
		}
		
		_worldReference.add(emitter);
	}
	
	override public function update(elapsed:Float):Void 
	{
		emitter.setPosition(x, y);
		if (playerPositions.length > 0) {
			var posMin:FlxPoint = playerPositions[0];
			var minVal = FlxMath.distanceToPoint(this, playerPositions[0]);
			
			for (i in 0...playerPositions.length){
				var pos = playerPositions[i];
				var dist = FlxMath.distanceToPoint(this, pos);
				if (dist < minVal) {
					minVal = dist;
					posMin = pos;
				}
				
			}
			if(minVal>20){
				FlxVelocity.moveTowardsPoint(this, posMin, 120);
				emitter.emitting = true;
			} else {
				FlxVelocity.moveTowardsPoint(this, new FlxPoint(FlxMath.lerp(x, posMin.x, 0.6), FlxMath.lerp(y, posMin.y, 0.6)), 10);
			}
			if(minVal<250){
				action();
			}
			
			var up, dn, lt, rt;
			if(Math.abs(velocity.y)>Math.abs(velocity.x)) {
				up = velocity.y <= 0;
				dn = velocity.y > 0;
				lt = false;
				rt = false;
			} else {
				lt = velocity.x <= 0;
				rt = velocity.x > 0;
				up = false;
				dn = false;
			}
			
			if (up&&!lt&&!rt) {
				animation.play("walku");
				facing = FlxObject.UP;
			}
			if (dn&&!lt&&!rt) {
				animation.play("walkd");
				facing = FlxObject.DOWN;
			}
			if (lt) {
				facing = FlxObject.LEFT;
			}
			if (rt) {
				facing = FlxObject.RIGHT;
			}
			if (lt || rt) animation.play("walk");

			
		} else {
			emitter.emitting = false;
			switch(facing){
				case FlxObject.LEFT, FlxObject.RIGHT:
					animation.play("idle");
				case FlxObject.UP:
					animation.play("idleu");
				case FlxObject.DOWN:
					animation.play("idled");
			}
		}
		super.update(elapsed);
	}
	
	private function action():Void
	{
		if (_arrowDecay > 1) {
			// if has collected dynamite, throw
			
			
			// else spawn arrow
			FlxG.log.notice(x);
			var angle = 0;
			switch(facing) {
				case FlxObject.UP:
					angle = 270;
				case FlxObject.RIGHT:
					angle = 0;
				case FlxObject.DOWN:
					angle = 90;
				case FlxObject.LEFT:
					angle = 180;
			}
			
			_worldReference.spawnArrow(Std.int(x), Std.int(y), angle, -1, 0);
			_arrowDecay = 0;
		}
		
		_arrowDecay += FlxG.elapsed;
	}
}