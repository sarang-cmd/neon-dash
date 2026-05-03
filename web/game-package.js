// Emscripten data package loader for game.love
// Uses SYNCHRONOUS fetch to ensure file is available before Love2D boots
var Module = Module || {};

(function() {
  // Store game.love data globally for preRun callback
  window._gameArchiveData = null;
  var REMOTE_PACKAGE_BASE = 'game.love';

  // Use synchronous XMLHttpRequest to fetch game.love IMMEDIATELY
  console.log('[Package Loader] Fetching game.love (sync)...');
  var xhr = new XMLHttpRequest();
  xhr.open('GET', REMOTE_PACKAGE_BASE, false); // false = synchronous!
  xhr.responseType = 'arraybuffer';
  xhr.onerror = function() {
    console.error('✗ [Package Loader] Failed to fetch game.love');
    throw new Error('Cannot load game.love');
  };
  
  try {
    xhr.send(null);
    window._gameArchiveData = xhr.response;
    console.log('[Package Loader] game.love fetched (' + xhr.response.byteLength + ' bytes)');
  } catch(e) {
    console.error('✗ [Package Loader] Fetch error:', e);
    throw e;
  }

  // Mount game.love before Love2D boots
  if (!Module.preRun) Module.preRun = [];
  Module.preRun.push(function() {
    if (FS && typeof FS !== 'undefined' && window._gameArchiveData) {
      try {
        var fileData = new Uint8Array(window._gameArchiveData);
        FS.createDataFile('/', 'game.love', fileData, true, true);
        console.log('✓ [Package Loader] game.love installed to FS at / (' + fileData.length + ' bytes)');
      } catch(e) {
        console.error('✗ [Package Loader] Failed to install to FS:', e);
        throw e;
      }
    } else {
      console.warn('[Package Loader] FS not ready or data missing');
    }
  });
})();
