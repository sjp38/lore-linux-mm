Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2556B0069
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:28:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so45053114wma.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 07:28:51 -0800 (PST)
Received: from mx1.molgen.mpg.de (mx1.molgen.mpg.de. [141.14.17.9])
        by mx.google.com with ESMTPS id r3si3041435wmd.81.2016.11.29.07.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 07:28:50 -0800 (PST)
Received: from keineahnung.molgen.mpg.de (keineahnung.molgen.mpg.de [141.14.17.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: pmenzel)
	by mx.molgen.mpg.de (Postfix) with ESMTPSA id D1876201299B43
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:28:49 +0100 (CET)
From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Securely accessing linux-mm.org over HTTPS
Message-ID: <b029759f-aa50-0bb7-1c7e-2a83b69fb4b3@molgen.mpg.de>
Date: Tue, 29 Nov 2016 16:28:49 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Dear Linux-MM folks,


Securely accessing the MM Web site [1], the browser currently displays a 
warning sign. Looking at the network traffic with the development tools, 
the culprit is the URL below, which is embedded with HTTP and not HTTPS.

 > http://s7.addthis.com/button1-share.gif

This file is available over HTTPS too.

```
$ curl -I http://s7.addthis.com/button1-share.gif
HTTP/1.1 200 OK
Date: Tue, 29 Nov 2016 15:22:15 GMT
Content-Type: image/gif
Content-Length: 605
Connection: keep-alive
Last-Modified: Tue, 17 May 2016 17:16:09 GMT
ETag: "25d-5330ce5b45578"
Timing-Allow-Origin: *
Surrogate-Key: client_dist
CF-Cache-Status: HIT
Accept-Ranges: bytes
X-Host: s7.addthis.com
Server: cloudflare-nginx
CF-RAY: 30970dd3e0482d35-TXL
```

I already created a user account on the Web site, but I am unable to 
edit the template. Please tell me how I can do that, or contact the Web 
masters.


Kind regards,

Paul Menzel


[1] https://linux-mm.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
