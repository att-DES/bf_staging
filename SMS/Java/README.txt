Application 1 – Allows end-user to perform three functions: 
1.	send SMS message to phone number they designate; 
2.	check status of message sent per (1);
3.	read queued SMS messages assuming device is off so messages are pending delivery.

Pattern: Server application, User Experience web page based, requires end-user context.

To use the functions in SMS.jsp, you will first be redirected to oauth.jsp to get an Access Token. 
Once received, oauth.jsp will save this Access Token as a session variable accessible to SMS.jsp 
and redirect you back to SMS.jsp.

Installation:
1. Install Apache Tomcat 7.0 web server and configure java environment.
2. Deploy source folder through Tomcat manager, or place contents in Tomcat directory under i.e. webapps/SMS
3. Access the scriptlet by directing your browser to http://localhost:8080/SMS/SMS.jsp, for example.

Configuration:
1. Open oauth.jsp with an editor and enter your API Key and API Secret for variables clientId and clientSecret, 
	respectively. These were provided when you registered your app.
2. You may also wish to configure the oauth.jsp scriptlet for external access by changing the redirectUri variable 
	in oauth.jsp to include your web server's external IP address instead of localhost.
3. If you are using a payment method, open index.jsp with an editor and change the default values for the three 
	redirect URIs, i.e. fulfillment redirect URI, cancel redirect URI, status callback redirect URI. 
	These should be set to your external IP address instead of localhost. 