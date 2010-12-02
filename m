Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 72DDF8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:41:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB21f4Pg012633
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 10:41:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B08A945DE67
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C17D45DE61
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:41:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 798E01DB8042
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:41:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FA681DB803E
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:41:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Difference between CommitLimit and Comitted_AS?
In-Reply-To: <B13AEDEE265EDB4182EA8B932E33033D13A904B7@SOSEXCHCL02.howost.strykercorp.com>
References: <B13AEDEE265EDB4182EA8B932E33033D13A904B7@SOSEXCHCL02.howost.strykercorp.com>
Message-Id: <20101202103408.1584.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Dec 2010 10:41:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Westerdale, John" <John.Westerdale@stryker.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi All,
> 
> Am interested in differentiating the meaning of Commit* and Vmalloc*.
> 
> I had thought that the Committed_AS was the sum of memory allocations,
> and Commit_Limit was the available memory to serve this from.
> 
> That said, I winced when I saw that Committed_AS was almost twice the
> Commit__Limit.

Commit_Limit is only meaningful when overcommit_memory=2.

And, Linux has virtual memory feature. then memory allocation has 2 levels,
virtual address space allocation and physical memory allocation.
Committed_AS mean amount of committed virtual address space. It's not
physical.

Example, if you create thread, libc allocate lots address space for stack.
but typical program don't use so large stack. then physical memory will be 
not allocated.


> 
> Vmalloc looks inconsequential, but, the Commit* numbers must be there
> for a reason.
> 
> Is it safe to continue running with such a perceived over-commit?

Probably safe. Java runtime usually makes a lot of overcommits. but I have
no way to know exactly your system state. 


> 
> Is this evidence of a leak or garbage collection issues?

Maybe no.

> 
> This system functions as an App/Web front end using  Tomcat servelet
> engine, FWIW.
> 
> Thanks
> 
> John Westerdale
> 
> 
> MemTotal:     16634464 kB
> MemFree:      11077520 kB
> Buffers:        420768 kB
> Cached:        4379000 kB
> SwapCached:          0 kB
> Active:        4577960 kB
> Inactive:       685344 kB
> HighTotal:    15859440 kB
> HighFree:     10987632 kB
> LowTotal:       775024 kB
> LowFree:         89888 kB
> SwapTotal:     4194296 kB
> SwapFree:      4194296 kB
> Dirty:              12 kB
> Writeback:           0 kB
> AnonPages:      462748 kB
> Mapped:          65420 kB
> Slab:           260144 kB
> PageTables:      21712 kB
> NFS_Unstable:        0 kB
> Bounce:              0 kB
> CommitLimit:  12511528 kB
> Committed_AS: 22423356 kB
> VmallocTotal:   116728 kB
> VmallocUsed:      6600 kB
> VmallocChunk:   109612 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> Hugepagesize:     2048 kB	
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
