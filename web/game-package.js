// Emscripten data package loader for game.love
// This tells the Emscripten runtime how to download and manage game.love
var Module = Module || {};
Module.expectedDataFileDownloads = 1;
Module.finishedDataFileDownloads = 0;

if (!Module.hasOwnProperty('dataFileDownloads')) {
  Module.dataFileDownloads = {};
}

(function() {
  var PACKAGE_PATH = typeof window === 'object' ? window.location.pathname.split('/').slice(0, -1).join('/') + '/' : '';
  var REMOTE_PACKAGE_BASE = 'game.love';
  var REMOTE_PACKAGE_SIZE = 25107;
  var PACKAGE_UUID = 'neon-dash-game';

  function processPackageData(arrayBuffer) {
    Module.finishedDataFileDownloads++;
    function runWithFS() {
      function assert(check, message) {
        if (!check) throw message;
      }
      var entries = {};
      entries['game.love'] = {
        url: REMOTE_PACKAGE_BASE,
        packOffset: 0,
        packSize: REMOTE_PACKAGE_SIZE
      };

      var files = Module['getPreloadedPackages']
        ? Module['getPreloadedPackages']()
        : [entries];

      function installPackage(pack) {
        var metadata = pack['metadata'];
        var index = pack['blob_index'];
        var needsAnimationFrame = false;
        
        // Write game.love to FS
        if (typeof FS !== 'undefined' && FS.createDataFile) {
          try {
            var fileData = new Uint8Array(arrayBuffer);
            FS.createDataFile('/', 'game.love', fileData, true, true);
            console.log('✓ [Package Loader] game.love installed to FS (' + fileData.length + ' bytes)');
          } catch(e) {
            console.error('✗ [Package Loader] Failed to install:', e);
          }
        }
      }

      if (Module['calledRun']) {
        installPackage(files[0]);
      } else {
        if (!Module.preRun) Module.preRun = [];
        Module.preRun.push(function() {
          installPackage(files[0]);
        });
      }
      
      Module.finishedDataFileDownloads++;
    }
    if (Module['calledRun']) {
      runWithFS();
    } else {
      if (!Module.preRun) Module.preRun = [];
      Module.preRun.push(runWithFS);
    }
  }

  function fetchRemotePackage(packageName, packageSize, callbacks) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', packageName, true);
    xhr.responseType = 'arraybuffer';
    xhr.onprogress = function(event) {
      if (callbacks.onProgress) {
        callbacks.onProgress(event.loaded, packageSize);
      }
    };
    xhr.onerror = function() {
      if (callbacks.onError) callbacks.onError();
    };
    xhr.onload = function() {
      if (callbacks.onLoad) callbacks.onLoad(xhr.response);
    };
    xhr.send(null);
  }

  Module.setStatus('Downloading game data...');
  console.log('[Package Loader] Fetching game.love from', REMOTE_PACKAGE_BASE);
  
  fetchRemotePackage(REMOTE_PACKAGE_BASE, REMOTE_PACKAGE_SIZE, {
    onLoad: processPackageData,
    onProgress: function(loaded, total) {
      if (Module.setStatus) {
        Module.setStatus('Downloading game data... (' + Math.floor(100 * loaded / total) + '%)');
      }
    },
    onError: function() {
      console.error('✗ Failed to fetch game.love');
      throw new Error('Failed to fetch game package');
    }
  });
})();
