import com.sun.jersey.multipart.file.*;
import com.sun.jersey.multipart.BodyPart;
import com.sun.jersey.multipart.MultiPart;
import java.io.*;
import java.util.List;
import com.sentaca.rest.client.*;
import java.net.*;
import javax.ws.rs.core.*;
import org.apache.commons.fileupload.*;
import java.util.List;
import java.util.Iterator;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.*;
import org.json.*;
import org.w3c.dom.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.dom.*;

public class MMS2 {

	  public static void main(String args[]) {
		  
		  try {
			  
			  while(true) {
				  String FQDN = "https://beta-api.att.com";
				  String clientId = "b4c586cf4472beb50e1e091761a1e389";
				  String clientSecret = "50e0c203f8454da7";
				  String accessToken = "";

				             String url = FQDN + "/oauth/access_token";   
				             org.apache.commons.httpclient.HttpClient client1 = new org.apache.commons.httpclient.HttpClient();
				             org.apache.commons.httpclient.methods.GetMethod method = new org.apache.commons.httpclient.methods.GetMethod(url);   
				             method.setQueryString("grant_type=client_credentials&client_id=" + clientId + "&client_secret=" + clientSecret);
				             System.out.println("okay0");
				             int statusCode = client1.executeMethod(method);    
				             String print = method.getResponseBodyAsString();
				             System.out.println("okay0.5");
				             if(statusCode==200){ 
				          	   accessToken = print.substring(18,50);
				             }
				             method.releaseConnection();
				             System.out.println("access token is " + accessToken);
String priority = "High";
String responseFormat = "json";
String requestFormat = "json";
String endpoint = FQDN + "/1/messages/outbox/mms";	
		
		String attachment = "coupon.jpg";

		MediaType contentBodyType = null;
		String requestBody = "";
		contentBodyType = MediaType.MULTIPART_FORM_DATA_TYPE;

   		FileDataBodyPart fIlE = new FileDataBodyPart();
   		MediaType medTyp = fIlE.getPredictor().getMediaTypeFromFileName("/" + attachment);

		// This currently uses a proprietary rest client to assemble the request body that does not follow SMIL standards. It is recommended to follow SMIL standards to ensure attachment delivery.
		RestClient client = new RestClient(endpoint, contentBodyType, MediaType.APPLICATION_JSON_TYPE);
		client.addParameter("access_token", accessToken);
		
		   RandomAccessFile inFile1 = new RandomAccessFile(System.getProperty("user.dir") + "/WEB-INF/msg.txt","rw");
		   String subject = inFile1.readLine();
		   inFile1.close();
		
		   String responze ="";
		   
			   RandomAccessFile inFile2 = new RandomAccessFile(System.getProperty("user.dir") + "/WEB-INF/phones.txt","rw");
			   String address = inFile2.readLine();
		   while(address!=null) {		   
			System.out.println("Sending coupon to " + address);
			JSONObject requestObject = new JSONObject();
		 	requestObject.put("priority", priority);
		    requestObject.put("address", "tel:" + address);
			requestObject.put("subject", subject);
			requestObject.put("content-type", "image/jpeg");
		 	requestBody += requestObject.toString();
		 	MultiPart mPart = new MultiPart().bodyPart(new BodyPart(requestBody,MediaType.APPLICATION_JSON_TYPE));
		 	mPart.bodyPart(new BodyPart(new File(System.getProperty("user.dir") + "/WEB-INF/" + attachment), medTyp));
		 	
		 	mPart.getBodyParts().get(0).getHeaders().add("Content-Transfer-Encoding", "8bit");
	 		mPart.getBodyParts().get(0).getHeaders().add("Content-Disposition","form-data; name=\"root-fields\"");
	 		mPart.getBodyParts().get(0).getHeaders().add("Content-ID", "<startpart>");
			client.addRequestBody(mPart);
			System.out.println("okay1");
			responze = client.invoke(com.sentaca.rest.client.HttpMethod.POST, true);
			System.out.println("okay2");
			System.out.println(responze);
			System.out.println("");
		
		if (client.getHttpResponseCode() == 201) {
			JSONObject rpcObject = new JSONObject(responze);
			String mmsId = rpcObject.getString("id");

		   } else {

		}
		address = inFile2.readLine();

	}
		   inFile2.close();
Thread.sleep(15*1000);
			  }
		  } catch (Throwable t) {
			  System.out.println(t);
		  }
		}
	}