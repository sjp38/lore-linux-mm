Received: from localhost (morework [127.0.0.1])
	by morework.geizhals.at (Postfix) with ESMTP id D7D42DEC99
	for <linux-mm@kvack.org>; Thu, 24 Nov 2005 20:52:42 +0100 (CET)
Received: from [10.0.0.126] (unknown [10.0.0.126])
	by morework.geizhals.at (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 24 Nov 2005 20:52:42 +0100 (CET)
Message-ID: <43861A43.3070300@geizhals.at>
Date: Thu, 24 Nov 2005 20:53:39 +0100
From: Michael Renner <michael.renner@geizhals.at>
MIME-Version: 1.0
Subject: Problems with amd64 on "big" boxes in oom situations
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've got a 8x dual core opteron server with 64 gb ram which reproducible 
locks up when it gets into an OOM situation. The traces for 2.6.14 and 
2.6.15-rc2 can be found at: http://666kb.com/i/10yom358azw8w.jpg , 
http://666kb.com/i/10yov42ydfdog.jpg .

Used .config: http://phpfi.com/88428

There were 1+16 (forked) processes, each starting with a base memory 
usage of 3.1 gb (maybe CoW, can't say), slowly growing while they ran, 
each utilizing a processor/core very thoroughly. Eventually the 
available memory was used up and the machine locked up shortly afterwards.

Any ideas?

-- 

best regards,
  Michael Renner - Network services

Preisvergleich Internet Services AG
Obere Donaustrasse 63/2, A-1020 Wien
Tel: +43 1 5811609 80
Fax: +43 1 5811609 55

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
