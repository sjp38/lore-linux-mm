Received: from sunA.comp.nus.edu.sg (zoum@sunA.comp.nus.edu.sg [137.132.87.10])
	by x86unx3.comp.nus.edu.sg (8.9.1/8.9.1) with ESMTP id RAA25026
	for <linux-mm@kvack.org>; Sat, 24 Feb 2001 17:29:43 +0800 (GMT-8)
Received: (from zoum@localhost)
	by sunA.comp.nus.edu.sg (8.8.5/8.8.5) id RAA00883
	for linux-mm@kvack.org; Sat, 24 Feb 2001 17:29:15 +0800 (GMT-8)
Date: Sat, 24 Feb 2001 17:29:15 +0800
From: Zou Min <zoum@comp.nus.edu.sg>
Subject: besides replacable pages in memory
Message-ID: <20010224172915.A29030@comp.nus.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am a newbie in the study of memory management in linux.
Usually, in OS, some of the kernel's code and data pages may not be replaceable,
e.g. the nonpaged pool in Windows NT/2000. I would like to find out, in Linux 
what are the portion of pages in memory, which are not replacable. And what are
they used for in details?

Lastly, may I know how to find out the size of the non-replacable pages in 
memory, given any workload. 

Many thanks!

-- 
Cheers!
--Zou Min 

zoum@comp.nus.edu.sg			URL: http://www.comp.nus.edu.sg/~zoum
-----------------------------------------------------------------------------
        Punch, brothers! punch with care!
        Punch in the presence of the passenjare!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
