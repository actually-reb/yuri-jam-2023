package;

import flixel.group.FlxGroup.FlxTypedGroup;

class Tile extends FlxTypedGroup<TileSprite>
{
	public function isEmpty()
	{
		return this.countLiving() == -1;
	}

	public inline function isOccupied()
	{
		return !isEmpty();
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
		var tile = get(spr.tx, spr.ty);
		return tile != null && tile.remove(spr) != null;
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
