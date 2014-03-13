config = require('./config.js');
var fs = require('fs');
var express = require('express');
var server = express();


server.use(express.bodyParser());
server.use('/voice-manager',express.static(__dirname));

server.post('/voice-manager/upload',function(req, res){
    var userId = req.body.userId;
    var tem_path = req.files.audio.path;
    var target_path = './bin/audio/' + userId + '.mp3';
    var is = fs.createReadStream(tem_path);
    var os = fs.createWriteStream(target_path);

    is.pipe(os);
    is.on('end',function() {
        fs.unlinkSync(tem_path);
        res.send({
            src: config.path + userId + '.mp3'
        });
    });

});

server.listen(8002);

console.log('listening at port 8002');