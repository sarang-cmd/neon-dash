#!/usr/bin/env python3
"""
Custom HTTP server that enables SharedArrayBuffer via cross-origin headers.
Required for love.js web runtime which uses WebWorkers for threading.
"""
import http.server
import socketserver
import os
import sys

class CORPHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add COOP and COEP headers to enable SharedArrayBuffer
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

    def log_message(self, format, *args):
        # Quiet logging
        if '404' not in format:
            sys.stderr.write("[%s] %s\n" % (self.log_date_time_string(), format%args))

if __name__ == '__main__':
    os.chdir('/workspaces/neon-dash/web')
    PORT = 9000
    Handler = CORPHandler
    
    socketserver.TCPServer.allow_reuse_address = True
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"🎮 NEON DASH server running on http://0.0.0.0:{PORT}/")
        print(f"📍 Visit: http://localhost:{PORT}/")
        print(f"✓ SharedArrayBuffer enabled via COOP/COEP headers\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n⏹  Server stopped")
