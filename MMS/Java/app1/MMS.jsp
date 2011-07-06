<%@ page language="java" errorPage="" %>
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
String getMmsDeliveryStatus = request.getParameter("getMmsDeliveryStatus");
String mmsId = request.getParameter("mmsId");
if (mmsId==null) mmsId = (String) session.getAttribute("mmsId");
if (mmsId==null) mmsId = "";
String accessToken = request.getParameter("access_token");
if(accessToken==null || accessToken=="null"){
	accessToken = (String) session.getAttribute("accessToken");}
if(accessToken==null || accessToken=="null") {
	accessToken = "";
	session.setAttribute("postOauth", "MMS.jsp");
	%><a href="oauth.jsp">Authenticate first</a><br><br><%
}
String sendMms = request.getParameter("sendMms");
String endpoint = "https://beta-api.att.com/1/messages/outbox/mms";		
String contentBodyFormat = "FORM-ENCODED";		
String address = "";		
String fileName = "";		
String subject = "";		
String priority = "";
String responseFormat = "";
String print = "";
String requestFormat = "";
%>

<form name="sendMms" action="MMS.jsp?sendMms=true" enctype="multipart/form-data" method="post">
	Access Token <input type="text" name="accessToken" value="<%=accessToken%>" size=40/><br>
	MSISDN <input type="text" name="address" value="tel:" /><br />
	Subject <input type="text" name="subject" value="Test." size=40/><br />
	Priority <input type="text" name="priority" value="High" size=40/><br />
	Request Format: <input type="radio" name="requestFormat" value="xml">XML<input type="radio" name="requestFormat" value="json" checked>JSON<input type="radio" name="requestFormat" value="form-encoded">Form-encoded<br/>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	Attachment <input type="file" name="f1" /><br>
	<input type="submit" name="sendMms" value="Send MMS"/>
</form><br><br>

<% if(request.getParameter("sendMms")!=null) {	

        DiskFileUpload fu = new DiskFileUpload();
        List fileItems = fu.parseRequest(request);
        Iterator itr = fileItems.iterator();
        while(itr.hasNext()) {
          FileItem fi = (FileItem)itr.next();
          if(!fi.isFormField()) {
            	File fNew= new File(application.getRealPath("/"), fi.getName());
            	fileName = "/" + fi.getName();
            	fi.write(fNew);
          } else if(fi.getFieldName().equalsIgnoreCase("address")) {
            	address = fi.getString();
          } else if(fi.getFieldName().equalsIgnoreCase("subject")) {
          	subject = fi.getString();
          } else if(fi.getFieldName().equalsIgnoreCase("priority")) {
          	priority = fi.getString();
          } else if(fi.getFieldName().equalsIgnoreCase("responseFormat")) {
          	responseFormat = fi.getString();
          } else if(fi.getFieldName().equalsIgnoreCase("accessToken")) {
          	accessToken = fi.getString();
          	session.setAttribute("accessToken", accessToken);
          } else if(fi.getFieldName().equalsIgnoreCase("requestFormat")) {
        	requestFormat = fi.getString();
          }
        }		
		String attachmentsStr = fileName;
		String[] attachments = attachmentsStr.split(",");

		FileDataBodyPart fIlE = new FileDataBodyPart();
		MediaType medTyp = fIlE.getPredictor().getMediaTypeFromFileName(fileName);
		
		ServletContext context = getServletContext();
   		InputStream is = context.getResourceAsStream(attachments[0]);
		
		MediaType contentBodyType = null;
		String requestBody = "";
		MultiPart mPart;
		if (requestFormat.equalsIgnoreCase("form-encoded"))
		{
			contentBodyType = MediaType.MULTIPART_FORM_DATA_TYPE;
			requestBody += "address=" + URLEncoder.encode(address, "UTF-8") + "&";	
			requestBody += "priority=" + URLEncoder.encode(priority, "UTF-8") + "&";
			requestBody += "subject=" + URLEncoder.encode(subject, "UTF-8") + "&";
			requestBody += "content-type=" + URLEncoder.encode(medTyp.toString(), "UTF-8") + "\r\n";
			mPart = new MultiPart().bodyPart(new BodyPart(requestBody,MediaType.APPLICATION_FORM_URLENCODED_TYPE)).bodyPart(new BodyPart(is, medTyp));
		} else if(requestFormat.equalsIgnoreCase("json")) {
			contentBodyType = MediaType.MULTIPART_FORM_DATA_TYPE;
			JSONObject requestObject = new JSONObject();
   		 	requestObject.put("priority", priority);
   		    requestObject.put("address", address);
   			requestObject.put("subject", subject);
   			requestObject.put("content-type", medTyp.toString());
   		 	requestBody += requestObject.toString();
   			mPart = new MultiPart().bodyPart(new BodyPart(requestBody,MediaType.APPLICATION_JSON_TYPE)).bodyPart(new BodyPart(is, medTyp));
		} else {
			 contentBodyType = MediaType.MULTIPART_FORM_DATA_TYPE;
	         DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	         DocumentBuilder builder = factory.newDocumentBuilder();
	         DOMImplementation impl = builder.getDOMImplementation();
	         Document doc = impl.createDocument(null,null,null);
	         Element e1 = doc.createElement("mms-request");
	         doc.appendChild(e1);
	         Element e2 = doc.createElement("address");
	         e1.appendChild(e2);
	         e2.setTextContent(address);
	         Element e3 = doc.createElement("subject");
	         e1.appendChild(e3);
	         e3.setTextContent(subject);
	         Element e4 = doc.createElement("priority");
	         e1.appendChild(e4);
	         e4.setTextContent(priority);
	         Element e5 = doc.createElement("content-type");
	         e1.appendChild(e5);
	         e5.setTextContent(medTyp.toString());
	         // transform the Document into a String
	         DOMSource domSource = new DOMSource(doc);
	         TransformerFactory tf = TransformerFactory.newInstance();
	         Transformer transformer = tf.newTransformer();
	         transformer.setOutputProperty(OutputKeys.METHOD, "xml");
	         transformer.setOutputProperty(OutputKeys.ENCODING,"UTF-8");
	         transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
	         transformer.setOutputProperty(OutputKeys.STANDALONE,"yes");
	         transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	         transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
	         java.io.StringWriter sw = new java.io.StringWriter();
	         StreamResult sr = new StreamResult(sw);
	         transformer.transform(domSource, sr);
	         String xml = sw.toString();
	         requestBody += xml;
	   		 mPart = new MultiPart().bodyPart(new BodyPart(requestBody,MediaType.TEXT_XML_TYPE)).bodyPart(new BodyPart(is, medTyp));
		}
		
		mPart.getBodyParts().get(1).getHeaders().add("Content-Transfer-Encoding", "binary");
		mPart.getBodyParts().get(1).getHeaders().add("Content-Disposition","attachment; name=\"\"; filename=\"\"");
		mPart.getBodyParts().get(0).getHeaders().add("Content-Transfer-Encoding", "8bit");
		mPart.getBodyParts().get(0).getHeaders().add("Content-Disposition","form-data; name=\"root-fields\"");
		mPart.getBodyParts().get(0).getHeaders().add("Content-ID", "<startpart>");
		mPart.getBodyParts().get(1).getHeaders().add("Content-ID", "<attachment>");
		// This currently uses a proprietary rest client to assemble the request body that does not follow SMIL standards. It is recommended to follow SMIL standards to ensure attachment delivery.
		RestClient client;
		if(responseFormat.equalsIgnoreCase("json")){
			client = new RestClient(endpoint, contentBodyType, MediaType.APPLICATION_JSON_TYPE);
		} else {
			client = new RestClient(endpoint, contentBodyType, MediaType.APPLICATION_XML_TYPE);
		}
		client.addParameter("access_token", accessToken);
		client.addRequestBody(mPart);
		String responze = client.invoke(com.sentaca.rest.client.HttpMethod.POST, true);
		
		if ((client.getHttpResponseCode() == 201) & (responseFormat.equalsIgnoreCase("json"))) {
			print = responze;
			JSONObject rpcObject = new JSONObject(responze);
			mmsId = rpcObject.getString("id");
			session.setAttribute("mmsId", mmsId);
		} else if ((client.getHttpResponseCode() == 201) & (responseFormat.equalsIgnoreCase("xml"))){
			print = responze;
       		DocumentBuilderFactory factoryForResponse = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factoryForResponse.newDocumentBuilder();
       	    Document xmlDoc = builder.parse(new ByteArrayInputStream(responze.getBytes()));
       	    mmsId = xmlDoc.getDocumentElement().getAttribute("id");
      	    session.setAttribute("mmsId",mmsId);
		} else {
			print = responze;
			System.out.println(print);
		}
	}	
%>

<form name="getMmsDeliveryStatus" action="" method="get">
	Request Identifier <input type="text" name="id" value="<%=mmsId%>" size=40/><br />
	Access Token <input type="text" name="access_token" value="<%=accessToken%>" size=40/><br>
	Response Format: <input type="radio" name="responseFormat" value="xml">XML<input type="radio" name="responseFormat" value="json" checked>JSON<br/>
	<input type="submit" name="getMmsDeliveryStatus" value="Get MMS Delivery Status" />
</form>

   <%  
       if(getMmsDeliveryStatus!=null) {
           String url ="https://beta-api.att.com/1/messages/outbox/mms/" + mmsId;   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&id=" + mmsId);
           method.addRequestHeader("Accept","application/" + responseFormat);
           int statusCode = client.executeMethod(method);    
           print = method.getResponseBodyAsString();
           System.out.println(method.getResponseBodyAsString());
           method.releaseConnection();
       }
   %> 
<br><br><html><body><%=print%></body></html>