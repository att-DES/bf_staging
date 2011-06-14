<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="org.apache.commons.httpclient.*"%>
<%@ page import="org.apache.commons.httpclient.methods.*"%>
<%@ page import="org.json.JSONObject"%>
<%
String clientId = request.getParameter("clientId");
if(clientId==null)
	clientId = (String) session.getAttribute("clientId");
if(clientId==null)
	clientId = "bb823da54e6f70f4387b39b285dcaa9d";
String clientSecret = request.getParameter("clientSecret");
if(clientSecret==null)
	clientSecret = (String) session.getAttribute("clientSecret");
if(clientSecret==null)
	clientSecret = "0790582c85fcb860";
String redirectUri = request.getParameter("redirectUri");
String scope = request.getParameter("scope");
String code = request.getParameter("code");
if(code==null) code="";
String print = "";
String getExtCode = request.getParameter("getExtCode");
String refreshToken = request.getParameter("refreshToken");
if (refreshToken==null) 
	refreshToken=(String) session.getAttribute("refreshToken");
if (refreshToken==null) 
	refreshToken="";
String getRefreshToken = request.getParameter("getRefreshToken");
if (getRefreshToken==null) getRefreshToken="";
%>

<form name="getExtCode" method="post">
API Key <input type="text" name="clientId" value="<%=clientId%>" size=40 /><br>
API Secret <input type="text" name="clientSecret" value="<%=clientSecret%>" size=40 /><br>
Scope <input type="text" name="scope" value="SMS,MMS,WAP,DC,TL,PAYMENT" size=40 /><br />
Redirect URI <input type="text" name="redirectUri" value="http://ddprdm.net:8080/apigee-public/oauth.jsp" size=60 /><br />
<input type="submit" name="getExtCode" value="Get Access Token" />
</form><br><br>

   <%   
   	   if(getExtCode!=null) {
   		   session.setAttribute("clientId", clientId);
   		   session.setAttribute("clientSecret", clientSecret);
   		   response.sendRedirect("https://beta-api.att.com/oauth/authorize?client_id=" + clientId + "&scope=" + scope + "&redirect_uri=" + redirectUri);
   	   }
   
       if(!code.equalsIgnoreCase("")) {
           String url ="https://beta-api.att.com/oauth/access_token";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);   
           method.setQueryString("grant_type=authorization_code&client_id=" + clientId + "&client_secret=" + clientSecret + "&code=" + code);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
           if(statusCode==200){ 
            	JSONObject rpcObject = new JSONObject(method.getResponseBodyAsString());
            	String accessToken = rpcObject.getString("access_token");
            	refreshToken = rpcObject.getString("refresh_token");
            	session.setAttribute("refreshToken", refreshToken);
               	session.setAttribute("accessToken", accessToken);

           	String postOauth = (String) session.getAttribute("postOauth");
           	if(postOauth!= null) {
           		session.setAttribute("postOauth", null);
           		response.sendRedirect(postOauth);
           	}
           }
           method.releaseConnection();
       }
   %>   

<form name="getRefreshToken" method="post">
API Key <input type="text" name="clientId" value="<%=clientId%>" size=40 /><br />
API Secret <input type="text" name="clientSecret" value="<%=clientSecret%>" size=40 /><br />
Refresh Token <input type="text" name="refreshToken" value="<%=refreshToken%>" size=60 /><br />
<input type="submit" name="getRefreshToken" value="Refresh Access Token" />
</form><br><br>

   <%   
       if(!getRefreshToken.equalsIgnoreCase("")) {
           String url ="https://beta-api.att.com/oauth/access_token";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);   
           method.setQueryString("grant_type=refresh_token&client_id=" + clientId + "&client_secret=" + clientSecret + "&refresh_token=" + refreshToken);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
           if(statusCode==200){ 
           	String accessToken = print.substring(18,50);
           	session.setAttribute("accessToken", accessToken);
           	String postOauth = (String) session.getAttribute("postOauth");
           	if(postOauth!= null) {
           		session.setAttribute("postOauth", null);
           		response.sendRedirect(postOauth);
           	}
           }
           method.releaseConnection();
       }
   %> 
<br><br><html><body><%=print%></body></html>