
var BackgroundMessenger = (function () 
{
    function BackgroundMessenger() 
    {
  		this.nextRequestId = 0;

		// Init listener for messages from content scripts
		window.browser.setMessageListener(function (obj) 
		{
			return function(request, sender, sendResponse) 
			{
				obj.handleRequest(request, sender, sendResponse);
			}
		}(this));
    }

	// Handles a request from a content script
	BackgroundMessenger.prototype.handleRequest = function (request, sender, sendResponse) 
	{
		if (request.type == 'func') 
		{
			var args = request.args ? request.args : [];
			for (i in args) 
			{
				if (args[i] == '__tab__')
				{
					args[i] = sender.tab.id;
				}
			}
			response = window[request.inst][request.func].apply(window[request.inst],args);
			return sendResponse(response);
		}
		else if (request.type == 'data') 
		{
			response = window[request.inst][request.attr];
			return sendResponse(response);
		}
		else if (request.type == 'api') 
		{
			var callback = function (response) 
			{
				response = { status: 'success', data: response }
				sendResponse(response);
			}
			var errorCallback = function (response) 
			{
				response = { status: 'error', data: response }
				sendResponse(response);
			}
			window.api.request(request.args, callback, errorCallback);
		}
	
	};


	// Sends a message to each tab's content script individually
	// If a callback is supplied, it runs for every tab, including the tab id as a parameter
	BackgroundMessenger.prototype.sendRequest = function (request, callback) 
	{
		window.browser.getAllTabs(function (obj, callback) 
		{
			return function (tabs) 
			{
				for (i in tabs) 
				{
					var tabId = window.browser.getTabId(tabs[i]);
					obj.sendSingleTabRequest(tabId, request, function (tabId, callback) 
					{
						return function (response) 
						{
							if (typeof callback == 'function')
							{
								callback(tabId, response);
							}
						}
					}(tabId, callback));
				}
			}
		}(this, callback));
	};

	// Sends a message to a single tab only
	BackgroundMessenger.prototype.sendSingleTabRequest = function (tabId, request, callback)
	{
		request.id = this.nextRequestId++;
		window.browser.sendTabRequest(tabId, request, callback);
	};

    return BackgroundMessenger;
})();
