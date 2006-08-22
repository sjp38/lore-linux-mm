Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7MNrOXl021080
	for <linux-mm@kvack.org>; Tue, 22 Aug 2006 19:53:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7MNrOX8349690
	for <linux-mm@kvack.org>; Tue, 22 Aug 2006 17:53:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7MNrNxp019145
	for <linux-mm@kvack.org>; Tue, 22 Aug 2006 17:53:23 -0600
Received: from dyn9047017164.beaverton.ibm.com (dyn9047017164.beaverton.ibm.com [9.47.17.164])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7MNrN7G019139
	for <linux-mm@kvack.org>; Tue, 22 Aug 2006 17:53:23 -0600
Subject: vm_total_pages and page-writeback.c:total_pages
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Tue, 22 Aug 2006 16:53:23 -0700
Message-Id: <1156290803.6479.129.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

I was looking at page-writeback.c and found that there is a static
variable "total_pages", which is same as the global variable
"vm_total_pages" except that "total_pages" is not updated when new pages
are brought in through memory hotplug.

Looking at the usage of "total_pages", it doesn't look intentional. Can
somebody tell if it is the intentional or it a bug that needs to be
fixed ?

Under the same context, "ratelimit_pages" in page-writeback.c is
recalculated every time CPU is hot added/removed. But there is no
recalculation happening when new memory pages are hot added. This also
doesn't seem to be right. Comments ?

regards,

chandra  
-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
