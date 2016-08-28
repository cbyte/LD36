package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.math.Vector2;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class PlayState extends FlxState
{
	private var _map:FlxOgmoLoader;
	private var _walls:FlxTilemap;
	private var _wallsOverlay:FlxTilemap;
	private var _ground:FlxTilemap;
	private var _players:FlxTypedGroup<Player>;
	private var _bots:FlxTypedGroup<Bot>;
	private var _playersReference:Array<Player>;
	private var _stuff:FlxTypedGroup<Stuff>;
	private var _food:FlxTypedGroup<Food>;
	private var _arrows:FlxTypedGroup<Arrow>;
	public var viewportWidth:Int = 0;
	public var viewportHeight:Int = 0;
	
	public var numPlayers:Int = 2;
	public var numBots:Int = 2;
	
	private var _hud:Array<Hud>;
	private var _cam:Array<FlxCamera>;
	private var _textFight:FlxText;
	private var _gameStarted:Bool = false;
	
	public var points:Array<Int> = [0, 0, 0, 0];
	
	private var emitter:FlxEmitter;
	
	private var _spawnLocations:Array<Vector2>;
	private var _keys = [
		[FlxKey.W, FlxKey.S, FlxKey.A, FlxKey.D, FlxKey.SPACE],
		[FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.CONTROL],
		[FlxKey.NUMPADEIGHT, FlxKey.NUMPADTWO, FlxKey.NUMPADFOUR, FlxKey.NUMPADSIX, FlxKey.NUMPADPLUS],
		[FlxKey.U, FlxKey.J, FlxKey.H, FlxKey.K, FlxKey.T]
	];
	
	public function new(?points:Array<Int>=null):Void
	{
		super();
		if(points!=null)
			this.points = points;
	}
	
	override public function create():Void
	{

		FlxG.worldBounds.set(0, 0, 1000, 1000);
		_players = new FlxTypedGroup<Player>();
		_bots = new FlxTypedGroup<Bot>();
		_stuff = new FlxTypedGroup<Stuff>();
		_food = new FlxTypedGroup<Food>();
		_spawnLocations = new Array<Vector2>();
		_arrows = new FlxTypedGroup<Arrow>();
		_hud = new Array<Hud>();
		_cam = new Array<FlxCamera>();
		_playersReference = new Array<Player>();
		
		super.create();
		FlxG.mouse.visible = false;
		
		_map = new FlxOgmoLoader(AssetPaths.nomanslandadvanced__oel);
		_walls = _map.loadTilemap(AssetPaths.desert__png, 32, 32, "walls");
		_wallsOverlay = _map.loadTilemap(AssetPaths.desert__png, 32, 32, "overlay");
		_ground = _map.loadTilemap(AssetPaths.ground__png, 64, 64, "ground");
		
		for (i in 1...24) {
			_walls.setTileProperties(i, FlxObject.ANY);
			_wallsOverlay.setTileProperties(i, FlxObject.NONE);
		}
		
		_ground.setTileProperties(0, FlxObject.NONE);
		_ground.setTileProperties(1, FlxObject.NONE);
		
		add(_ground);
		add(_walls);
		add(_stuff);
		add(_food);
		add(_players);
		add(_bots);
		add(_arrows);
		
		add(_wallsOverlay);
		
		_map.loadEntities(loadEntity);
		spawnPlayers();
		
		set_bgColor(FlxColor.fromRGB(33, 160, 252));
		
		FlxG.cameras.fade(FlxColor.BLACK, 0.33, true);

		new FlxTimer().start(1, function(_):Void {
			beginRound();
		});
	}
	
	private function spawnPlayers():Void
	{
		// camera positioning
		var rows = 0, cols = 0;
		switch (numPlayers) {
			case 1:
				rows = 1;
				cols = 1;
			case 2:
				rows = 1;
				cols = 2;
			case 3:
				rows = 1;
				cols = 3;
			case 4:
				rows = 2;
				cols = 2;
			case 6:
				rows = 2;
				cols = 3;
		}
		
		viewportHeight = Std.int(FlxG.height / rows);
		viewportWidth = Std.int(FlxG.width / cols);
		
		FlxG.cameras.reset();
		
		var currCol = 0, currRow = 0;		
		for (i in 0...numPlayers) {
			if (currCol >= cols) {
				currRow++;
				currCol = 0;
			}
			//FlxG.log.notice(i);
			var spawnLocation = Std.random(_spawnLocations.length);
			var camera = new FlxCamera(currCol * viewportWidth, currRow * viewportHeight, viewportWidth, viewportHeight);
			var player = new Player(_spawnLocations[spawnLocation].x + Std.random(5),
									_spawnLocations[spawnLocation].y + Std.random(5), _keys[i], this, i, camera);
			
			camera.follow(player, FlxCameraFollowStyle.TOPDOWN, 10);
			camera.setScrollBounds(0, 1000, 0, 1000);
			FlxG.cameras.add(camera);
			_cam.push(camera);
			_players.add(player);
			_playersReference.push(player);
			
			currCol++;
			var hud = new Hud(numPlayers, rows, cols, this, player);
			hud.set_camera(camera);
			_hud.push(hud);
			add(_hud[_hud.length - 1]);
		}
		
		for(i in 0...numBots) {
			var spawnLocation = Std.random(_spawnLocations.length);
			_bots.add(new Bot(_spawnLocations[spawnLocation].x + Std.random(50), _spawnLocations[spawnLocation].y + Std.random(50), this));
		}
		
		if(numPlayers > 1) {
			for(i in 0...cols) {
				var _sprBar = new FlxSprite().makeGraphic(2, FlxG.height, FlxColor.BLACK);
				_sprBar.x = i*(FlxG.width/cols);
				_sprBar.scrollFactor.set(0, 0);
				add(_sprBar);
			}
			
			for(i in 0...rows) {
				var _sprBar = new FlxSprite().makeGraphic(FlxG.height, 2, FlxColor.BLACK);
				_sprBar.y = i*(FlxG.height/rows);
				_sprBar.scrollFactor.set(0, 0);
				add(_sprBar);
			}
		}
				
		_textFight = new FlxText(viewportWidth /2 -100 , viewportHeight /2 - 20, 200, "", 20);
		_textFight.alignment = "center";
		_textFight.alpha = 0;
		_textFight.scrollFactor.set(0, 0);
		add(_textFight);
	}
	
	public function showMessage(text:String):Void
	{
		_textFight.text = text;
		_textFight.alpha = 1;
		var origY = _textFight.y;
		FlxTween.tween(_textFight, {y: _textFight.y + 20}, 1, {ease: FlxEase.backIn, onComplete: function(_):Void{ 
			_textFight.alpha = 0;
			_textFight.y = origY;
		}});
	}

	public function showMessageLong(text:String):Void
	{
		_textFight.text = text;
		_textFight.alpha = 1;
		var origY = _textFight.y;
		
		FlxTween.tween(_textFight, {y: _textFight.y + 20}, 3, {ease: FlxEase.backIn, onComplete: function(_):Void{ 
			_textFight.alpha = 0;
			_textFight.y = origY;
		}});
	}
	
	public function spawnArrow(x:Int, y:Int, angle:Int, playerId:Int, strength:Int):Void
	{
		if (!_gameStarted){
			return;
		}
		var arrow:Arrow = new Arrow(x, y, angle, playerId, strength);
		_arrows.add(arrow);
	}
	
	public function beginRound():Void
	{
		showMessage("PREPARE TO FIGHT");
		var i = 3;
		new FlxTimer().start(1.1, function(_):Void{
			if (i == 0){
				showMessage("FIGHT");
				_gameStarted = true;
			} else {
				showMessage(Std.string(i));
				i--;
			}
		}, 4);
	}
	
	public function arrowHitWall(arrow:Arrow, _):Void
	{
		arrow.kill();
	}

	public function arrowHitPlayer(arrow:Arrow, player:Player):Void
	{
		if (arrow.owner == player.playerId) {
			return;
		}
		
		player.health -= 1;
		// TODO: show player was hurt
		_cam[player.playerId].flash(FlxColor.RED, 0.33);
		
		if (player.health <= 0) {
			player.emitter.emitting = false;
			player.kill();
			_cam[player.playerId].fade(FlxColor.RED);
			if(arrow.owner>=0){
				_hud[arrow.owner].show("+1");
				this.points[arrow.owner]++;
			}
		} else {
			if(arrow.owner>=0){
				_hud[arrow.owner].show("HIT");
			}
		}
		arrow.kill();
		
		// check if all players are dead
		checkWinCondition();
	}
	
	public function checkWinCondition():Void
	{
		var countAlive:Int = 0;
		var countPlayerAlive:Int = 0;
		_players.forEachAlive(function (_):Void {countAlive++; countPlayerAlive++; });
		_bots.forEachAlive(function (_):Void {countAlive++; });
		
		
		if (countAlive == 1 && countPlayerAlive == 1) {
			
			var alivePlayer = _players.getFirstAlive();
			showMessage('PLAYER ${alivePlayer.playerId+1} WON');
			new FlxTimer().start(3, function(_):Void {
				FlxG.switchState(new MenuState(this.points, numPlayers, numBots));
			});
		} else if (countPlayerAlive==0) {
			// bot won
			showMessage('DRAW');
			new FlxTimer().start(3, function(_):Void {
				FlxG.switchState(new MenuState(this.points, numPlayers, numBots));
			});
		}
	}

	public function arrowHitBots(arrow:Arrow, bot:Bot):Void
	{
		
		bot.health -= 1;
		
		if (bot.health <= 0) {
			bot.emitter.emitting = false;
			bot.kill();
			
			if(arrow.owner>=0){
				_hud[arrow.owner].show("+1");
				this.points[arrow.owner]++;
			}
		} else {
			if(arrow.owner>=0){
				_hud[arrow.owner].show("HIT");
			}
		}
		arrow.kill();
		checkWinCondition();
	}
	
	public function playerHitFood(player:Player, food:Food):Void
	{
		if (player.health == 3) {
			return;
		}
		player.health++;
		_hud[player.playerId].show("YUM!");
		food.kill();
	}
	
	private function loadEntity(name:String, data:Xml):Void
	{
		var x = Std.parseInt(data.get("x"));
		var y = Std.parseInt(data.get("y"));
		
		switch(name) {
			case "Player":
				_spawnLocations.push(new Vector2(x, y));
				
			case "StuffBig":
				_stuff.add(new Stuff(x, y, true, Std.parseInt(data.get("etype"))));
			
			case "StuffSmall":
				_stuff.add(new Stuff(x, y, false, Std.parseInt(data.get("etype"))));
			case "Food":
				_food.add(new Food(x, y));
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		sortSprites();
		super.update(elapsed);
		FlxG.collide(_players, _walls);
		FlxG.collide(_bots, _walls);
		FlxG.collide(_players, _stuff);
		FlxG.collide(_bots, _stuff);
		FlxG.collide(_bots, _bots);
		FlxG.overlap(_players, _food, playerHitFood);
		FlxG.collide(_food, _walls);
		
		FlxG.collide(_arrows, _walls, arrowHitWall);
		FlxG.collide(_arrows, _players, arrowHitPlayer);
		FlxG.collide(_arrows, _bots, arrowHitBots);
		_bots.forEachAlive(function(bot:Bot):Void {
			var visPlayers:Array<FlxPoint> = new Array<FlxPoint>();
			_players.forEachAlive(function(pl:Player):Void {
				if (_walls.ray(bot.getMidpoint(), pl.getMidpoint())) {
					// sees a player
					visPlayers.push(pl.getMidpoint());
				}
			});
			bot.playerPositions = visPlayers;
		});
	}
	
	private function sortSprites():Void
	{
		_players.sort(FlxSort.byY);
		_bots.sort(FlxSort.byY);
		_stuff.sort(FlxSort.byY);
		//members.sort(FlxSort.byY);
	}
}