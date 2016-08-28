package;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import lime.math.Vector2;
import flixel.util.helpers.FlxBounds;
import flixel.system.FlxSound;
/**
 * ...
 * @author chocobyte, made at LD36 48h competition
 */
class Player extends FlxSprite
{
	private var _keys = [FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.CONTROL];
	private var speed = 200;
	private var _worldreference:PlayState = null;
	public var playerId:Int;
	private var _angle:Int;
	private var _arrowDecay:Float = 0;
	public var _cameraReference:FlxCamera;
	public var emitter:FlxEmitter;
	
	public function new(?X:Float=0, ?Y:Float=0, keys:Array<FlxKey>, worldReference:PlayState, id:Int, cameraReference:FlxCamera) 
	{
		_worldreference = worldReference;
		_cameraReference = cameraReference;
		playerId = id;
		
		super(X, Y);
		
		if(keys != null) {
			_keys = keys;
		}
		
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
		
		_worldreference.add(emitter);
		
	}
	
	
	override public function update(elapsed:Float):Void 
	{
		emitter.setPosition(x, y);
		movement();
		action();
		
		super.update(elapsed);
	}
	
	private function movement():Void
	{
		var up = FlxG.keys.anyPressed([_keys[0]]);
		var dn = FlxG.keys.anyPressed([_keys[1]]);
		var lt = FlxG.keys.anyPressed([_keys[2]]);
		var rt = FlxG.keys.anyPressed([_keys[3]]);
		
		var angle:Int = 0;
		
		if (up) angle = 270;
		if (rt) angle = 0;
		if (dn) angle = 90;
		if (lt) angle = 180;
		if (up && rt) angle = 315;
		if (rt && dn) angle = 45;
		if (dn && lt) angle = 135;
		if (lt && up) angle = 225;
		
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
		
		if (up || rt || dn || lt)
		{
			emitter.emitting = true;
			_angle = angle;
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), angle);
			
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
	}
	
	private function action():Void
	{
		if (FlxG.keys.anyPressed([_keys[4]]) && _arrowDecay > 1/2) {			
			// spawn arrow
			_worldreference.spawnArrow(Std.int(x), Std.int(y), _angle, playerId, 0);
			_arrowDecay = 0;
		}
		
		_arrowDecay += FlxG.elapsed;
	}
}