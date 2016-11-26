
precision mediump float;

varying mediump vec2 coordinate;
uniform sampler2D uVideoframe;

void main()
{
	gl_FragColor = texture2D(uVideoframe, coordinate);
}