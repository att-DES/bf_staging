import java.awt.Toolkit;
import java.util.Timer;
import java.util.TimerTask;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.*;
import org.json.*;
import java.io.*;

public class SMS2 {

  public static void main(String args[]) {
	  
	  try {
		  
		  while(true) {
String clientId = "b4c586cf4472beb50e1e091761a1e389";
String clientSecret = "50e0c203f8454da7";
String accessToken = "";

           String url ="https://beta-api.att.com/oauth/access_token";   
           HttpClient client = new HttpClient();
           GetMethod method = new GetMethod(url);   
           method.setQueryString("grant_type=client_credentials&client_id=" + clientId + "&client_secret=" + clientSecret);
           int statusCode = client.executeMethod(method);    
           String print = method.getResponseBodyAsString();
           if(statusCode==200){ 
        	   accessToken = print.substring(18,50);
           }
           method.releaseConnection();

String responseFormat = "json";
String registrationID = "22888926";
int numberOfMessagesInBatch = 0;
JSONObject jsonResponse = new JSONObject();
JSONObject smsList = new JSONObject();
JSONArray messages = new JSONArray();
String invalidMessagePresent = "";
	
	   String lineData1 = "";
	   RandomAccessFile inFile1 = new RandomAccessFile(System.getProperty("user.dir") + "/WEB-INF/tally1.txt","rw");
	   lineData1 = inFile1.readLine();
	   inFile1.close();
	   Integer totalTally1 = Integer.parseInt(lineData1);
	   
   	   String lineData2 = "";
	   RandomAccessFile inFile2 = new RandomAccessFile(System.getProperty("user.dir") + "/WEB-INF/tally2.txt","rw");
	   lineData2 = inFile2.readLine();
	   inFile2.close();
	   Integer totalTally2 = Integer.parseInt(lineData2);
	   
   	   String lineData3 = "";
	   RandomAccessFile inFile3 = new RandomAccessFile(System.getProperty("user.dir") + "/WEB-INF/tally3.txt","rw");
	   lineData3 = inFile3.readLine();
	   inFile3.close();
	   Integer totalTally3 = Integer.parseInt(lineData3);
 
           url ="https://beta-api.att.com/1/messages/inbox/sms";   
           client = new HttpClient();
           method = new GetMethod(url);  
           method.setQueryString("access_token=" + accessToken + "&registrationID=" + registrationID);
           method.addRequestHeader("Accept","application/" + responseFormat);
           statusCode = client.executeMethod(method); 
           
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
					}
					
				}
      		}
           
    	   totalTally1 = totalTally1 + numberOfMessagesInBatch1;
    	   PrintWriter outWrite1 = new PrintWriter(new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/WEB-INF/tally1.txt")), false);
   		   outWrite1.write(totalTally1.toString());
   		   outWrite1.close();
   		   System.out.println("Tally A is " + totalTally1);
   		   
    	   totalTally2 = totalTally2 + numberOfMessagesInBatch2;
    	   PrintWriter outWrite2 = new PrintWriter(new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/WEB-INF/tally2.txt")), false);
   		   outWrite2.write(totalTally2.toString());
   		   outWrite2.close();
   		   System.out.println("Tally B is " + totalTally2);
   		   
    	   totalTally3 = totalTally3 + numberOfMessagesInBatch3;
    	   PrintWriter outWrite3 = new PrintWriter(new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/WEB-INF/tally3.txt")), false);
   		   outWrite3.write(totalTally3.toString());
   		   outWrite3.close();
   		   System.out.println("Tally C is " + totalTally3);
   		   System.out.println("");

        } else {
        	System.out.println(method.getResponseBodyAsString());
        	System.out.println("");
        }
        method.releaseConnection();
        Thread.sleep(15*1000);
		  }
	  } catch (Throwable t) {
		  System.out.println(t);
	  }
	}
}