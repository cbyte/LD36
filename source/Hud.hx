package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * ...
 * @author chocobyte, made at LD36 48h competition 
 */
class Hud extends FlxTypedGroup<FlxSprite>
{
	private var _sprBar:FlxSprite;
	private var _worldReference:PlayState;
	private var _playerReference:Player;
	
	public function new(numPlayers:Int, rows:Int, cols:Int, worldReference:PlayState, playerReference:Player) 
	{
		_playerReference = playerReference;
		_worldReference = worldReference;
		super();
		
	}
	
	public function show(text:String):Void
	{
		var message = new FlxText(0,0, 100, text, 20);
		message.alignment = "center";
		message.alpha = 1;
		message.x = _playerReference.x;
		message.y = _playerReference.y;
		
		FlxTween.tween(message, {y: message.y + 20}, .5, {ease: FlxEase.backIn, onComplete: function(_):Void{ 
			message.kill();
		}});
		
		add(message);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
}