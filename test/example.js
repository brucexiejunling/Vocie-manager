require.config({
    paths: {
        'jquery': '../jquery-2.0.0'
    }
});

require(['jquery', '../src/voice-manager'], function($, VoiceManager){
    
    $container = $('div.recorder-container');

    //在页面上嵌入audio-plus。而且只嵌入一个
    var AudioPlus = VoiceManager($container);
    var connected = false;

    // var createConfiguration = function() { 
    //     var gain = $('#gain')[0];
    //     var silenceLevel = $('#silenceLevel')[0];
    //     for(var i=0; i<=100; i++) {
    //         gain.options[gain.options.length] = new Option(100-i);
    //         silenceLevel.options[silenceLevel.options.length] = new Option(i);
    //     }

    //     $('#configure').click(function(){
    //         configureMic();
    //     });
    // };
    
    // createConfiguration();

    // var startAudition = function() {
    //     $('span.info').html('试音模式已开启,请说话并调整麦克风参数...');
    //     $('div.configuration').fadeIn(200);
    //     AudioPlus.startAudition();
    // };

    // var stopAudition = function() {
    //     $('div.configuration').fadeOut(200);
    //     $('span.info').html('试音模式已关闭...');
    //     AudioPlus.stopAudition();
    // };

    // var configureMic = function(){
    //     AudioPlus.configure( $('#gain').val(),$('#rate').val());
    // };

    // $('button.open').click(function(){
    //     startAudition();
    // });

    // $('button.close').click(function(){
    //     stopAudition();
    // });

    var which = '';

    $('button.send').click(function(){
      AudioPlus.send()
    })

    $('div.controls button').attr('disabled',true);

    $('button.A').click(function(){
        which = 'a';
        $('span.info').html('打开了A录音器...');
        
        //在页面上多个地方使用audio-plus,其实是共用一个,只需配置不同的信息
        AudioPlus.init('/voice-manager/upload', [{class: 'first', name: 'recorder', value: 'recorder-a'}]);
        $('div.controls button').attr('disabled',false);
        $('div.recorder-b div.controls').find('button').attr('disabled',true);

    });

    $('button.B').click(function(){
        which = 'b';
        $('span.info').html('打开了B录音器...');

        //在页面上多个地方使用audio-plus,其实是共用一个,只需配置不同的信息
        AudioPlus.init('http://172.16.21.226:8004/upload-audio', [{class: 'second', name: 'recorder', value: 'recorder-b'}]);

        $('div.controls button').attr('disabled',false);
        $('div.recorder-a div.controls').find('button').attr('disabled',true);
    });

    $('button.start').click(function(){        
        AudioPlus.start();

    });

    $('button.stop').click(function(){
        AudioPlus.stop(autoSend = true);
    });



    //状态事件

    $container.on('ready',function(){
        $('span.info').html('flash已经嵌入网页中...');
    });
    
    $container.on('mic-request',function(){
        $('span.info').html('请求使用麦克风...');
    });

    $container.on('mic-not-found',function(){
        $('span.info').html('未找到可用麦克风...');
    });    

    $container.on('mic-connected',function(){
        $('span.info').html('麦克风已连接...');
        $('span.info').html('在录音之前，您可以设置调整麦克风音量...');
    });    

    $container.on('mic-not-connected',function(){
        $('span.info').html('麦克风未连接,将不能录音...');
    });    

    $container.on('record-start',function(){
        setTimeout(AudioPlus.stop, 60000);
        $('span.info').html('正在录音...');
    });    


    $container.on('record-complete',function(){
        $('span.info').html('录音结束...');

    });
    
    $container.on('encode-start',function(){
        $('span.info').html('进行格式转换...');
    });    
    
    $container.on('encode-complete',function(){
        $('span.info').html('格式转换完成...');
    }); 

    $container.on('send-start',function(){
        $('span.info').html('正在发送...');
    });

    $container.on('send-complete',function(event,data){
      console.log('yifasong')
      console.log(data)
        var $audio;

        if(which == 'a'){
            $audio = $('div.recorder-a audio');
        }else{
            $audio = $('div.recorder-b audio');
        }

        $audio.attr('src', data.src);

        $('span.info').html('已发送...');

    });

    $container.on('send-error',function(){
        $('span.info').html('保存时发生错误...');
    });

    $container.on('io-error',function(){
        $('span.info').html('IO 错误...');
    });

    $container.on('security-error',function(){
        $('span.info').html('安全限制...');
    });

});