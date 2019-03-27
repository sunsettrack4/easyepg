var webPage = require('webpage');
var page = webPage.create();

page.open('https://zattoo.com/login', function (status) {
	setTimeout(function() {
		var cookies = page.cookies;
  
		console.log('Listing cookies:');
		for(var i in cookies) {
			console.log(cookies[i].name + '=' + cookies[i].value);
		}
  
		phantom.exit();
	}, 5000);
});
