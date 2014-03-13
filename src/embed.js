define(['./swfobject','./event'], function(SwfObj, Event){

    var createReserveArea = function($recorderContainer) {
        Event.setContainer($recorderContainer);

        var $flashReserve = $('<div id="altContent"></div>');

        $flashReserve.append('<h1>您需先安装 Adobe flash player</h1>');
        $flashReserve.append('<p><a href="http://www.adobe.com/go/getflashplayer">下载 Adobe flash player</p>');

        var $formForUploadAudio = $('<form id="uploadForm" name="uploadForm" action=""></form>');

        $recorderContainer.append($flashReserve).append($formForUploadAudio);

    };

    /*
        options 是指要附带语音一起发给服务端的信息，如userId等.
        options = [
            {class: "chat", name: "chat_id", value: "67868768767678"},
            ...
        ]    
        
    */
    var initFormData = function(action, options) {
        $form = $('#uploadForm');
        
        $form.find('input').remove();

        $form.attr('action',action);

        if(arguments.length > 1){
            for(var i=0; i<options.length; i++){
                $input = $('<input class="" type="hidden" >');

                if(options[i].class){
                    $input.attr('class',options[i].class);
                }

                $input.attr('name', options[i].name);
                $input.attr('value', options[i].value);

                $form.append($input);
            }
        }
    };

    var getFormData = function() {
        var formData = $('#uploadForm').serializeArray();

        return formData;
    };

    var embed = function(){
        var microphone_recorder_events = Event.microphone_recorder_events;

        var flashvars = {
            'event_handler': 'microphone_recorder_events'
        };
        
        var params = {};

        var attributes = {
            'id': 'recorder',
            'name': 'recorder'
        };

        SwfObj.embedSWF(
            '../bin/RecordSound.swf',
            'altContent','100%','100%','10.0.0',
            '../bin/expressInstall.swf',
            flashvars,params,attributes);

    };

    var addRecorder = function($recorderContainer) {
        createReserveArea($recorderContainer);
        embed();
    };

    return {
        addRecorder: addRecorder,
        initFormData: initFormData,
        getFormData: getFormData
    };

});