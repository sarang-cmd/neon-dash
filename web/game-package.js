// Emscripten game package loader - mounts game.love to FS when runtime is ready
// Uses async fetch + onRuntimeInitialized (when FS is available)

var Module = Module || {};

// Global state for game archive
var _gameArchiveBuffer = null;

console.log('[GameLoader] Fetching game.love asynchronously...');

// Fetch the game archive asynchronously
fetch('game.love')
  .then(response => {
    if (!response.ok) throw new Error('HTTP ' + response.status);
    console.log('[GameLoader] HTTP response OK, reading buffer...');
    return response.arrayBuffer();
  })
  .then(buffer => {
    _gameArchiveBuffer = buffer;
    console.log('[GameLoader] ✓ game.love fetched:', buffer.byteLength, 'bytes');
  })
  .catch(err => {
    console.error('[GameLoader] ✗ Fetch failed:', err);
    throw err;
  });

// Mount archive to FS when runtime is ready (FS available)
var _originalOnRuntimeInitialized = Module.onRuntimeInitialized;
Module.onRuntimeInitialized = function() {
  console.log('[GameLoader] onRuntimeInitialized: FS ready, mounting game.love...');
  
  try {
    if (!_gameArchiveBuffer) {
      throw new Error('Game archive not fetched yet');
    }
    
    if (typeof FS === 'undefined') {
      throw new Error('FS still not available');
    }
    
    // Convert ArrayBuffer to Uint8Array and mount
    var archiveData = new Uint8Array(_gameArchiveBuffer);
    console.log('[GameLoader] Calling FS.createDataFile with', archiveData.length, 'bytes...');
    
    FS.createDataFile('/', 'game.love', archiveData, true, true);
    console.log('[GameLoader] ✓ game.love mounted to FS at /game.love');
    
    // Verify file exists
    try {
      var stat = FS.stat('/game.love');
      console.log('[GameLoader] ✓ File verified: size =', stat.size, 'bytes');
    } catch(e) {
      console.warn('[GameLoader] Could not stat file:', e);
    }
    
  } catch(e) {
    console.error('[GameLoader] ✗ Mount failed:', e);
    throw e;
  }
  
  // Call original onRuntimeInitialized if it existed
  if (_originalOnRuntimeInitialized && typeof _originalOnRuntimeInitialized === 'function') {
    _originalOnRuntimeInitialized();
  }
};

