const STATE_DISABLED = 0
const STATE_ENABLED = 1
const STATE_ACTIVE = 2

const ICON_SIZE = 48

var enabled = true;
var loaded = [];

var canvas = document.createElement('canvas');
var icon = new Image();
icon.src = chrome.extension.getURL('img/annotator-icon-sprite.png');
icon.alt = 'Annotate';
icon.onload = setIcon;

function setIcon(tabId) {
	var state = (loaded[tabId] && enabled) ? STATE_ENABLED : STATE_DISABLED;
	var ctx = canvas.getContext('2d');
	ctx.drawImage(icon, ICON_SIZE * state, 0, ICON_SIZE, ICON_SIZE, 0, 0, 19, 19);
	chrome.browserAction.setIcon({
		imageData: ctx.getImageData(0, 0, 19, 19)
	})
}

chrome.browserAction.onClicked.addListener(function(tab) {
	if (loaded[tab.id])
	{
		loaded[tab.id] = false;
		chrome.tabs.reload(tab.id, {}, function() {
			setIcon(tab.id);
		});
	}
	else
	{
		var message = 'load';
		chrome.tabs.sendRequest(tab.id, {annotator: message}, function (response) {
			if (response.error) {
				throw response.error;
			} 
			else {
				loaded[tab.id] = true;
			}
			setIcon(tab.id);
		});
	}
});

chrome.tabs.onActivated.addListener(function(activeInfo) {
	setIcon(activeInfo.tabId);
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
	//console.log('tab updated');
	loaded[tabId] = false;
});

/*
chrome.browserAction.onClicked.addListener(function(tab) {
	var message = loaded ? (enabled ? 'hide' : 'show') : 'load'
	window.messenger.sendRequest({annotator: message}, function (response) {
		if (response.error) {
			throw response.error;
		} 
		else {
			if (!loaded) 
				loaded = true;
			enabled = !enabled;
		}
	});
});
*/
