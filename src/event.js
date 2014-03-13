define(['./recorder'], function(Recorder) {
    
    var container = null;

    var setContainer = function($container) {
        container = $container;
    };

    var t1 = null, t2 = null,i=0;
    var time = [];

    microphone_recorder_events = function() {
        switch(arguments[0]){
        
            case "ready":
                container.trigger('ready');
                break;
                
            case "mic_request":
                container.trigger('mic-request');         
                Recorder.showSettingWindow();
                break;

            case "mic_not_found":
                container.trigger('mic-not-found');
                break;

            case "mic_connected": 
                container.trigger('mic-connected');
                break;

            case "mic_not_connected":
                container.trigger('mic-not-connected');
                break;

            case "record_start":
                container.trigger('record-start');
                break;

            case "record_commplete":
                container.trigger('record-complete');
                break;

            case "encode_start":
                t1 = new Date();
                container.trigger('encode-start');
                break;

            case "encode_complete":
                t2 = new Date();
                console.log('encoding time:');
                console.log(t2.getTime() - t1.getTime());
                time[i++] = t2.getTime()-t1.getTime();
                t1=t2=0;
                console.log(i);
                if(i==10){
                    var sum = 0;
                    for(var j=0;j<10;j++){
                        sum += time[j];
                    }
                    console.log(sum/10);
                }
                container.trigger('encode-complete');
                break;
                
            case "send_start":
                container.trigger('send-start');
                break;

            case "send_progressing":
                container.trigger('send-progressing');
                break;

            case "send_complete":
                var data = JSON.parse(arguments[1]);
                container.trigger('send-complete', [data]);

                break;

            case "send_error":
                container.trigger('send-error');
                break;

            case "io_error":
                container.trigger('io-error');
                break;

            case "security_error":
                container.trigger('security-error');
                break;
        }
    };

    return {
        setContainer: setContainer,
        microphone_recorder_events: microphone_recorder_events
    };
});