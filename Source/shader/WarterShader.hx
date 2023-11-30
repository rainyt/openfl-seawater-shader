package shader;

import VectorMath;
import glsl.GLSL;
import glsl.Sampler2D;
import glsl.OpenFLShader;

/**
 * 海水着色器
 */
@:debug
class WarterShader extends OpenFLShader {
	/**
	 * 时间戳
	 */
	@:uniform
	private var time:Float;

	/**
	 * 纹理
	 */
	@:uniform
	private var noiseBitmap:Sampler2D;

	public function new() {
		super();
		this.setFrameEvent(true);
		this.u_time.value = [0];
		this.u_tweenStart.value = [0.05];
		this.u_tweenWidth.value = [0.1];
		this.u_tweenEnd.value = [0.1];
	}

	@:uniform
	private var tweenStart:Float;

	@:uniform
	private var tweenWidth:Float;

	@:uniform
	private var tweenEnd:Float;

	@:glsl
	public function lerp(rate:Float, from:Float, to:Float):Float {
		return from * (1 - rate) + to * rate;
	}

	/**
	 * 过渡计算
	 * @return Float
	 */
	@:glsl
	public function mathAlphaTween():Float {
		// 其余部分都应该是1
		var f2:Float = gl_openfl_TextureCoordv.x / 0.15;
		f2 = min(1, f2);
		var v:Float = lerp(f2, 0.5, 1.);
		return v;
	}

	/**
	 * 范围内时，返回1，否则返回0
	 * @param x 
	 * @param min 
	 * @param max 
	 * @return Float
	 */
	@:glsl
	public function cut(v:Float, min:Float, max:Float):Float {
		return step(min, v) * step(v, max);
	}

	@:glsl
	public function cutkeep(v:Float, min:Float, max:Float):Float {
		return cut(v, min, max) * v;
	}

	override function fragment() {
		super.fragment();
		// 海水的UV像素比
		var uv:Vec2 = 1. / gl_openfl_TextureSize;
		// 噪声的时间戳
		var noiseOffest:Float = time / 6.28;
		// 海水的噪声图
		var noise:Vec4 = texture2D(noiseBitmap, fract(gl_openfl_TextureCoordv + vec2(noiseOffest, 0)));
		// 影子的噪声图
		var shadowNoise:Vec4 = texture2D(noiseBitmap, fract(gl_openfl_TextureCoordv + vec2(3.14 / 10., 0)));
		// 这是海水波浪映射效果
		var offest:Float = noise.r * uv.x * 10.;
		// var waterBottomColor:Vec4 = texture2D(gl_bitmap, gl_openfl_TextureCoordv + vec2(offest * 2, offest * 2));
		var waterBottomColor:Vec4 = texture2D(gl_openfl_Texture, gl_openfl_TextureCoordv);
		// 测试法线
		// waterBottomColor *= gl_openfl_TextureCoordv.y;
		// var mTween:Float = mathTween();
		var waterColor:Vec4 = vec4(1, 1, 1, 1) * 0.5;
		// v2
		// 这里海浪的平移速度要加速
		var moveTime:Float = time;
		var waterOffest:Float = noise.r * 0.5;
		var waterMove:Float = 5. + cos(moveTime) * 5.;
		// 冲浪变粗处理
		var waterMove2:Float = sin(-moveTime) * 1.5;
		var min:Float = uv.x * (15 * waterOffest + waterMove);
		var max:Float = uv.x * (35 * waterOffest + waterMove - waterMove2);
		waterColor = waterColor * cut(gl_openfl_TextureCoordv.x, min, max);
		var waterStart:Float = step(min, gl_openfl_TextureCoordv.x);
		waterBottomColor.rgb = waterBottomColor.rgb + waterColor.rgb;
		waterBottomColor = waterBottomColor * mathAlphaTween() * waterStart;
		// v2影子
		var shadowNoiseOffest:Float = shadowNoise.r * 0.5;
		var shadowWater:Vec4 = vec4(0., 0., 0., 1.) * (1 - waterStart) * 0.5;
		var min_shadow:Float = uv.x * (15 * shadowNoiseOffest);
		// var max_shadow:Float = uv.x * (35 * shadowNoiseOffest);
		shadowWater = shadowWater * cut(gl_openfl_TextureCoordv.x, min_shadow, 1);
		waterBottomColor = waterBottomColor + shadowWater * (sin(-moveTime) / 3.14);
		// 海浪花
		var tweenSize:Float = uv.x * 100.;
		var mTweenCut:Float = cut(gl_openfl_TextureCoordv.x, max, 1);
		var mTween:Float = (1 - gl_openfl_TextureCoordv.x / tweenSize) * mTweenCut;
		var waterColor2:Vec4 = vec4(1, 1, 1, 1) * 0.25;
		var noise2:Vec4 = texture2D(noiseBitmap, fract(gl_openfl_TextureCoordv * vec2(8, 1) + vec2(noiseOffest, 0) + vec2(offest, offest)));
		waterColor2.rgb = waterColor2.rgb * step(1 - noise2.r, mTween * 0.5);
		waterBottomColor.rgb = waterColor2.rgb + waterBottomColor.rgb;
		// 海绵杂浪
		// var waterColor_main_tween:Float = cut(gl_openfl_TextureCoordv.x, tweenSize * 0., 1);
		var waterColor_main:Vec4 = vec4(1, 1, 1, 1) * cos(offest) * 0.1;
		var main_noise:Vec4 = texture2D(noiseBitmap, fract(gl_openfl_TextureCoordv + vec2(offest * 2, offest * 2)));
		waterColor_main = waterColor_main * main_noise.r;
		waterBottomColor.rgb = waterBottomColor.rgb + waterColor_main.rgb * mTweenCut;

		// 透明过渡
		var c:Float = cut(gl_openfl_TextureCoordv.x, 0.9, 1);
		var tweenAlpha:Float = (1 - c) + (c * (1 - gl_openfl_TextureCoordv.x) / 0.1);
		this.gl_FragColor = waterBottomColor * tweenAlpha;
	}

	override function onFrame() {
		super.onFrame();
		this.u_time.value[0] = (this.u_time.value[0] + 1 / 60) % (6.28);
	}
}
