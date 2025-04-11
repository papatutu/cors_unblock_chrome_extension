# CORS Unblock Chrome Extension

A simple Chrome extension to bypass CORS (Cross-Origin Resource Sharing) restrictions for all websites.

## Features

- Automatically modifies response headers to allow cross-origin requests
- Works on all websites
- Simple toggle to enable/disable the extension
- Visual indicator showing the current state
- Uses Chrome's Declarative Net Request API for better performance

## How It Works

This extension uses Chrome's `declarativeNetRequest` API to modify the following headers in HTTP responses:

- `Access-Control-Allow-Origin: *` (allows requests from any origin)
- `Access-Control-Allow-Methods` (allows all common HTTP methods)
- `Access-Control-Allow-Headers: *` (allows all request headers)
- `Access-Control-Allow-Credentials: true` (allows credentials to be sent)
- `Access-Control-Max-Age: 1728000` (caches preflight requests)
- `Cross-Origin-Resource-Policy: cross-origin`
- `Cross-Origin-Embedder-Policy: credentialless`

These modifications allow your browser to access resources from any domain, bypassing the CORS restrictions that would normally block such requests.

## Installation

### From Source

1. Download or clone this repository
2. Open Chrome and navigate to `chrome://extensions/`
3. Enable "Developer mode" using the toggle in the top-right corner
4. Click "Load unpacked" and select the directory containing the extension files
5. The extension will appear in your toolbar and is enabled by default

### From Chrome Web Store

*Coming soon*

## Usage

1. Click the extension icon in the toolbar to open the popup
2. Use the toggle switch to enable or disable CORS unblocking
3. The status text will indicate whether the extension is currently active
4. No other configuration needed - it just works!

## Use Cases

- Testing APIs without configuring CORS on the server
- Accessing resources from different domains in local development
- Working with third-party APIs that don't have CORS enabled
- Developing web applications that need to access resources from different origins

## Technical Details

This extension uses:
- Chrome's Manifest V3
- `declarativeNetRequest` API for header modification
- Background service worker
- Local storage to remember the enabled/disabled state

## Privacy & Permissions

This extension requires the following permissions:
- `declarativeNetRequest`: To modify response headers
- `storage`: To save your preferences
- `<all_urls>`: To work on all websites

The extension does not collect any data, track your browsing, or send any information to external servers.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details

## Disclaimer

This extension is intended for development and testing purposes only. Using it in production environments may pose security risks by bypassing security mechanisms designed to protect your browser and data. Use at your own risk.