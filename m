Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Tue, 28 Aug 2001 00:57:34 +0200
References: <3B8AAA3E.80707@syntegra.com>
In-Reply-To: <3B8AAA3E.80707@syntegra.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010827225101Z16227-32386+152@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 27, 2001 10:14 pm, Andrew Kay wrote:
> I am having some rather serious problems with the memory management (i 
> think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots 
> of these errors in /var/log/messages.
> 
> Aug 24 15:08:04 dell63 kernel: __alloc_pages: 1-order allocation failed.
> Aug 24 15:08:35 dell63 last message repeated 448 times
> Aug 24 15:09:37 dell63 last message repeated 816 times
> Aug 24 15:10:38 dell63 last message repeated 1147 times
> 
> I am running a Redhat 7.1 distro w/2.4.9 kernel on a Dell poweredge 6300 
> (4x500Mhz cpu, 4Gb ram).  I get this error while running the specmail 
> 2001 benchmarking software against our email server, Intrastore.  The 
> system  is very idle from what I can see.  The sar output shows user cpu 
> at around 1% and everything else rather low as well.  It seems to pop up 
> randomly and requires a reboot to fix it.
> 
> Is there any workarounds or something I can do to get a more useful 
> debug message than this?

Please apply this patch:

--- 2.4.9.clean/mm/page_alloc.c	Thu Aug 16 12:43:02 2001
+++ 2.4.9/mm/page_alloc.c	Mon Aug 20 22:05:40 2001
@@ -502,7 +502,8 @@
 	}
 
 	/* No luck.. */
-	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n", order);
+	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed (gfp=0x%x/%i).\n",
+		order, gfp_mask, !!(current->flags & PF_MEMALLOC));
 	return NULL;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
