package;

import openfl.display.Sprite;
import openfl.events.Event;
import shader.WarterShader;
import openfl.Assets;
import hxnoise.Perlin;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class Main extends Sprite {
	public function new() {
		super();
		stage.color = 0x0;
		// 代码初始化入口
		untyped window.set = reset;
		this.reset(500, 10, 4, 0.2, 0.2, 10);
	}

	/**
	 * 开始渲染
	 * @param size 
	 * @param scale 
	 * @param octaves 
	 * @param persistence 
	 * @param frequency 
	 * @param repeat 
	 */
	private function reset(size:Int, scale:Int, octaves:Int, persistence:Float, frequency:Float, repeat:Int):Void {
		this.removeChildren();
		var bitmapData = new BitmapData(size, size, false, 0x0);
		var perlinNoise:Perlin = new Perlin(repeat);
		// var w:Int = Std.int(size / 2);
		var w = size;
		for (ix in 0...w) {
			for (iy in 0...w) {
				var factor = perlinNoise.OctavePerlin(ix / scale, iy / scale, 0, octaves, persistence, frequency);
				var c = StringTools.hex(Std.int(factor * 255));
				bitmapData.setPixel(ix, iy, Std.parseInt("0x" + c + c + c));
			}
		}

		var bitmap = new Bitmap(bitmapData);
		bitmap.scaleX = bitmap.scaleY = 2;
		// this.addChild(bitmap);
		bitmap.x = bitmap.width;

		var map = new Bitmap(Assets.getBitmapData("assets/bg_shazi1.png"));
		this.addChild(map);

		var map = new Bitmap(Assets.getBitmapData("assets/bg_shazi1.png"));
		this.addChild(map);
		map.x = -map.width / 2;

		var map = new Bitmap(Assets.getBitmapData("assets/bg_shazi1.png"));
		this.addChild(map);
		map.y = map.width / 2;

		var water = new Bitmap(Assets.getBitmapData("assets/water.jpg"));
		this.addChild(water);
		water.scaleX = water.scaleY = 4;
		var s = new WarterShader();
		s.u_noiseBitmap.input = bitmapData;
		water.shader = s;
		this.addEventListener(Event.ENTER_FRAME, (e) -> {
			water.invalidate();
		});
		water.x = 300;

		// var bitmap = new Bitmap(bitmapData);
		// bitmap.scaleX = bitmap.scaleY = 1;
		// this.addChild(bitmap);
		// bitmap.x = stage.stageWidth - bitmap.width;
	}
}
