
function Game(ws_url)
{
  var _this = this;

  /* websocket connect */
  this.ws = new WebSocket(ws_url);
  this.ws.binaryType = "arraybuffer";

  this.ws.onmessage = function(e){
    if(e.data instanceof ArrayBuffer){
      var data = msgpack.decode(new Uint8Array(e.data));
      if(data != null && data.length != null && data.length >= 2)
        _this.onPacket(data[0], data[1]);
    }
  }
}

Game.prototype.sendPacket = function(protocol, data)
{
  if(protocol != null && data != null)
    this.ws.send(msgpack.encode([protocol, data]), WebSocket.BINARY);
}

Game.prototype.onPacket = function(protocol, data)
{
  var _this = this;

  if(protocol == -1){ // load protocol actions
    this.net = data;
  }
}
