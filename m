Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7O4ldAW016015
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 00:47:39 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7O4ld7w527574
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 00:47:39 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7O4lcDM016103
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 00:47:38 -0400
Subject: Re: Drop caches - is this safe behavior?
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <46CE3617.6000708@redhat.com>
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>
	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>
	 <46CE3617.6000708@redhat.com>
Content-Type: text/plain
Date: Thu, 23 Aug 2007 23:47:37 -0500
Message-Id: <1187930857.6406.12.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: mike <mike503@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-23 at 21:36 -0400, Chris Snook wrote:

> If you think the system is doing the wrong thing (and it doesn't sound 
> like it is) you should be tweaking the vm.swappiness sysctl.  The 
> default is 60, but lower values will make it behave more like you think 
> it should be behaving, though you'll still probably see a tiny bit of 
> swap usage.  Of course, if your webservers are primarily serving up 
> static content, you'll want a higher value, since swapping anonymous 
> memory will leave more free for the pagecache you're primarily working with.

swappiness deals with page cache, whereas writing "2" to drop_caches
cleans out the inode and dentry caches.  Mike may be better off writing
a high number (say 10000) to /proc/sys/vm/vfs_cache_pressure.  This
would cause inode and dentry cache to be reclaimed sooner than other
memory.

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
