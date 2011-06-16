<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML lang=en xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"><HEAD><TITLE>Application 1</TITLE>
<META content="text/html; charset=windows-1252" http-equiv=Content-Type>
<SCRIPT type=text/javascript 
src="http://www.dwestern.com/smsapp/smshelper.js">
</SCRIPT>
<META name=GENERATOR content="MSHTML 8.00.6001.19046"></HEAD>
<BODY>
<TABLE border=0 width="100%">
  <TBODY>
  <TR>
    <TD rowSpan=2 width="25%" align=left><IMG 
      src="http://developer.att.com/developer/images/att.gif"></TD>
    <TD width="15%" align=right>Server Time:</TD>
    <TD width="60%" align=left>Monday, June 13, 2011 16:52 CDT</TD></TR>
  <TR>
    <TD width="15%" align=right>Client Time:</TD>
    <TD width="25%" align=left>
      <SCRIPT language=JavaScript type=text/javascript>
<!--
var myDate = new Date();
document.write(myDate.format('l, F d, Y  H:i') + ' PDT');

//-->
</SCRIPT>
</TD></TR></TBODY></TABLE>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="org.apache.commons.httpclient.*"%>
<%@ page import="org.apache.commons.httpclient.methods.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
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
		session.setAttribute("redirectUri", "http://apigee.dyndns.org:8080/apigee-public/oauth.jsp");
		response.sendRedirect("oauth.jsp?getExtCode=yes");
	}
	String address = request.getParameter("address");
	String message = request.getParameter("message");
	String smsId = request.getParameter("smsId");
	if (smsId==null) smsId = (String) session.getAttribute("smsId");
	if (smsId==null) smsId = "";
	String getSmsDeliveryStatus = request.getParameter("getSmsDeliveryStatus");
	String sendSms = request.getParameter("sendSms");
	String getReceivedSms = request.getParameter("getReceivedSms");
	String registrationID = request.getParameter("registrationID");
	if(registrationID==null || registrationID=="null"){
		registrationID = (String) session.getAttribute("registrationID");}
	if(registrationID==null || registrationID=="null"){
		registrationID = "";}
	String print = "";
%>
    
<HR size=px"></HR>
<font size=4px"><B>ATT sample SMS application</B></font><BR>
Feature 1 - sending SMS message.<BR>
<FORM  method="post" name="sendSms" >
<TABLE border=0 width="60%">
  <TBODY>
  <TR>
    <TD width="10%">Message:</TD>
    <TD><TEXTAREA rows=4 name="message">simple message to myself</TEXTAREA>
	</TD></TR>
  <TR>
    <TD width="10%">Phone:</TD>
    <TD><input maxLength=12 size=12 name="address" value="425-241-8899"></input>
    </TD>
  </TR>
  <TR>
    <TD width="10%">&nbsp;</TD>
    <TD>DDD-DDD-DDDD</TD></TR></TBODY></TABLE>
<BUTTON type="submit" name="sendSms">send sms message</BUTTON>
</FORM>
<%

if(sendSms!=null) {
	address = "tel:" + address.substring(0,3) + address.substring(4,7) + address.substring(8,12);
	System.out.println("address is: " + address);
    String url ="https://test-api.att.com/1/messages/outbox/sms";   
    HttpClient client = new HttpClient();
    PostMethod method = new PostMethod(url);
    JSONObject rpcObject = new JSONObject();
	rpcObject.put("message", message);
	rpcObject.put("address", address);
	method.setRequestBody(rpcObject.toString());
	method.addRequestHeader("Content-Type","application/json; charset=UTF-8");
	method.setQueryString("access_token=" + accessToken);
    method.addRequestHeader("Accept","application/json");
    int statusCode = client.executeMethod(method);
    System.out.println(method.getResponseBodyAsString());
    if(statusCode==201) {
       	JSONObject jsonResponse = new JSONObject(method.getResponseBodyAsString());
       	smsId = jsonResponse.getString("id");
       	session.setAttribute("smsId",smsId);
       	%>
       	<table border="1" bgcolor="#CCFF33" >
  		<tr><th>message id</th></tr>
  		<tr><td><%=smsId%></td></tr>
		</table>
		<%
    } else {
    	%>
       	<table border="1" bgcolor="#FF0000" >
  		<tr><th>Error</th></tr>
  		<tr><td><%=method.getResponseBodyAsString()%></td></tr>
		</table>
		<%
    }
    method.releaseConnection();
}
%>

<HR></HR>
Feature 2 - obtaining status on previously sent message.
<FORM method="post" name="getSmsDeliveryStatus">
    <TD>Message ID:</TD>
    <TD><input type="text" name="smsId" value="<%=smsId%>"></input></TD>
    <TD><BUTTON type="submit" name="getSmsDeliveryStatus">get status</BUTTON></TD>
</FORM>

   <%  
       if(getSmsDeliveryStatus!=null) {
           String url ="https://test-api.att.com/1/messages/outbox/sms/" + smsId;   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&id=" + smsId);
           method.addRequestHeader("Accept","application/json");
           int statusCode = client.executeMethod(method); 
           System.out.println(method.getResponseBodyAsString());
           if(statusCode==200) {
              	JSONObject jsonResponse = new JSONObject(method.getResponseBodyAsString());
              	JSONObject deliveryInfoList = new JSONObject(jsonResponse.getString("deliveryInfoList"));
              	JSONArray deliveryInfoArray = new JSONArray(deliveryInfoList.getString("deliveryInfo"));
              	JSONObject deliveryInfo = new JSONObject(deliveryInfoArray.getString(0));
              	%>
				<TABLE border="1" bgcolor="#CCFF33">
   					<TR><TH>Status</th><th>Resource URL</TH></TR>
   					<TR><TD><%=deliveryInfo.getString("delivery-status")%></td><td><%=deliveryInfoList.getString("resourceURL")%></TD><TR>
				</TABLE>
       		<%
           } else {
           	%>
              	<table border="1" bgcolor="#FF0000" >
         		<tr><th>Error</th></tr>
         		<tr><td><%=method.getResponseBodyAsString()%></td></tr>
       		</table>
       		<%
           }
           System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %> 
   
<HR></HR>
Feature 3 - checking number messages sent to a short code.
<FORM method="post" name="getReceivedSms">
<TABLE>
  <TR>
    <TD>ShortCode:</TD>
    <TD><input type="text" name="registrationID" value="22888955"></input></TD>
    <TD><BUTTON type="submit" name="getReceivedSms" >get messages for shortcode</BUTTON></TD>
  </TR>
</TABLE>
</FORM>
  
   <%  
       if(getReceivedSms!=null) {
           String url ="https://test-api.att.com/1/messages/inbox/sms";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&registrationID=" + registrationID);
           method.addRequestHeader("Accept","application/json");
           session.setAttribute("registrationID", registrationID);
           int statusCode = client.executeMethod(method);
           System.out.println(method.getResponseBodyAsString());
           if(statusCode==200) {
              		JSONObject jsonResponse = new JSONObject(method.getResponseBodyAsString());
              		JSONObject smsList = new JSONObject(jsonResponse.getString("inboundSMSMessageList"));
              		int numberOfMessagesInBatch = Integer.parseInt(smsList.getString("numberOfMessagesInThisBatch"));
              		int numberOfMessagesPending = Integer.parseInt(smsList.getString("totalNumberOfPendingMessages"));
              		JSONArray messages = new JSONArray(smsList.getString("inboundSMSMessage"));
              		if(numberOfMessagesInBatch!=0) {
              		%>
						<table border="1"  bgcolor="#CCFF33">
    						<tr><td><b>Message Index</b></td><td><b>Message Text</b></td><td><b>Sender Address</b></td><tr>
							<%for(int i=0;i<numberOfMessagesInBatch; i++) {
							JSONObject msg = new JSONObject(messages.getString(i));%>
    						<tr><td align="center"><%=msg.getString("messageId")%></td><td align="center"><%=msg.getString("message")%></td><td><%=msg.getString("senderAddress")%></td><tr>
							<%}%>
    						<tr><td></td><td><b>Number of messages in this batch:</b></td><td align="center"><%=numberOfMessagesInBatch%></td><tr>
    						<tr><td></td><td><b>Number of remaining pending messages:</b></td><td align="center"><%=numberOfMessagesPending%></td><tr>
						</table>
              		<%
              		} else {
                       	%>
                      	<table border="1" bgcolor="#FF0000" >
                 		<tr><th>Error</th></tr>
                 		<tr><td>No messages.</td></tr>
               		</table>
               		<%
                   }

              } else {
                 	%>
                  	<table border="1" bgcolor="#FF0000" >
             		<tr><th>Error</th></tr>
             		<tr><td><%=method.getResponseBodyAsString()%></td></tr>
           		</table>
           		<%
               }
           method.releaseConnection();
       }
   %>