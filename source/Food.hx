package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;

/**
 * ...
 * @author chocobyte, made at LD36 48h competition 
 */
class Food extends FlxSprite
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		if (FlxG.random.bool()){
			loadGraphic(AssetPaths.apple__png, false, 32, 32);
		} else {
			loadGraphic(AssetPaths.bottle__png, false, 32, 32);
		}
		
		scale.set(0.5, 0.5);
	}
	
}