Date: Wed, 3 May 2000 00:02:05 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <ytt4s8g1vx0.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005022355140.1677-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On 2 May 2000, Juan J. Quintela wrote:

><self package advertising> 
>I can reproduce this BUGs easily with the mmap002 program from the
>memtest-0.0.3 suite (http://carpanta.dc.fi.udc.es/~quintela/memtest/).
>You need to change the #define RAMSIZE to reflect your memory size in
>include file misc_lib.h and you run it in one while(true); do
>./mmap002; done and in the 8th, 9th execution it Oops here also.
></self package advertising>

I'll try this, thanks.

>If you want the patch for get rid of PG_swap_entry, I can do it and send
>it to you.

The PG_swap_entry isn't going to be the problem. However if you fear about
it try out this patch on top of 2.3.99-pre6. If PG_swap_entry is the
problem you'll get your problem fixed.

--- 2.3.99-pre6/mm/swapfile.c	Thu Apr 27 17:56:45 2000
+++ /tmp/swapfile.c	Tue May  2 23:57:24 2000
@@ -207,7 +207,7 @@
 	unsigned long offset, type;
 	swp_entry_t entry;
 
-	if (!PageSwapEntry(page))
+	if (1 || !PageSwapEntry(page))
 		goto new_swap_entry;
 
 	/* We have the old entry in the page offset still */

Just a thought, do you use NFS? If so please give a try without NFS
filesystem mounted. I should have addressed the NFS troubles in my current
tree but it's still under testing.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
