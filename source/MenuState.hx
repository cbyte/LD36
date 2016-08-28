package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxSlider;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

class MenuState extends FlxState
{
	private var _playState:PlayState;
	
	public var points:Array<Int>;
	
	public function new(?points:Array<Int>=null, ?numPlayer:Int=null, ?numBots:Int=null):Void
	{
		super();
		if (points != null) {
			this.points = points;
		} else {
			this.points = [0, 0, 0, 0];
		}
		_playState = new PlayState(this.points);
		
		if (numPlayer != null) {
			_playState.numPlayers = numPlayer;
		}
		if (numBots != null) {
			_playState.numBots = numBots;
		}
	}
	
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		super.create();
		var _titleText:FlxText = new FlxText(0, 0, 0, "WILD WEST HERO", 30);
		_titleText.screenCenter();
		_titleText.y -= 50;
		_titleText.color = FlxColor.BLACK;
		add(_titleText);
		var _playButton:FlxButton = new FlxButton((FlxG.width/2), 0, "PLAY GAME", clickPlay);
		_playButton.screenCenter();
		add(_playButton);
		set_bgColor(FlxColor.fromRGB(40, 185, 252));
		
		var _playerCount:FlxSlider = new FlxSlider(_playState, "numPlayers", 50, (FlxG.height)-70, 1, 4, 100, 15, 10, 0xFF000000, 0xFFFFFFFF);
		_playerCount.setTexts("PLAYER COUNT");
		add(_playerCount);
		
		var _botCount:FlxSlider = new FlxSlider(_playState, "numBots", 180, (FlxG.height)-70, 1, 5, 100, 15, 10, 0xFF000000, 0xFFFFFFFF);
		_botCount.setTexts("COMPUTER COUNT");
		add(_botCount);
		
		var _highscore:FlxText = new FlxText((FlxG.width)-120, (FlxG.height)-90, 100, 'YOUR SCORE\n\nPLAYER 1: \t${this.points[0]} \nPLAYER 2: \t${this.points[1]} \nPLAYER 3: \t${this.points[2]} \nPLAYER 4: \t${this.points[3]}');
		add(_highscore);
		
	}
	
	private function clickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() {
			FlxG.switchState(_playState);
		});
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}