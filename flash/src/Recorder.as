package {
	import cmodule.shine.StaticInitter;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.EventDispatcher;
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;

	import flash.system.Security;

	
	import flash.external.ExternalInterface;


	import class_lib.shinemp3.ShineMP3Encoder;
	import class_lib.as3wavsound.WavSound;
	import class_lib.micrecorder.MicRecorder;
	import class_lib.micrecorder.encoder.WaveEncoder;
	import class_lib.micrecorder.events.RecordingEvent;
	
	import MultiPartFormUtil;

	public class Recorder extends Sprite {
		private var volume:Number = 0.5; // volume in the final WAV file
		private var wavEncoder:WaveEncoder; // we create the WAV encoder to be used by MicRecorder
		private var recorder:MicRecorder; // we create the MicRecorder object which does the job
		private var mp3Encoder:ShineMP3Encoder;      //mp3格式
		private var player:WavSound;
		private var mic:Microphone;
		private var isRecording:Boolean = false;
		
		public static var READY:String = "ready";
		public static var MIC_REQUEST:String = "mic_request";
		public static var MIC_NOT_FOUND:String = "mic_not_found";
		public static var MIC_CONNECTED:String = "mic_connected";
		public static var MIC_NOT_CONNECTED:String = "mic_not_connected";
		public static var RECORD_START:String = "record_start";
		public static var RECORD_COMPLETE:String = "record_complete";
		public static var ENCODE_START:String = "encode_start";
		public static var ENCODE_COMPLETE:String = "encode_complete";		
		public static var SEND_START:String = "send_start";
		public static var SEND_PROGRESSING:String = "send_progressing";
		public static var SEND_COMPLETE:String = "send_complete";
		public static var SEND_ERROR:String = "send_error";
		public static var IO_ERROR:String = "io_error";
		public static var SECURITY_ERROR:String = "security_error";
 
		
		public var uploadUrl:String;
		public var uploadFormData:Array;
		public var uploadFieldName:String;
		public var eventHandler:String = "microphone_recorder_events";
		public var autoSend:Boolean = false;
		
		public function Recorder() {
			if(ExternalInterface.available && ExternalInterface.objectID) {
				ExternalInterface.addCallback("showSettings", showSettings);
				ExternalInterface.addCallback("getMicStatus", getMicStatus);
				ExternalInterface.addCallback("init", init);
				ExternalInterface.addCallback("update", update);        
				ExternalInterface.addCallback("startRecord", startRecord);
				ExternalInterface.addCallback("stopRecord", stopRecord);
				ExternalInterface.addCallback("playBack", playBack);
				ExternalInterface.addCallback("sendToServer", sendToServer);
			}
			
			wavEncoder = new WaveEncoder(volume);
			recorder = new MicRecorder(wavEncoder);
			recorder.addEventListener(Event.COMPLETE, onRecordComplete);
			
			
			ready();
		}
		
		/* --------------------------private function--------------------------*/
		
		private function ready():void {
			ExternalInterface.call(this.eventHandler, Recorder.READY);
		}		
		
		private function isMicrophoneAvailable():Boolean {
			if (!recorder.mic.muted) {
				ExternalInterface.call(this.eventHandler, this.recorder.mic.rate);
				return true;
			}else if(Microphone.names.length == 0){
				ExternalInterface.call(this.eventHandler, Recorder.MIC_NOT_FOUND);
			}else {
				ExternalInterface.call(this.eventHandler, Recorder.MIC_REQUEST);
			}
			return false;
		}
		
		
		private function send():void {
			
			var boundary:String = MultiPartFormUtil.boundary();
			
			this.uploadFormData.push( MultiPartFormUtil.fileField(this.uploadFieldName,this.mp3Encoder.data, "audio.mp3", "audio/x-mp3") );
			var request:URLRequest = MultiPartFormUtil.request(this.uploadFormData);
			this.uploadFormData.pop();
			
			request.url = this.uploadUrl;
			var loader:URLLoader = new URLLoader();

			loader.addEventListener(Event.COMPLETE, onSendComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			try {
				ExternalInterface.call(this.eventHandler, Recorder.SEND_START);
				loader.load(request);
			}catch (event:Error) {
				ExternalInterface.call(this.eventHandler, Recorder.SEND_ERROR);
			}
				
		}
		

		
		/* -------------------------- Javascript API -----------------------------*/
		

		public function init(url:String = null, fieldName:String = null, formData:Array = null):void {
			this.uploadUrl = url;
			this.uploadFieldName = fieldName;
			this.update(formData);
		}
		
		public function update(formData:Array = null):void {
			this.uploadFormData = new Array();
			if(formData) {
				for(var i:int=0; i<formData.length; i++) {
					var data:Object = formData[i];
					this.uploadFormData.push(MultiPartFormUtil.nameValuePair(data.name, data.value));
				}
			}
		}
		

		public function showSettings():void {
			recorder.mic.addEventListener(StatusEvent.STATUS, onMicrophoneStatus);
			Security.showSettings();
		}
		
		public function getMicStatus():String {
			if (!recorder.mic.muted) {
				return "connected";
			}else if (Microphone.names.length == 0){
				return "not_found";
			}else {
				return "not_connected";
			}
		}
		
		public function startRecord():void {
			if(!isRecording){
				if (isMicrophoneAvailable()) {			
					ExternalInterface.call(this.eventHandler, Recorder.RECORD_START);		
					recorder.record();
					isRecording = true;
				}
			}
		}
			
		public function stopRecord(isAutoSend:Boolean = false):void {
			if (isRecording) {
				autoSend = isAutoSend;
				ExternalInterface.call(this.eventHandler,Recorder.RECORD_COMPLETE);
				recorder.stop();
			}
		}
			
		public function playBack():void {
			player = new WavSound(this.recorder.output);
			player.play();	
		}

		public function sendToServer():void {
			send();
		}
		
		/* -----------------------------Event handler ------------------------------*/
		private function onMicrophoneStatus(event:StatusEvent):void {
			if (event.code == "Microphone.Unmuted") {
				ExternalInterface.call(this.eventHandler,Recorder.MIC_CONNECTED);
			}else {
				ExternalInterface.call(this.eventHandler, Recorder.MIC_NOT_CONNECTED);
			}
		}
		
		
		private function onRecordComplete(event:Event):void {
			isRecording = false;
			EncodeIntoMP3();
		}

		private function EncodeIntoMP3():void {
			mp3Encoder = new ShineMP3Encoder(recorder.output);
			
			mp3Encoder.addEventListener("start", onEncodeStart);
			mp3Encoder.addEventListener(Event.COMPLETE, onEncodeComplete);

			mp3Encoder.start();			
		}
		
		private function onEncodeStart(event:Event):void {
			ExternalInterface.call(this.eventHandler, Recorder.ENCODE_START);
		}
		
		private function onEncodeComplete(event:Event):void {
			ExternalInterface.call(this.eventHandler, Recorder.ENCODE_COMPLETE);
			if (autoSend) {
				send();
			}
		}
			
		private function onSendComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			ExternalInterface.call(this.eventHandler, Recorder.SEND_COMPLETE, loader.data);
		}
		
		private function onIOError(event:Event):void {
			ExternalInterface.call(this.eventHandler,Recorder.IO_ERROR);
		}
		
		private function onSecurityError(event:Event):void {
			ExternalInterface.call(this.eventHandler, Recorder.SECURITY_ERROR);
		}
		
		private function onProgress(event:Event):void {
			ExternalInterface.call(this.eventHandler, Recorder.SEND_PROGRESSING);
		}
		

	}

}
