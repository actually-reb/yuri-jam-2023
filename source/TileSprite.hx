package;

import flixel.FlxSprite;

enum TileProperty {}

class TileSprite extends FlxSprite implements ZLayer
{
	public var tx:Int;
	public var ty:Int;
	public var zlayer:Int;
	public var properties:Array<TileProperty>; // Maybe should be EnumFlags<T>?

	public function new(game:PlayState, tx, ty)
	{
		super(Global.tilesize * tx, Global.tilesize * ty);
		this.zlayer = 0;
		this.tx = tx;
		this.ty = ty;

		game.addTileSprite(this);
	}

	public function gameUpdate(game:PlayState, elapsed:Float) {}

	public function addProperties(properties:Array<TileProperty>)
	{
		for (p in properties)
		{
			properties.push(p);
		}
	}

	public function move(game:PlayState, x, y)
	{
		game.room.moveSprite(this, x, y);
		this.x = Global.tilesize * this.tx;
		this.y = Global.tilesize * this.ty;
	}
}
