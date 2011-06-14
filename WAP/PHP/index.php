<?php
    $host="ssl://beta-api.att.com";//target host name
    $port="443";//port number
    //try to connect the socket  
    $fp = fsockopen($host, $port, $errno, $errstr, 1000); 
//checking the connection ,if it fails display the error 
    if (!$fp) { 
        echo "errno: $errno \n"; 
        echo "errstr: $errstr\n"; 
        return $result; 
    } 
    $boundary = "----------------------------".substr(md5(date("c")),0,10);
    $sendMMS_JSonData = '{"addresses" : "tel:+14252337701"}';
    $wappush_data = "<?xml version=\"1.0\" encoding =\"UTF-8\"?>\r\n"."<!DOCTYPE si PUBLIC \"-//WAPFORUM//DTD SI 1.0//EN\"\r\n"."\"http://www.wapforum.org/DTD/si.dtd\">\r\n";
    $wappush_data .= "<si>\r\n"."<indication href=\"http://wap.yahoo.com\" si-id=\"6532\" action=\"signal-medium\">WAP PUSH Message</indication>\r\n</si>";
    print("$wappush_data");
    
    //WAPPUSH data
    $data = "";
    $data .= "--$boundary\r\n";
    $data .= "MIME-Version: 1.0\r\n";
    $data .= "Content-type: application/json;\r\n\r\n".$sendMMS_JSonData."\r\n"; 
    $data .= "--$boundary\r\n";
    $data .= "MIME-Version: 1.0\r\n";
    $data .= "Content-Type: application/octet-stream\r\n";
    $data .= "ContentType: text/vnd.wap.si\r\n\r\n";
    $data .= $wappush_data."\r\n"; 
    $data .= "--$boundary--\r\n"; 
    //http header values
    $header = "POST https://beta-api.att.com/1/messages/outbox/wapPush?access_token=3cc817c3aed599496773e4c4f7866fd HTTP/1.1\r\n";
    $header .= "Host: beta-api.att.com\r\n";
    $header .= "Content-type: multipart/mixed;"." boundary=\"$boundary\"\r\n";
    $header .= "MIME-Version: 1.0\r\n";
    $dc = strlen($data); //content length
    //$header .= "Content-length: $dc\r\n\r\n";
 
    $httpRequest = $header.$data;
    fputs($fp, $httpRequest);
    print("HTTP : $httpRequest");
    //read the response from file and store it.
    $res="";
    while(!feof($fp)) { 
        $res .= fread($fp,1); 
    } 
    fclose($fp); //close the socket
    print ("Response=$res");//display the response
    ?>