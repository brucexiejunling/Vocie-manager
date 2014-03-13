define(['./embed', './recorder'], function(Embed, Recorder) {

    var VM = null;
    var recorderContainer = null;
    var addRecorder = function($recorderContainer) {
        Embed.addRecorder($recorderContainer);
        recorderContainer = $recorderContainer;
    };

    //在每一个widget中使用VM时，设置特定的表单信息
    var initRecorder = function(action, options){
        Embed.initFormData(action, options);

        var formData = Embed.getFormData();
        Recorder.initialize(action, formData);
    };

    var startRecord = function() {
        Recorder.startRecord();
    };

    var stopRecord = function(autoSend) {
        Recorder.stopRecord(autoSend);
    };

    var playBack = function() {
        Recorder.playBack();
    };

    var sendToServer = function() {
        Recorder.sendToServer()
    };

    var getRecorderContainer = function() {
        return recorderContainer;
    }


    function VoiceManager($recorderContainer) {
        if (VM) {
            return VM;
        }else{

            VM = {
                init: initRecorder,
                start: startRecord,
                stop: stopRecord,
                play: playBack,
                send: sendToServer,
                container: getRecorderContainer
            };

            addRecorder($recorderContainer); //嵌入一次
            
            return VM;
        }
    }

    return VoiceManager;
});