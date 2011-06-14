<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="org.apache.commons.httpclient.*"%>
<%@ page import="org.apache.commons.httpclient.methods.*"%>
<%@ page import="org.json.*"%>
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
	session.setAttribute("postOauth", "transaction.jsp");
	%><a href="oauth.jsp">Authenticate first</a><br><br><%
}
String amount = request.getParameter("amount");
String autoCommit = request.getParameter("autoCommit");
String category = request.getParameter("category");
String channel = request.getParameter("channel");
String currency = request.getParameter("currency");
String description = request.getParameter("description");
String extTrxID = request.getParameter("extTrxID");
String appID = request.getParameter("appID");
String cancelUrl = request.getParameter("cancelUrl");
String fulfillUrl = request.getParameter("fulfillUrl");
String productID = request.getParameter("productID");
String purchaseNoSub = request.getParameter("purchaseNoSub");
String statusUrl = request.getParameter("statusUrl");
String trxID = request.getParameter("trxID");
if(trxID==null || trxID=="null"){
	trxID = (String) session.getAttribute("trxID");}
if(trxID==null || trxID=="null") {
	trxID = "";}
String refund = request.getParameter("refund");
String newTransaction = request.getParameter("newTransaction");
String getTransactionStatus = request.getParameter("getTransactionStatus");
String commitTransaction = request.getParameter("commitTransaction");
String refundTransaction = request.getParameter("refundTransaction");
String responseFormat = request.getParameter("responseFormat");
String print = "";
String requestFormat = request.getParameter("requestFormat");
%>

<table><tr><td>
<form name="newTransaction" method="post">
Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
Amount <input type="text" name="amount" value="0.05" /><br />
Auto Commit <input type="text" name="autoCommit" value="false" /><br />
Category <input type="text" name="category" value="1" /><br />
Channel <input type="text" name="channel" value="MOBILE_WEB" /><br />
Currency <input type="text" name="currency" value="USD" /><br />
Description <input type="text" name="description" value="ProductByMe" /><br />
Transaction ID <input type="text" name="extTrxID" value="Transaction151" /><br />
App ID <input type="text" name="appID" value="testApp" /><br />
Cancel Redirect Url <input type="text" name="cancelUrl" value="http://ddprdm.net:8080/apigee-public/transaction.jsp" size=60/><br />
Fulfillment Url <input type="text" name="fulfillUrl" value="http://ddprdm.net:8080/apigee-public/transaction.jsp" size=60/><br />
Product ID <input type="text" name="productID" value="Product252" /><br />
PurhcaseOnNoActiveSubscription <input type="text" name="purchaseNoSub" value="false" /><br />
Status Url <input type="text" name="statusUrl" value="http://ddprdm.net:8080/apigee-public/transaction.jsp" size=60/><br />
Request Format: <input type="radio" name="requestFormat" value="xml">XML<input type="radio" name="requestFormat" value="json" checked>JSON<input type="radio" name="requestFormat" value="form-encoded">Form-encoded<br/>
Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
<input type="submit" name="newTransaction" value="Click to make new transaction" />
</form><br>


<%  
if(newTransaction!=null) {
    String url ="https://beta-api.att.com/1/payments/transactions";   
    HttpClient client = new HttpClient();
    PostMethod method = new PostMethod(url);  
    method.setQueryString("access_token=" + accessToken);
    if (responseFormat.equalsIgnoreCase("json"))
    	method.addRequestHeader("Accept","application/json");
    else if (responseFormat.equalsIgnoreCase("xml"))
    	method.addRequestHeader("Accept","application/xml");
    
    if (requestFormat.equalsIgnoreCase("json")) {
        method.addRequestHeader("Content-Type","application/json");
        JSONObject bodyObject = new JSONObject();
        bodyObject.put("amount",Double.parseDouble(amount));
        bodyObject.put("autoCommit",Boolean.parseBoolean(autoCommit));
        bodyObject.put("category",category);
        bodyObject.put("channel",channel);
        bodyObject.put("currency",currency);
        bodyObject.put("description",description);
        bodyObject.put("externalMerchantTransactionID",extTrxID);
        bodyObject.put("merchantApplicationID",appID);
        bodyObject.put("merchantCancelRedirectUrl",cancelUrl);
        bodyObject.put("merchantFulfillmentRedirectUrl",fulfillUrl);
        bodyObject.put("merchantProductID",productID);
        bodyObject.put("purchaseOnNoActiveSubscription",Boolean.parseBoolean(purchaseNoSub));
        bodyObject.put("transactionStatusCallbackUrl",statusUrl);
        method.setRequestBody(bodyObject.toString()); 
    } else if (requestFormat.equalsIgnoreCase("xml")) {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        DOMImplementation impl = builder.getDOMImplementation();
        Document doc = impl.createDocument(null,null,null);
        Element e1 = doc.createElement("newTransactionRequest");
        doc.appendChild(e1);
        Element e2 = doc.createElement("amount");
        e1.appendChild(e2);
        e2.setTextContent(amount);
        Element e3 = doc.createElement("autoCommit");
        e1.appendChild(e3);
        e3.setTextContent(autoCommit);
        Element e4 = doc.createElement("category");
        e1.appendChild(e4);
        e4.setTextContent(category);
        Element e5 = doc.createElement("channel");
        e1.appendChild(e5);
        e5.setTextContent(channel);
        Element e6 = doc.createElement("currency");
        e1.appendChild(e6);
        e6.setTextContent(currency);
        Element e7 = doc.createElement("description");
        e1.appendChild(e7);
        e7.setTextContent(description);
        Element e8 = doc.createElement("externalMerchantTransactionID");
        e1.appendChild(e8);
        e8.setTextContent(extTrxID);
        Element e9 = doc.createElement("merchantApplicationID");
        e1.appendChild(e9);
        e9.setTextContent(appID);
        Element e10 = doc.createElement("merchantCancelRedirectUrl");
        e1.appendChild(e10);
        e10.setTextContent(cancelUrl);
        Element e11 = doc.createElement("merchantFulfillmentRedirectUrl");
        e1.appendChild(e11);
        e11.setTextContent(fulfillUrl);
        Element e12 = doc.createElement("merchantProductID");
        e1.appendChild(e12);
        e12.setTextContent(productID);
        Element e13 = doc.createElement("purchaseOnNoActiveSubscription");
        e1.appendChild(e13);
        e13.setTextContent(purchaseNoSub);
        Element e14 = doc.createElement("transactionStatusCallbackUrl");
        e1.appendChild(e14);
        e14.setTextContent(statusUrl);

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
    } else if(requestFormat.equalsIgnoreCase("form-encoded")){
   			NameValuePair nvp1= new NameValuePair("amount",amount);
   			NameValuePair nvp2= new NameValuePair("autoCommit",autoCommit);
   			NameValuePair nvp3= new NameValuePair("category",category);
   			NameValuePair nvp4= new NameValuePair("channel",channel);
   			NameValuePair nvp5= new NameValuePair("description",description);
   			NameValuePair nvp6= new NameValuePair("currency",currency);
   			NameValuePair nvp7= new NameValuePair("externalMerchantTransactionID",extTrxID);
   			NameValuePair nvp8= new NameValuePair("merchantApplicationID",appID);
   			NameValuePair nvp9= new NameValuePair("merchantCancelRedirectUrl",cancelUrl);
   			NameValuePair nvp10= new NameValuePair("merchantFulfillmentRedirectUrl",fulfillUrl);
   			NameValuePair nvp11= new NameValuePair("merchantProductID",productID);
   			NameValuePair nvp12= new NameValuePair("purchaseOnNoActiveSubscription",purchaseNoSub);
   			NameValuePair nvp13= new NameValuePair("transactionStatusCallbackUrl",statusUrl);
   			method.addRequestHeader("Content-Type","application/form-encoded; charset=UTF-8");
   		    method.setRequestBody(new NameValuePair[] {nvp1,nvp2,nvp3,nvp4,nvp5,nvp6,nvp7,nvp8,nvp9,nvp10,nvp11,nvp12,nvp13});
}

    int statusCode = client.executeMethod(method);   
    System.out.println(method.getResponseBodyAsString());
    if(statusCode==200) {
    	if (responseFormat.equalsIgnoreCase("json")) {
        	JSONObject rpcObject = new JSONObject(method.getResponseBodyAsString());
        	session.setAttribute("trxID", rpcObject.getString("trxID"));
        	response.sendRedirect(rpcObject.getString("redirectUrl"));
    	} else if (responseFormat.equalsIgnoreCase("xml")) {
       		DocumentBuilderFactory factoryForResponse = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factoryForResponse.newDocumentBuilder();
       	    Document xmlDoc = builder.parse(method.getResponseBodyAsStream());
      	    session.setAttribute("trxID",xmlDoc.getDocumentElement().getElementsByTagName("trxID").item(0).getTextContent());
      	    response.sendRedirect(xmlDoc.getDocumentElement().getElementsByTagName("redirectUrl").item(0).getTextContent());
    	}

    } else {
    	print = method.getResponseBodyAsString();
    }
    method.releaseConnection();
}
%> </td><td>&nbsp &nbsp &nbsp &nbsp </td><td>

<td>
<form name="getTransactionStatus" action="" method="get">
	Transaction ID <input type="text" name="trxID" value="<%=trxID%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="getTransactionStatus" value="Get Transaction Status" />
</form><br>

   <%  
       if(getTransactionStatus!=null) {
           String url ="https://beta-api.att.com/1/payments/transactions/" + trxID;   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken);
           method.addRequestHeader("Accept","application/" + responseFormat);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
         //  System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %>
   
<form name="commitTransaction" action="" method="post">
	Transaction ID <input type="text" name="trxID" value="<%=trxID%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="commitTransaction" value="Commit Transaction" />
</form><br>

   <%  
       if(commitTransaction!=null) {
           String url ="https://beta-api.att.com/1/payments/transactions/" + trxID;   
           HttpClient client = new HttpClient();
           PostMethod method = new PostMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&action=commit");
           method.addRequestHeader("Accept","application/" + responseFormat);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
        //   System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %>

<form name="refundTransaction" action="" method="post">
	Transaction ID <input type="text" name="trxID" value="<%=trxID%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="refundTransaction" value="Refund Transaction" />
</form>

<%  
if(refundTransaction!=null) {
    String url ="https://beta-api.att.com/1/payments/transactions/" + trxID;  
    HttpClient client = new HttpClient();
    PostMethod method = new PostMethod(url);  
    method.setQueryString("access_token=" + accessToken + "&action=refund");
    method.addRequestHeader("Content-Type","application/json");
    method.addRequestHeader("Accept","application/json");
    JSONObject bodyObject = new JSONObject();
    String reasonCode = "1";
    bodyObject.put("refundReasonCode",Double.parseDouble(reasonCode));
    bodyObject.put("refundReasonText","Subscriber unhappy.");
    method.setRequestBody(bodyObject.toString()); 
    int statusCode = client.executeMethod(method);   
   // System.out.println(method.getResponseBodyAsString());
    print = method.getResponseBodyAsString();
    method.releaseConnection();
}
%> 
</td></tr></table>
<br><br><html><body><%=print%></body></html>