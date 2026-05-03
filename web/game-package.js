// Emscripten game package loader - mounts game.love to FS when ready
// Works with love.js by accessing FS through Module.FS or waiting for availability

var Module = Module || {};

// Global state for game archive
var _gameArchiveBuffer = null;
var _gameArchiveMounted = false;

console.log('[GameLoader] Fetching game.love asynchronously...');

// Fetch the game archive
fetch('game.love')
  .then(response => {
    if (!response.ok) throw new Error('HTTP ' + response.status);
    console.log('[GameLoader] HTTP response OK, reading buffer...');
    return response.arrayBuffer();
  })
  .then(buffer => {
    _gameArchiveBuffer = buffer;
    console.log('[GameLoader] ✓ game.love fetched:', buffer.byteLength, 'bytes');
    // Try to mount immediately in case FS is already available
    tryMountArchive();
  })
  .catch(err => {
    console.error('[GameLoader] ✗ Fetch failed:', err);
    throw err;
  });

// Function to mount the archive - called multiple times until successful
function tryMountArchive() {
  if (_gameArchiveMounted) return;
  if (!_gameArchiveBuffer) {
    console.log('[GameLoader] Archive not yet fetched');
    return;
  }

  // Try to get FS object (love.js might store it in Module.FS or global FS)
  var FS = window.FS || Module.FS || (typeof FS !== 'undefined' ? FS : null);
  
  if (!FS) {
    console.log('[GameLoader] FS not available yet, will retry...');
    return;
  }

  try {
    console.log('[GameLoader] Mounting game.love to FS...');
    var archiveData = new Uint8Array(_gameArchiveBuffer);
    
    // Ensure root directory exists
    try {
      FS.stat('/');
    } catch(e) {
      console.warn('[GameLoader] Root directory does not exist, creating...');
      FS.mkdir('/');
    }
    
    FS.createDataFile('/', 'game.love', archiveData, true, true);
    console.log('[GameLoader] ✓ game.love mounted to FS at /game.love');
    
    // Verify file exists
    var stat = FS.stat('/game.love');
    console.log('[GameLoader] ✓ File verified: size =', stat.size, 'bytes');
    
    _gameArchiveMounted = true;
    
  } catch(e) {
    console.error('[GameLoader] ✗ Mount failed:', e);
    // Retry after a short delay
    setTimeout(tryMountArchive, 100);
  }
}

// Hook into onRuntimeInitialized to mount when runtime is ready
var _originalOnRuntimeInitialized = Module.onRuntimeInitialized;
Module.onRuntimeInitialized = function() {
  console.log('[GameLoader] onRuntimeInitialized called, attempting mount...');
  tryMountArchive();
  
  // Call original if it existed
  if (_originalOnRuntimeInitialized && typeof _originalOnRuntimeInitialized === 'function') {
    _originalOnRuntimeInitialized();
  }
};

// Also try mounting periodically until we succeed (fallback)
setTimeout(function checkMount() {
  if (!_gameArchiveMounted && _gameArchiveBuffer) {
    tryMountArchive();
    if (!_gameArchiveMounted) {
      setTimeout(checkMount, 200);
    }
  }
}, 100);

