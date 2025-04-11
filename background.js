// Background script for CORS Unblock extension

// Initialize the extension
chrome.runtime.onInstalled.addListener(() => {
  console.log('CORS Unblock extension has been installed.');
  
  // Set default state to enabled
  chrome.storage.local.set({ enabled: true }, () => {
    console.log('CORS Unblock is enabled by default.');
    updateIcon(true);
  });
});

// Listen for messages from the popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'getState') {
    chrome.storage.local.get(['enabled'], (result) => {
      sendResponse({ enabled: result.enabled });
    });
    return true; // Required for async sendResponse
  }
  
  if (message.action === 'toggle') {
    chrome.storage.local.get(['enabled'], (result) => {
      const newState = !result.enabled;
      chrome.storage.local.set({ enabled: newState }, () => {
        updateIcon(newState);
        sendResponse({ enabled: newState });
      });
    });
    return true; // Required for async sendResponse
  }
});

// Update the extension icon based on state
function updateIcon(enabled) {
  const iconPath = enabled ? 'images/icon' : 'images/icon_disabled';
  chrome.action.setIcon({
    path: {
      16: `${iconPath}16.png`,
      32: `${iconPath}32.png`,
      48: `${iconPath}48.png`,
      128: `${iconPath}128.png`
    }
  });
}