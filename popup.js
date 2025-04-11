// Wait for the DOM to be loaded
document.addEventListener('DOMContentLoaded', () => {
  const toggleCheckbox = document.getElementById('toggle');
  const statusElement = document.getElementById('status');
  
  // Get current state from background script
  chrome.runtime.sendMessage({ action: 'getState' }, (response) => {
    if (response && response.enabled !== undefined) {
      toggleCheckbox.checked = response.enabled;
      updateStatusText(response.enabled);
    }
  });
  
  // Handle toggle changes
  toggleCheckbox.addEventListener('change', () => {
    chrome.runtime.sendMessage({ action: 'toggle' }, (response) => {
      if (response && response.enabled !== undefined) {
        updateStatusText(response.enabled);
      }
    });
  });
  
  // Update status text based on state
  function updateStatusText(enabled) {
    statusElement.textContent = enabled ? 'Enabled' : 'Disabled';
    statusElement.style.color = enabled ? '#4CAF50' : '#F44336';
  }
});