Message-ID: <20040429122741.95537.qmail@web21407.mail.yahoo.com>
Date: Thu, 29 Apr 2004 05:27:41 -0700 (PDT)
From: mahesh gowda <aryamithra@yahoo.com>
Subject: Trouble freeing pinned pages.
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We are developing a device driver on kernel version
2.4.21. We have a program in user-space that registers

a part of its virtual address space with our driver.
This memory may be anonymous or file backed.

In the driver, we translate the virtual addresses to 
physical pages and pin them down. We want to hold on 
to these pages even after the userspace program exits.

Our current approach is: 
Fault in the required pages using get_user_pages(), 
increment page reference count using get_page() and 
release the pages using put_page() when the driver 
unloads. But this is not working. The pages that we 
release seem to remain on the inactive list and never 
get freed. We have also attempted usig SetPageReserved
() and ClearPageReserved() in place of 
get_page/put_page. But that didn't help either. 

 Any ideas on debugging or getting this to work right
will be very helpful.

Please cc me on replies as i have not subscribed to 
the list.

Thanks,
Mahesh.


	
		
__________________________________
Do you Yahoo!?
Win a $20,000 Career Makeover at Yahoo! HotJobs  
http://hotjobs.sweepstakes.yahoo.com/careermakeover 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
