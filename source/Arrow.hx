package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;

/**
 * ...
 * @author chocobyte, made at LD36 48h competition 
 */
class Arrow extends FlxSprite
{
	public var owner:Int = -1;
	private var _strength:Int = -1;
	private var _speed:Int = 300;

	public function new(?X:Float=0, ?Y:Float=0, angle:Int, playerId:Int, strength:Int) 
	{
		super(X, Y);
		owner = playerId;
		_strength = strength;
		
		loadGraphic(AssetPaths.arrow__png, false, 32, 32);
		this.angle = angle;
		setSize(14, 14);
		offset.set(2,18);
	}
	
	override public function update(elapsed:Float):Void 
	{
		velocity.set(_speed, 0);
		velocity.rotate(FlxPoint.weak(0,0), angle);
		super.update(elapsed);
	}
	
}