package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author chocobyte, made at LD36 48h competition 
 */
class Stuff extends FlxSprite
{

	public function new(?X:Float=0, ?Y:Float=0, big:Bool=false, type:Int) 
	{
		super(X, Y);
		
		moves = false;
		solid = true;
		var factor = 1 + (1 / (10+(7* Std.random(3))));
		scale.set(factor, factor);
		if(big){
			loadGraphic(AssetPaths.stuffbig__png, true, 96, 96);
			animation.add("0", [0]);
			animation.add("1", [1]);
			animation.add("2", [2]);
			animation.play(Std.string(type));
			width = 60;
			height = 70;
		} else {
			loadGraphic(AssetPaths.stuffsmall__png, true, 64, 64);
			animation.add("0", [0]);
			animation.add("1", [1]);
			animation.add("2", [2]);
			animation.add("3", [3]);
			animation.add("4", [4]);
			animation.add("5", [5]);
			animation.play(Std.string(type));
			width = 20;
			height = 20;
		}
		
		centerOffsets();
		
		set_immovable(true);
	}
	
	override public function update(elapsed:Float):Void 
	{
		//super.update(elapsed);
	}
	
}