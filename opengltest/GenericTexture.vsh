
attribute vec4 aPosition;
attribute mediump vec4 aTexturecoordinate;
varying mediump vec2 coordinate;

void main()
{
	gl_Position = aPosition;
	coordinate = aTexturecoordinate.xy;
}
