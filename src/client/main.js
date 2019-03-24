
window.addEventListener("load", function(){
  game = new Game("ws://"+(location.hostname.length > 0 ? location.hostname : "127.0.0.1")+":35000");
});
