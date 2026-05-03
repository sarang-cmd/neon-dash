// Emscripten data package loader for game.love
// Async fetch with proper preRun sequencing to ensure mounting before Love2D boot
var Module = Module || {};

(function() {
  if (!Module.preRun) Module.preRun = [];
  
  // Fetch game.love early and keep as module property
  var gameDataFetched = false;
  var gameDataBuffer = null;
  
  // Add fetch to beginning of preRun chain
  Module.preRun.unshift(function() {
    console.log('[Package Loader] preRun: Waiting for game data fetch...');
  });
  
  // Fetch game.love with error handling
  console.log('[Package Loader] Starting synchronous game.love fetch...');
  
  var req = new XMLHttpRequest();
  req.open('GET', 'game.love', false); // synchronous
  req.responseType = 'arraybuffer';
  
  try {
    req.send();
    if (req.status === 200) {
      gameDataBuffer = req.response;
      gameDataFetched = true;
      console.log('[Package Loader] ✓ game.love fetched: ' + gameDataBuffer.byteLength + ' bytes');
    } else {
      console.error('[Package Loader] ✗ HTTP ' + req.status + ' fetching game.love');
      throw new Error('Failed to fetch game.love: HTTP ' + req.status);
    }
  } catch(e) {
    console.error('[Package Loader] ✗ Fetch failed:', e);
    // Try a fallback - fetch the data early in case synchronous request fails
    fetch('game.love')
      .then(r => r.arrayBuffer())
      .then(buf => {
        gameDataBuffer = buf;
        gameDataFetched = true;
        console.log('[Package Loader] ✓ Fallback fetch succeeded: ' + buf.byteLength + ' bytes');
      })
      .catch(err => {
        console.error('[Package Loader] ✗ Fallback fetch also failed:', err);
      });
    throw e;
  }

  // Mount game.love in FS during preRun
  Module.preRun.push(function() {
    console.log('[Package Loader] preRun callback: FS available? ' + (typeof FS !== 'undefined'));
    
    if (typeof FS !== 'undefined' && gameDataBuffer) {
      try {
        var fileData = new Uint8Array(gameDataBuffer);
        
        // Try creating at root
        FS.createDataFile('/', 'game.love', fileData, true, true);
        console.log('✓ [Package Loader] game.love installed to FS / (' + fileData.length + ' bytes)');
        
      } catch(e) {
        console.error('✗ [Package Loader] FS.createDataFile failed:', e);
        throw e;
      }
    } else {
      var msg = 'preRun: Cannot install - FS=' + (typeof FS) + ', data=' + (gameDataBuffer ? 'ready' : 'missing');
      console.error('✗ [Package Loader] ' + msg);
      throw new Error(msg);
    }
  });
})();
