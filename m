Received: from sunA.comp.nus.edu.sg (zoum@sunA.comp.nus.edu.sg [137.132.87.10])
	by x86unx3.comp.nus.edu.sg (8.9.1/8.9.1) with ESMTP id RAA25319
	for <linux-mm@kvack.org>; Sat, 24 Feb 2001 17:41:22 +0800 (GMT-8)
Received: (from zoum@localhost)
	by sunA.comp.nus.edu.sg (8.8.5/8.8.5) id RAA01938
	for linux-mm@kvack.org; Sat, 24 Feb 2001 17:40:54 +0800 (GMT-8)
Date: Sat, 24 Feb 2001 17:40:54 +0800
From: Zou Min <zoum@comp.nus.edu.sg>
Subject: size of shared memory, buffer cache, page cache, etc.
Message-ID: <20010224174054.B29030@comp.nus.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, all,

Sorry to bother you to answer these naive questions about linux mm.

I know that in linux memory management, besides the pages actually used by
the some workload, there are also some shared pages (e.g. Copy-On-Write or 
IPC shared memory), disk caches (buffer/page cache), swap cache, dentry cache,
slab cache, etc, in order to improve the performance.

My 1st question is: usually, how can I roughly found out the size of the part 
of memory which is occupied by all those shared pages, different caches?
(assume there is some processes running)

2nd question is: how are those special pages managed differently, when there
is only single process running and when there are multiple processes running?

Thank you.

-- 
Cheers!
--Zou Min 

zoum@comp.nus.edu.sg			URL: http://www.comp.nus.edu.sg/~zoum
-----------------------------------------------------------------------------
Presume not that I am the thing I was.		--William Shakespeare
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
