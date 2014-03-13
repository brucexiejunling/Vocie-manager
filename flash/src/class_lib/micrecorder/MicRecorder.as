package class_lib.micrecorder
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import class_lib.micrecorder.encoder.WaveEncoder;
	import class_lib.micrecorder.events.RecordingEvent;
	
	/**
	 * Dispatched during the recording of the audio stream coming from the microphone.
	 *
	 * @eventType org.bytearray.micrecorder.RecordingEvent.RECORDING
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( RecordingEvent.RECORDING, onRecording );
	 * </pre>
	 * </div>
	 */
	[Event(name='recording', type='org.bytearray.micrecorder.RecordingEvent')]
	
	/**
	 * Dispatched when the creation of the output file is done.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 *
	 * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( Event.COMPLETE, onRecordComplete );
	 * </pre>
	 * </div>
	 */
	[Event(name='complete', type='flash.events.Event')]

	/**
	 * This tiny helper class allows you to quickly record the audio stream coming from the Microphone and save this as a physical file.
	 * A WavEncoder is bundled to save the audio stream as a WAV file
	 * @author Thibault Imbert - bytearray.org
	 * @version 1.2
	 * 
	 */	
	public final class MicRecorder extends EventDispatcher
	{
		private var _gain:uint;
		private var _rate:uint;
		private var _silenceLevel:uint;
		private var _timeOut:uint;
		private var _difference:uint;
		private var _buffer:ByteArray = new ByteArray();
		private var _output:ByteArray;
		private var _encoder:IEncoder;
		
		private var _completeEvent:Event = new Event ( Event.COMPLETE );
		private var _recordingEvent:RecordingEvent = new RecordingEvent( RecordingEvent.RECORDING, 0 );

		public var  mic:Microphone = Microphone.getMicrophone();
		/**
		 * 
		 * @param encoder The audio encoder to use
		 * @param gain The gain
		 * @param rate Audio rate
		 * @param silenceLevel The silence level
		 * @param timeOut The timeout
		 * @param mic The microphone device to use
		 * 
		 */		
		public function MicRecorder(encoder:IEncoder, gain:int=100, rate:int=44, silenceLevel:Number=0, timeOut:int=4000)
		{
			_encoder = encoder;
			_gain = gain;
			_rate = rate;
			_silenceLevel = silenceLevel;
			_timeOut = timeOut;
			
			mic.setSilenceLevel(_silenceLevel, _timeOut);
			mic.gain = _gain;
			mic.rate = _rate;
		}
		
		
		public function configure(gain:int = 100, rate:int = 44):void {
			_gain = gain;
			_rate = rate;

			mic.gain = _gain;
			mic.rate = _rate;
		}
		
		
		public function record():void
		{		 
			_difference = getTimer();
			
			_buffer.length = 0;
			
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			mic.addEventListener(StatusEvent.STATUS, onStatus);
		}
		
		private function onStatus(event:StatusEvent):void
		{
			_difference = getTimer();
		}
		
		/**
		 * Dispatched during the recording.
		 * @param event
		 */		
		private function onSampleData(event:SampleDataEvent):void
		{
			_recordingEvent.time = getTimer() - _difference;
			
			dispatchEvent( _recordingEvent );
			
			while(event.data.bytesAvailable > 0)
				_buffer.writeFloat(event.data.readFloat());
		}
		
		/**
		 * Stop recording the audio stream and automatically starts the packaging of the output file.
		 */		
		public function stop():void
		{
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			_buffer.position = 0;
			_output = _encoder.encode(_buffer, 1, 16, frequency(_rate));
			
			dispatchEvent( _completeEvent);
		}
		
		private function frequency(rate:int):int {
			switch(rate) {
				case 44:
					return 44100;
				case 22:
					return 22050;
				case 11:
					return 11025;
				case 8:
					return 8000;
				case 5:
					return 5512;
			}
			
			return 0;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get gain():uint
		{
			return _gain;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set gain(value:uint):void
		{
			_gain = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get rate():uint
		{
			return _rate;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set rate(value:uint):void
		{
			_rate = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get silenceLevel():uint
		{
			return _silenceLevel;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set silenceLevel(value:uint):void
		{
			_silenceLevel = value;
		}


		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get microphone():Microphone
		{
			return mic;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set microphone(value:Microphone):void
		{
			mic = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get output():ByteArray
		{
			return _output;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public override function toString():String
		{
			return "[MicRecorder gain=" + _gain + " rate=" + _rate + " silenceLevel=" + _silenceLevel + " timeOut=" + _timeOut + " microphone:" + mic + "]";
		}
	}
}