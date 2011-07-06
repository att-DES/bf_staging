<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML lang=en xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"><HEAD><TITLE>Application 2</TITLE>
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
<%@ page import="com.sun.jersey.multipart.file.*" %>
<%@ page import="com.sun.jersey.multipart.BodyPart" %>
<%@ page import="com.sun.jersey.multipart.MultiPart" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sentaca.rest.client.*" %>
<%@ page import="java.net.*" %>
<%@ page import="javax.ws.rs.core.*" %>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="java.util.List,java.util.Iterator"%>
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
	session.setAttribute("postOauth", "MMS2.jsp");
	session.setAttribute("redirectUri", "http://198.171.172.186:8080/apigee-public/oauth.jsp");
	session.setAttribute("clientId", "861e5197f51c002bb6fa9c44cc6360c3");
	session.setAttribute("clientSecret", "bb4d6838d7c65326");
	session.setAttribute("FQDN", "https://test-api.att.com");
	response.sendRedirect("oauth.jsp?getExtCode=yes");
}
String sendMms = request.getParameter("sendMms");		
String contentBodyFormat = "FORM-ENCODED";		
String priority = "High";
String responseFormat = "json";
String requestFormat = "json";
String FQDN = request.getParameter("FQDN");
if (FQDN==null) 
	FQDN = (String) session.getAttribute("FQDN");
if (FQDN==null)
	FQDN = "https://test-api.att.com";
String endpoint = FQDN + "/1/messages/outbox/mms";
%>

<HR size=px"></HR>
<font size=4px"><B>ATT sample MMS application</B></font><BR>
Feature 1 - sending MMS message.<BR>
<FORM  method="post" name="sendMms">
<TABLE border=0 width="60%">
  <TBODY>

  </TBODY></TABLE>
<BUTTON type="submit" name="sendMms">send mms message</BUTTON>
</FORM>

<% if(request.getParameter("sendMms")!=null) {	
		
		String attachment = "coupon.jpg";

		MediaType contentBodyType = null;
		String requestBody = "";
		contentBodyType = MediaType.MULTIPART_FORM_DATA_TYPE;

   		FileDataBodyPart fIlE = new FileDataBodyPart();
   		MediaType medTyp = fIlE.getPredictor().getMediaTypeFromFileName("/" + attachment);

   		 
   		ServletContext context = getServletContext();


		// This currently uses a proprietary rest client to assemble the request body that does not follow SMIL standards. It is recommended to follow SMIL standards to ensure attachment delivery.
		RestClient client = new RestClient(endpoint, contentBodyType, MediaType.APPLICATION_JSON_TYPE);
		client.addParameter("access_token", accessToken);
		
		   RandomAccessFile inFile1 = new RandomAccessFile(application.getRealPath("/WEB-INF/msg.txt"),"rw");
		   String subject = inFile1.readLine();
		   inFile1.close();
		
		   String responze ="";
     		%>
			<table border="1"  bgcolor="#CCFF33">
				<tr><td><b>Message ID</b></td><td><b>Address</b></td><tr>
			<%
		   
			   RandomAccessFile inFile2 = new RandomAccessFile(application.getRealPath("/WEB-INF/phones.txt"),"rw");
			   String address = inFile2.readLine();
		   while(address!=null) {		   
			JSONObject requestObject = new JSONObject();
		 	requestObject.put("priority", priority);
		    requestObject.put("address", "tel:" + address);
			requestObject.put("subject", subject);
			requestObject.put("content-type", "image/jpeg");
		 	requestBody += requestObject.toString();
			MultiPart mPart = new MultiPart().bodyPart(new BodyPart(requestBody,MediaType.APPLICATION_JSON_TYPE));
			mPart.bodyPart(new BodyPart(context.getResourceAsStream("/WEB-INF/" + attachment), medTyp));
		 	
		 	mPart.getBodyParts().get(0).getHeaders().add("Content-Transfer-Encoding", "8bit");
	 		mPart.getBodyParts().get(0).getHeaders().add("Content-Disposition","form-data; name=\"root-fields\"");
	 		mPart.getBodyParts().get(0).getHeaders().add("Content-ID", "<startpart>");
		
			client.addRequestBody(mPart);
			responze = client.invoke(com.sentaca.rest.client.HttpMethod.POST, true);
			System.out.println(responze);
		
		if (client.getHttpResponseCode() == 201) {
			JSONObject rpcObject = new JSONObject(responze);
			String mmsId = rpcObject.getString("id");
      		%>
				<tr><td align="center"><%=mmsId%></td><td><%=address%></td><tr>
  		<%
		   } else {
	    %>
	  		<tr><td bgcolor="#FF0000" ><%=responze%></td></tr>
			<%
		}
		address = inFile2.readLine();

	}
		   inFile2.close();
			%>
			</table>
			<%
}
%>