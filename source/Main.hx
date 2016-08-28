package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		var game = new FlxGame(640, 360, MenuState, 1, 60, 60, false, true);
		addChild(game);
	}
}