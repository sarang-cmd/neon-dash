// Emscripten game package loader for love.js
// Delays game boot until we can mount game.love to the virtual filesystem

var Module = Module || {};

// Global state
var _gameArchiveBuffer = null;
var _gameArchiveMounted = false;

console.log('[GameLoader] Fetching game.love asynchronously...');

// Fetch game archive
fetch('game.love')
  .then(response => {
    if (!response.ok) throw new Error('HTTP ' + response.status);
    return response.arrayBuffer();
  })
  .then(buffer => {
    _gameArchiveBuffer = buffer;
    console.log('[GameLoader] ✓ game.love fetched:', buffer.byteLength, 'bytes');
  })
  .catch(err => {
    console.error('[GameLoader] ✗ Fetch failed:', err);
  });

// Try to access FS and mount the archive
function mountArchive() {
  if (_gameArchiveMounted || !_gameArchiveBuffer) return false;
  
  // FS might be available as a global, or through IDBFS, or embedded in love.js
  // Try multiple access paths
  var FS = null;
  if (typeof globalThis !== 'undefined' && globalThis.FS) {
    FS = globalThis.FS;
  } else if (typeof window !== 'undefined' && window.FS) {
    FS = window.FS;
  } else if (Module.FS) {
    FS = Module.FS;
  }
  
  if (!FS) {
    console.log('[GameLoader] FS not available, will retry...');
    return false;
  }

  try {
    console.log('[GameLoader] Mounting game.love to FS...');
    var archiveData = new Uint8Array(_gameArchiveBuffer);
    
    // Create root directory if needed
    try {
      FS.stat('/');
    } catch(e) {
      console.log('[GameLoader] Creating root directory...');
      FS.mkdir('/');
    }
    
    // Mount the file
    FS.createDataFile('/', 'game.love', archiveData, true, true);
    console.log('[GameLoader] ✓ game.love mounted successfully');
    
    // Verify
    var stat = FS.stat('/game.love');
    console.log('[GameLoader] ✓ Verified: size =', stat.size, 'bytes');
    _gameArchiveMounted = true;
    return true;
    
  } catch(e) {
    console.error('[GameLoader] Mount failed:', e.message);
    return false;
  }
}

// Hook into postRun - fires AFTER love.js runtime is fully initialized
if (!Module.postRun) Module.postRun = [];
Module.postRun.push(function() {
  console.log('[GameLoader] postRun: Attempting late mount...');
  
  var maxAttempts = 50;
  var attempt = 0;
  
  var tryMount = function() {
    attempt++;
    if (mountArchive()) {
      console.log('[GameLoader] ✓ Archive mounted in postRun');
      return;
    }
    
    if (attempt < maxAttempts) {
      setTimeout(tryMount, 50);
    } else {
      console.error('[GameLoader] ✗ Failed to mount after', maxAttempts, 'attempts');
    }
  };
  
  tryMount();
});

// Also try mounting as soon as the archive is fetched
var originalFetch = window.fetch;
Object.defineProperty(window, '_gameArchiveBuffer', {
  set: function(val) {
    if (val && !_gameArchiveMounted) {
      console.log('[GameLoader] Archive available, attempting immediate mount...');
      setTimeout(mountArchive, 10);
    }
  }
});

