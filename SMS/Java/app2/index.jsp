<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="org.apache.commons.httpclient.*"%>
<%@ page import="org.apache.commons.httpclient.methods.*"%>
<%@ page import="org.json.*"%>
<%@ page import="java.io.*" %>
<HTML>
<BODY>
<TABLE border=0 width="100%">
  <TBODY>
  <TR>
    <TD rowSpan=2 width="25%" align=left><IMG 
      src="http://developer.att.com/developer/images/att.gif"></TD></TR></TBODY></TABLE>
<HR size=px"></HR>
<font size=4px"><B>ATT sample SMS application 2</B></font><BR>
Feature 1 - Calculate votes sent via SMS to short code <b>22888926</b> with text "Football", "Baseball", or "Basketball".<BR>
      </BODY>
      
<%
String accessToken = request.getParameter("access_token");
if(accessToken==null || accessToken=="null"){
	accessToken = (String) session.getAttribute("accessToken");}
if(accessToken==null || accessToken=="null") {
	accessToken = "";
	session.setAttribute("postOauth", "index.jsp");
	response.sendRedirect("oauthSS.jsp?getAccessToken=yes");
}
String responseFormat = "json";
String getReceivedSms = request.getParameter("getReceivedSms");
String registrationID = request.getParameter("registrationID");
	if(registrationID==null || registrationID=="null"){
		registrationID = (String) session.getAttribute("registrationID");}
	if(registrationID==null || registrationID=="null"){
		registrationID = "22888926";}
int numberOfMessagesInBatch = 0;
JSONObject jsonResponse = new JSONObject();
JSONObject smsList = new JSONObject();
JSONArray messages = new JSONArray();
String invalidMessagePresent = (String) session.getAttribute("invalidMessagePresent");
	
	   String lineData1 = "";
	   RandomAccessFile inFile1 = new RandomAccessFile(application.getRealPath("/WEB-INF/tally1.txt"),"rw");
	   lineData1 = inFile1.readLine();
	   inFile1.close();
	   Integer totalTally1 = Integer.parseInt(lineData1);
	   
   	   String lineData2 = "";
	   RandomAccessFile inFile2 = new RandomAccessFile(application.getRealPath("/WEB-INF/tally2.txt"),"rw");
	   lineData2 = inFile2.readLine();
	   inFile2.close();
	   Integer totalTally2 = Integer.parseInt(lineData2);
	   
   	   String lineData3 = "";
	   RandomAccessFile inFile3 = new RandomAccessFile(application.getRealPath("/WEB-INF/tally3.txt"),"rw");
	   lineData3 = inFile3.readLine();
	   inFile3.close();
	   Integer totalTally3 = Integer.parseInt(lineData3);
%> <br>

   <%  
       if(getReceivedSms!=null) {
           String url ="https://beta-api.att.com/1/messages/inbox/sms";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&registrationID=" + registrationID);
           method.addRequestHeader("Accept","application/" + responseFormat);
           session.setAttribute("registrationID", registrationID);
           int statusCode = client.executeMethod(method); 
           
        if(statusCode==200) {
      		jsonResponse = new JSONObject(method.getResponseBodyAsString());
      		smsList = new JSONObject(jsonResponse.getString("inboundSMSMessageList"));
      		numberOfMessagesInBatch = Integer.parseInt(smsList.getString("numberOfMessagesInThisBatch"));
      		int numberOfMessagesInBatch1 = 0;
      		int numberOfMessagesInBatch2 = 0;
      		int numberOfMessagesInBatch3 = 0;
      		int numberOfMessagesPending = Integer.parseInt(smsList.getString("totalNumberOfPendingMessages"));
      		messages = new JSONArray(smsList.getString("inboundSMSMessage"));
      		if(numberOfMessagesInBatch!=0) {
				for(int i=0;i<numberOfMessagesInBatch; i++) {
					JSONObject msg = new JSONObject(messages.getString(i));
					String messageText = msg.getString("message");
					if(messageText.equalsIgnoreCase("football")) {
						numberOfMessagesInBatch1 += 1;
					} else if(messageText.equalsIgnoreCase("baseball")) {
						numberOfMessagesInBatch2 += 1;
					} else if(messageText.equalsIgnoreCase("basketball")) {
						numberOfMessagesInBatch3 += 1;
					} else {
						invalidMessagePresent = "yes";
						session.setAttribute("invalidMessagePresent", "yes");
					}
					
				}
      		}
           
    	   totalTally1 = totalTally1 + numberOfMessagesInBatch1;
    	   PrintWriter outWrite1 = new PrintWriter(new BufferedWriter(new FileWriter(application.getRealPath("/WEB-INF/tally1.txt"))), false);
   		   outWrite1.write(totalTally1.toString());
   		   outWrite1.close();
   		   
    	   totalTally2 = totalTally2 + numberOfMessagesInBatch2;
    	   PrintWriter outWrite2 = new PrintWriter(new BufferedWriter(new FileWriter(application.getRealPath("/WEB-INF/tally2.txt"))), false);
   		   outWrite2.write(totalTally2.toString());
   		   outWrite2.close();
   		   
    	   totalTally3 = totalTally3 + numberOfMessagesInBatch3;
    	   PrintWriter outWrite3 = new PrintWriter(new BufferedWriter(new FileWriter(application.getRealPath("/WEB-INF/tally3.txt"))), false);
   		   outWrite3.write(totalTally3.toString());
   		   outWrite3.close();

        }
        method.releaseConnection();
       }
              	%>
              	
		<TABLE border="1" bgcolor="#CCFF33">
   			<TR><TH>&nbsp; Favorite Sport &nbsp;</th><th>&nbsp; Total number of votes &nbsp;</TH></TR>
   			<TR><TD align="center">&nbsp; Football &nbsp;</td><td align="center"><%=totalTally1%></TD><TR>
   			<TR><TD align="center">&nbsp; Baseball &nbsp;</td><td align="center"><%=totalTally2%></TD><TR>
   			<TR><TD align="center">&nbsp; Basketball &nbsp;</td><td align="center"><%=totalTally3%></TD><TR>
		</TABLE>

<br>
<form name="getReceivedSms" action="" method="get">
	<input type="submit" name="getReceivedSms" value="Update vote total" />
</form><br><br>

<%
      		if((numberOfMessagesInBatch!=0) && (invalidMessagePresent!=null)) {
      			System.out.println("invalid is present");
				%><table border="1"  bgcolor="#FF0000">
				<tr><td align="center"><b>&nbsp; Invalid Vote Text &nbsp;</b></td><td align="center"><b>&nbsp; Sender Address &nbsp;</b></td><tr><%
				for(int i=0;i<numberOfMessagesInBatch; i++) {
					JSONObject msg = new JSONObject(messages.getString(i));
					String messageText = msg.getString("message");
					if((!messageText.equalsIgnoreCase("football")) && (!messageText.equalsIgnoreCase("baseball")) && (!messageText.equalsIgnoreCase("basketball"))) {
						System.out.println("message is not any sport");
						%>
    						<tr><td align="center"><%=msg.getString("message")%></td><td align="center"><%=msg.getString("senderAddress")%></td><tr>
					<%
					}
				}
				%>
				</tr></table>
			<%
      		}
%>
</html>