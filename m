Received: from [192.168.1.3] (unknown [192.168.1.3])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by unox.bitpit.net (Postfix) with ESMTP id 730BA1B8
	for <linux-mm@kvack.org>; Thu,  5 Jan 2006 22:13:28 +0100 (MET)
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Transfer-Encoding: 7bit
Message-Id: <34EBD6CD-1972-4FCC-98A9-4B9CAE4287AE@bitpit.net>
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
From: Marijn Meijles <marijn@bitpit.net>
Subject: Multiple invocations of wakeup_kswapd
Date: Thu, 5 Jan 2006 22:13:25 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I was wondering why __alloc_pages calls wakeup_kswapd for every zone.  
It seems to me that one time is enough, balance_pgdat looks at the  
whole node anyway.

-- 
Marijn
---
This line says this line says

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
