/**
 * ...
 * @author bruce
 */
 
define(function(){

	var Recorder = {
	    recorder: null,
        
        uploadFieldName: "audio",

        uploadURL: "",

        uploadFormData: "",

	    connect: function(name,attempts) {
			if (window.document[name]){
				Recorder.recorder =  window.document[name];
			}else if (navigator.appName.indexOf("Microsoft Internet")==-1){
				if (document.embeds && document.embeds[name]){
					Recorder.recorder = document.embeds[name]; 
				}
			}else{
				Recorder.recorder = document.getElementById(name);
			}

			if(attempts >= 40){
				return ;
			}

	      	// flash app needs time to load and initialize
			if(Recorder.recorder && Recorder.recorder.init){
				Recorder.recorder.init(Recorder.uploadURL, Recorder.uploadFieldName, Recorder.uploadFormData);

				return ;
			}

	        setTimeout(function() {
	        	Recorder.connect(name, attempts+1);
	        }, 100);
	        
	    },
		
		initialize: function(uploadURL, formData) {
			Recorder.uploadURL = uploadURL;
			Recorder.uploadFormData = formData;
			
			Recorder.connect('recorder', 0);
		},
		
		showSettingWindow: function() {
			Recorder.recorder.showSettings();
		},

		startRecord: function() {
			Recorder.recorder.startRecord();
		},

		stopRecord: function(autoSend) {
			Recorder.recorder.stopRecord(autoSend);
		},

		playBack: function() {
			Recorder.recorder.playBack();
		},

    sendToServer: function() {
      Recorder.recorder.sendToServer();
    }
		
 	};

 	return Recorder;
});
  