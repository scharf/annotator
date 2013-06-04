BrowserApi = function () 
{
}

BrowserApi.prototype = 
{
	getURL: function (url) 
	{
		return chrome.extension.getURL(url);
	},
	
	getCookie: function (cookie, callback) 
	{
		chrome.cookies.get(cookie, callback);
	},

	removeCookie: function (cookie) 
	{
		chrome.cookies.remove(cookie);
	},

	getAllTabs: function (callback) 
	{
		chrome.windows.getAll({populate: true}, function (callback) 
		{
			return function (windows) 
			{
				var tabs = [];
				for (i in windows)
					tabs = tabs.concat(windows[i].tabs);
				callback(tabs);
			}
		}(callback));
	},

	updateTab: function (tab, update) 
	{
		chrome.tabs.update(tab.id, update);
	},

	closeTab: function (tabId) 
	{
		chrome.tabs.remove(tabId);
	},

	isNewTab: function (tab) 
	{
		return tab.url == 'chrome://newtab/' ? true : false;
	},

	setBrowserButtonListener: function (callback) 
	{
		chrome.browserAction.onClicked.addListener(callback);
	},

	setMessageListener: function (callback) 
	{
		chrome.extension.onRequest.addListener(callback);
	},
	
	sendBackgroundRequest: function (request, callback) 
	{
		chrome.extension.sendRequest(request, callback);
	},
	
	sendTabRequest: function (tabId, request, callback) 
	{
		chrome.tabs.sendRequest(tabId, request, callback);
	},
	
	setIcon: function (details) 
	{
		chrome.browserAction.setIcon(details);
	},

	ajaxRequest: function (host, args, callback, errorCallback) 
	{
	    $.ajax(
	    {
	      type: args.type,
	      url: host + '/api' + args.uri,
	      data: args.data,
	      context: args.context,
	      dataType: 'json',
	      error: errorCallback,
	      success: callback
	    });
	},

	getTabId: function (tab) 
	{
	    return tab.id;
	}

}
