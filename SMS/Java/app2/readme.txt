Application 2 – Vote tallying application which checks all messages sent to a particular short code. Results are placed in a server file. A web page allows viewing the results and enables the user to request the server to re-compute the vote total.

Pattern: Server application, no end-user context required.

To use the functions in index.jsp, you will first be redirected to oauthSS.jsp to get an Access Token.
Once received, oauthSS.jsp will save this Access Token as a session variable accessible to index.jsp
and redirect you back to index.jsp.

Installation:
1. Install Apache Tomcat 7.0 web server and configure java environment.
2. Deploy source folder through Tomcat manager, or place contents in Tomcat directory under i.e. webapps/tally
3. Access the scriptlet by directing your browser to http://localhost:8080/tally, for example.

Configuration:
1. Open oauthSS.jsp with an editor and enter your API Key and API Secret for variables clientId and clientSecret,
respectively. These were provided when you registered your app.
2. Open index.jsp with an editor and enter your short code for the variable registrationID.