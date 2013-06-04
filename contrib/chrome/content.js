/*
 * Listen for requests from the background scripts. Since the annotator code is
 * loaded in the page context, background events which interact with the
 * annotator user interface, such as showing or hiding the annotator need to be
 * handled here.
 */
chrome.extension.onRequest.addListener(
	function (request, sender, sendResponse) 
	{
		var command = request.annotator;
		if (command) 
		{
			if (command === 'load') 
			{
				$(document.body).annotator().annotator('setupPlugins');
				
				var options = {};
				options.categories = {
					'highlight':'annotator-hl-highlight', 
					'underline':'annotator-hl-underline', 
					'rect':'annotator-hl-rect', 
					'bold':'annotator-hl-bold' 
				};

				$(document.body).annotator().annotator('addPlugin', 'Categories', options.categories);
				
				sendResponse({ok: true});
			} 
			else if (command === 'hide') 
			{
				console.log('got hide');
				sendResponse({ok: true});
			}
			else if (command === 'show') 
			{
				console.log('got show');
				sendResponse({ok: true});
			} 
			else 
			{
				sendResponse({error: new TypeError("not implemented: " + command)});
			}
		}
	}
)
