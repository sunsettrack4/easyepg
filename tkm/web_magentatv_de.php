<?php
    $agent = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0';
    $dir_path = dirname(__FILE__);
	$type = $_GET['type'];
				
	$url = "https://api.prod.sngtv.magentatv.de/EPG/JSON/Login?&T=PC_firefox_75";
	$data = '{"userId":"Guest","mac":"00:00:00:00:00:00"}';
	$ch = curl_init ($url);
	curl_setopt ($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
	curl_setopt ($ch, CURLOPT_POST, 1);
	curl_setopt ($ch, CURLOPT_POSTFIELDS, $data);
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded; charset=UTF-8'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Language: de,en-US;q=0.7,en;q=0.3'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Encoding: gzip, deflate, br'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Connection: keep-alive'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Upgrade-Insecure-Requests: 1'));
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt ($ch, CURLOPT_USERAGENT, $agent);
	curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt ($ch, CURLOPT_COOKIEJAR, $dir_path . '/web.magentatv.de.cookies.txt');
    curl_setopt ($ch, CURLOPT_COOKIEFILE, $dir_path . '/web.magentatv.de.cookies.txt');
	$output = curl_exec ($ch);
	curl_close($ch);
				
    $path = $dir_path . '/web.magentatv.de.cookies.txt';
    $fileContent = file_get_contents($path);
    $pattern = '/[A-Za-z0-9]{48}/';
    preg_match($pattern,$fileContent,$match);
    $xcsrf1 = $match[0];
				
	$url1 = "https://api.prod.sngtv.magentatv.de/EPG/JSON/Authenticate?SID=firstup&T=PC_firefox_75";
	$data1 = '{"terminalid": "00:00:00:00:00:00", "mac": "00:00:00:00:00:00", "terminaltype": "WEBTV","utcEnable": "1", "timezone": "UTC", "userType": "3", "terminalvendor": "Unknown","preSharedKeyID": "PC01P00002", "cnonce": "5c6ff0b9e4e5efb1498e7eaa8f54d9fb"}';
	$ch = curl_init ($url1);
	curl_setopt ($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
	curl_setopt ($ch, CURLOPT_POSTFIELDS, $data1);
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('X_CSRFToken: ' . $xcsrf1));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded; charset=UTF-8'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Language: de,en-US;q=0.7,en;q=0.3'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Encoding: gzip, deflate, br'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Connection: keep-alive'));
	curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Upgrade-Insecure-Requests: 1'));
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt ($ch, CURLOPT_USERAGENT, $agent);
	curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt ($ch, CURLOPT_COOKIEFILE, $dir_path . '/web.magentatv.de.cookies.txt');
	curl_setopt ($ch, CURLOPT_COOKIEJAR, $dir_path . '/web.magentatv.de.cookies.txt');
	$output1 = curl_exec ($ch);
	curl_close($ch);
				
	$path = $dir_path . '/web.magentatv.de.cookies.txt';
    $fileContent = file_get_contents($path);
    $pattern = '/[A-Za-z0-9]{48}/';
    preg_match($pattern,$fileContent,$match);
    $xcsrf = $match[0];
       
		
	if($type == '1') {
        $start = $_GET['date'];
        $time = $_GET['time'];
        $stop = date("Ymd", strtotime("$start +$time days"));
        $channel = $_GET['channel'];
        $data2 = '{"channelid":"' . $channel . '","type":2,"offset":0,"count":-1,"isFillProgram":1,"properties":[{"name":"playbill","include":"ratingForeignsn,id,channelid,name,subName,starttime,endtime,cast,casts,country,producedate,ratingid,pictures,type,introduce,foreignsn,seriesID,genres,subNum,seasonNum"}],"endtime":"' . $stop . '235959","begintime":"' . $start . '000000"}';
        $url2 = "https://api.prod.sngtv.magentatv.de/EPG/JSON/PlayBillList?userContentFilter=241221015&sessionArea=1&SID=ottall&T=PC_firefox_75";
        $ch = curl_init ($url2);
        curl_setopt ($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt ($ch, CURLOPT_POST, 1);
        curl_setopt ($ch, CURLOPT_POSTFIELDS, $data2);
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded; charset=UTF-8'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Language: de,en-US;q=0.7,en;q=0.3'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Encoding: gzip, deflate, br'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Connection: keep-alive'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Upgrade-Insecure-Requests: 1'));
        curl_setopt ($ch, CURLOPT_HTTPHEADER, array('X_CSRFToken: ' . $xcsrf));
        curl_setopt ($ch, CURLOPT_USERAGENT, $agent);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt ($ch, CURLOPT_COOKIEFILE, $dir_path . '/web.magentatv.de.cookies.txt');
        $output2 = curl_exec($ch);
        curl_close($ch);
        echo $output2;

	} elseif($type == '2') {
        $data3 = '{"properties": [{"name": "logicalChannel","include": "/channellist/logicalChannel/contentId,/channellist/logicalChannel/name,/channellist/logicalChannel/pictures/picture/imageType,/channellist/logicalChannel/pictures/picture/href"}],"metaDataVer": "Channel/1.1", "channelNamespace": "2","filterlist": [{"key": "IsHide", "value": "-1"}], "returnSatChannel": "0"}';
        $url3 = "https://api.prod.sngtv.magentatv.de/EPG/JSON/AllChannel?SID=first&T=PC_firefox_75";
        $ch = curl_init ($url3);
        curl_setopt ($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt ($ch, CURLOPT_POST, 1);
        curl_setopt ($ch, CURLOPT_POSTFIELDS, $data3);
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded; charset=UTF-8'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Language: de,en-US;q=0.7,en;q=0.3'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Accept-Encoding: gzip, deflate, br'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Connection: keep-alive'));
	    curl_setopt ($ch, CURLOPT_HTTPHEADER, array('Upgrade-Insecure-Requests: 1'));
        curl_setopt ($ch, CURLOPT_HTTPHEADER, array('X_CSRFToken: ' . $xcsrf));
        curl_setopt ($ch, CURLOPT_USERAGENT, $agent);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt ($ch, CURLOPT_COOKIEFILE, $dir_path . '/web.magentatv.de.cookies.txt');
        $output3 = curl_exec($ch);
        curl_close($ch);
        echo $output3;
    }
?>
