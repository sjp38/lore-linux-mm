Received: from localhost ([127.0.0.1])
	by mailapp.tensilica.com with esmtp (Exim 4.34)
	id 1Hgl5Z-0003Ev-Ls
	for linux-mm@kvack.org; Wed, 25 Apr 2007 10:15:33 -0700
Received: from mailapp.tensilica.com ([127.0.0.1])
	by localhost (mailapp [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 11950-06 for <linux-mm@kvack.org>;
	Wed, 25 Apr 2007 10:15:33 -0700 (PDT)
Received: from tux.hq.tensilica.com ([192.168.11.71])
	by mailapp.tensilica.com with esmtp (Exim 4.34)
	id 1Hgl5Z-0003Eq-2T
	for linux-mm@kvack.org; Wed, 25 Apr 2007 10:15:33 -0700
Message-ID: <462F8CB4.4070907@tensilica.com>
Date: Wed, 25 Apr 2007 10:15:32 -0700
From: Chris Zankel <zankel@tensilica.com>
MIME-Version: 1.0
Subject: SMP and cache-aliasing.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Sorry for the intrusion, but maybe someone with more insight in linux 
memory-management can give me a brief hint about the following:

In an SMP system with cache-aliasing, is it possible that the same 
physical page is mapped to two or more virtual addresses of different 
'color'?

On a single processor system this doesn't happen. Shared pages are 
always allocated in a way to avoid cache-aliasing and non-shared pages 
are only mapped once in user-space.

I guess that leaves kernel space. Is it possible that the kernel running 
on the two different processors maps the same physical address to pages 
of different 'color' in kernel space?

Thank you for any input,
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
