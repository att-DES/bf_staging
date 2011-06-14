<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="org.apache.commons.httpclient.*"%>
<%@ page import="org.apache.commons.httpclient.methods.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.w3c.dom.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="javax.xml.transform.*" %>
<%@ page import="javax.xml.transform.stream.*" %>
<%@ page import="javax.xml.transform.dom.*" %>
<%
	String accessToken = request.getParameter("access_token");
	if(accessToken==null || accessToken=="null"){
		accessToken = (String) session.getAttribute("accessToken");}
	if(accessToken==null || accessToken=="null") {
		accessToken = "";
		session.setAttribute("postOauth", "SMS.jsp");
		%><a href="oauth.jsp">Authenticate first</a><br><br><%
	}
	String address = request.getParameter("address");
	String message = request.getParameter("message");
	String smsId = request.getParameter("smsId");
	if (smsId==null) smsId = (String) session.getAttribute("smsId");
	if (smsId==null) smsId = "";
	String requestFormat = request.getParameter("requestFormat");
	String responseFormat = request.getParameter("responseFormat");
	String getSmsDeliveryStatus = request.getParameter("getSmsDeliveryStatus");
	String sendSms = request.getParameter("sendSms");
	String getReceivedSms = request.getParameter("getReceivedSms");
	String registrationID = request.getParameter("registrationID");
	if(registrationID==null || registrationID=="null"){
		registrationID = (String) session.getAttribute("registrationID");}
	if(registrationID==null || registrationID=="null"){
		registrationID = "";}
	String print = "";
%> <br>


<form name="sendSms" method="post">
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	MSISDN <input type="text" name="address" value="tel:" /><br />
	Message <input type="text" name="message" value="Test." size=40/><br />
	Request Format: <input type="radio" name="requestFormat" value="xml">XML<input type="radio" name="requestFormat" value="json" checked>JSON<input type="radio" name="requestFormat" value="form-encoded">Form-encoded<br/>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="sendSms" value="Send SMS"/>
</form><br>

   <%   
       if(sendSms!=null) {
           String url ="https://beta-api.att.com/1/messages/outbox/sms";   
           HttpClient client = new HttpClient();
           PostMethod method = new PostMethod(url);  
           
if(requestFormat.equalsIgnoreCase("xml")){       
         DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
         DocumentBuilder builder = factory.newDocumentBuilder();
         DOMImplementation impl = builder.getDOMImplementation();
         Document doc = impl.createDocument(null,null,null);
         Element e1 = doc.createElement("sms-request");
         doc.appendChild(e1);
         Element e2 = doc.createElement("address");
         e1.appendChild(e2);
         e2.setTextContent(address);
         Element e3 = doc.createElement("message");
         e1.appendChild(e3);
         e3.setTextContent(message);
         // transform the Document into a String
         DOMSource domSource = new DOMSource(doc);
         TransformerFactory tf = TransformerFactory.newInstance();
         Transformer transformer = tf.newTransformer();
         transformer.setOutputProperty(OutputKeys.METHOD, "xml");
         transformer.setOutputProperty(OutputKeys.ENCODING,"UTF-8");
         transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
         transformer.setOutputProperty(OutputKeys.STANDALONE,"yes");
         transformer.setOutputProperty(OutputKeys.INDENT, "yes");
         java.io.StringWriter sw = new java.io.StringWriter();
         StreamResult sr = new StreamResult(sw);
         transformer.transform(domSource, sr);
         String xml = sw.toString();
         System.out.println(xml);
         method.setRequestBody(xml);
         method.addRequestHeader("Content-Type","application/xml");
} else if(requestFormat.equalsIgnoreCase("json")) { 
			JSONObject rpcObject = new JSONObject();
   		 	rpcObject.put("message", message);
   		 	rpcObject.put("address", address);
   		 	method.setRequestBody(rpcObject.toString());
   			method.addRequestHeader("Content-Type","application/json; charset=UTF-8");
   			
} else if(requestFormat.equalsIgnoreCase("form-encoded")){
   			 NameValuePair nvp1= new NameValuePair("message",message);
   			 NameValuePair nvp2= new NameValuePair("address",address);
   			 method.addRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
   		     method.setRequestBody(new NameValuePair[] {nvp1,nvp2});
}
           method.setQueryString("access_token=" + accessToken);
           method.addRequestHeader("Accept","application/" + responseFormat);
           int statusCode = client.executeMethod(method); 
           if(statusCode==201) {
           	if(responseFormat.equalsIgnoreCase("json")) {
           		JSONObject jsonResponse = new JSONObject(method.getResponseBodyAsString());
           		smsId = jsonResponse.getString("id");
           		session.setAttribute("smsId",smsId);
           		print = method.getResponseBodyAsString();
           	}
           	else if(responseFormat.equalsIgnoreCase("xml")) {
           		DocumentBuilderFactory factoryForResponse = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factoryForResponse.newDocumentBuilder();
                print = method.getResponseBodyAsString();
           	    Document xmlDoc = builder.parse(method.getResponseBodyAsStream());
           	    smsId = xmlDoc.getDocumentElement().getAttribute("id");
          	    session.setAttribute("smsId",smsId);
           	}
           } else {
        	   print = method.getResponseBodyAsString();
           }
           
           method.releaseConnection();
       }
   %>   

<form name="getSmsDeliveryStatus" action="" method="get">
	Request Identifier <input type="text" name="id" value="<%=smsId%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="getSmsDeliveryStatus" value="Get SMS Delivery Status" />
</form><br><br>

   <%  
       if(getSmsDeliveryStatus!=null) {
           String url ="https://beta-api.att.com/1/messages/outbox/sms/" + smsId;   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&id=" + smsId);
           method.addRequestHeader("Accept","application/" + responseFormat);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
           System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %>     

<form name="getReceivedSms" action="" method="get">
	Registration ID <input type="text" name="registrationID" value="<%=registrationID%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="getReceivedSms" value="Get Received Sms" />
</form>

   <%  
       if(getReceivedSms!=null) {
           String url ="https://beta-api.att.com/1/messages/inbox/sms";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&registrationID=" + registrationID);
           method.addRequestHeader("Accept","application/" + responseFormat);
           session.setAttribute("registrationID", registrationID);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
           System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %>  
<br><br><html><body><%=print%></body></html>