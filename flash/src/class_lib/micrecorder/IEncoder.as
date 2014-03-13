package class_lib.micrecorder
{
	import flash.utils.ByteArray;

	public interface IEncoder
	{
		function encode(samples:ByteArray, channels:int, bits:int, rate:int):ByteArray;
	}
}