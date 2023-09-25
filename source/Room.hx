package;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class Tile
{
	var sprites:Array<TileSprite> = new Array<TileSprite>();

	public function new() {}

	public function add(spr:TileSprite)
	{
		if (sprites.indexOf(spr) >= 0)
			return;
		sprites.push(spr);
	}

	public function remove(spr:TileSprite)
	{
		return sprites.remove(spr);
	}

	public function length()
	{
		return sprites.length;
	}

	public function isEmpty()
	{
		return sprites.length == 0;
	}

	public inline function isOccupied()
	{
		return !isEmpty();
	}

	public function any(func:TileSprite->Bool)
	{
		for (s in sprites)
		{
			if (func(s))
				return true;
		}
		return false;
	}

	public function all(func:TileSprite->Bool)
	{
		for (s in sprites)
		{
			if (!func(s))
				return false;
		}
		return true;
	}

	public function first(func:TileSprite->Bool)
	{
		for (s in sprites)
		{
			if (func(s))
				return s;
		}
		return null;
	}

	public function filter(func:TileSprite->Bool)
	{
		var list:Array<TileSprite> = new Array<TileSprite>();

		for (s in sprites)
		{
			if (func(s))
				list.push(s);
		}
		return list;
	}

	public function hasType<K>(ObjectClass:Class<K>)
	{
		for (s in sprites)
		{
			if (Std.isOfType(s, ObjectClass))
				return true;
		}
		return false;
	}

	public function getFirst<K>(ObjectClass:Class<K>)
	{
		for (s in sprites)
		{
			if (Std.isOfType(s, ObjectClass))
				return s;
		}
		return null;
	}
}

class Room
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	var data:Array<Tile>;

	public function new(w, h)
	{
		this.width = w;
		this.height = h;

		this.data = new Array<Tile>();

		for (i in (0...(w * h)))
			this.data.push(new Tile());
	}

	public function isOutOfBounds(x, y)
	{
		return (x < 0 || x > this.width || y < 0 || y > this.height);
	}

	public function get(x, y)
	{
		if (isOutOfBounds(x, y))
			return null;
		return data[x + y * this.width];
	}

	public function hasSolid(x, y)
	{
		if (isOutOfBounds(x, y))
			return true;
		return get(x, y).isOccupied();
	}

	public function hasType<K>(ObjectClass:Class<K>, x, y)
	{
		if (isOutOfBounds(x, y))
			return true;
		return get(x, y).hasType(ObjectClass);
	}

	public inline function hasNoSolid(x, y)
	{
		return !hasSolid(x, y);
	}

	public function addSprite(spr:TileSprite)
	{
		get(spr.tx, spr.ty).add(spr);
	}

	public function removeSprite(spr:TileSprite)
	{
		if (isOutOfBounds(spr.tx, spr.ty))
			return false;
		return get(spr.tx, spr.ty).remove(spr);
	}

	public function moveSprite(spr:TileSprite, x, y)
	{
		var newtile = get(x, y);

		if (newtile == null)
			return false;

		if (!removeSprite(spr))
			return false;

		newtile.add(spr);
		spr.tx = x;
		spr.ty = y;

		return true;
	}
}
