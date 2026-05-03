// Emscripten game package loader - handles mounting game.love to FS
// Executes BEFORE love.js loads to ensure file is available when needed

var Module = Module || {};

// Initialize preRun array
if (!Module.preRun) Module.preRun = [];

// Global state
var _gameArchive = null;
var _archiveFetchComplete = false;

// Step 1: Fetch game archive SYNCHRONOUSLY (before any async bootstrap)
console.log('[GameLoader] Starting synchronous fetch of game.love...');
try {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', 'game.love', false); // synchronous
  xhr.responseType = 'arraybuffer';
  xhr.send();
  
  if (xhr.status === 200 && xhr.response) {
    _gameArchive = xhr.response;
    _archiveFetchComplete = true;
    console.log('[GameLoader] ✓ Synchronously loaded game.love:', xhr.response.byteLength, 'bytes');
  } else {
    throw new Error('HTTP ' + xhr.status);
  }
} catch(e) {
  console.error('[GameLoader] ✗ Synchronous load failed:', e.message);
  console.log('[GameLoader] Falling back to async fetch...');
  
  // Fallback: async fetch
  fetch('game.love')
    .then(response => {
      if (!response.ok) throw new Error('HTTP ' + response.status);
      return response.arrayBuffer();
    })
    .then(buffer => {
      _gameArchive = buffer;
      _archiveFetchComplete = true;
      console.log('[GameLoader] ✓ Async load complete:', buffer.byteLength, 'bytes');
    })
    .catch(err => {
      console.error('[GameLoader] ✗ Async fetch also failed:', err);
    });
}

// Step 2: Mount archive to FS during preRun (before Love2D boots)
Module.preRun.push(function() {
  console.log('[GameLoader] preRun callback executing...');
  
  if (!_gameArchive) {
    console.error('[GameLoader] ✗ No game archive data available!');
    return;
  }
  
  if (typeof FS === 'undefined') {
    console.error('[GameLoader] ✗ FS not available in preRun');
    return;
  }
  
  try {
    // Convert ArrayBuffer to Uint8Array
    var archiveData = new Uint8Array(_gameArchive);
    console.log('[GameLoader] Installing', archiveData.length, 'bytes to FS...');
    
    // Mount the game archive
    FS.createDataFile('/', 'game.love', archiveData, true, true);
    
    console.log('[GameLoader] ✓ game.love mounted to FS at /game.love');
    
    // Verify the file exists
    var stat = FS.stat('/game.love');
    console.log('[GameLoader] ✓ File verified: size =', stat.size, 'bytes');
    
  } catch(e) {
    console.error('[GameLoader] ✗ Failed to mount:', e);
    throw e;
  }
});

