Date: Fri, 19 Jan 2001 07:59:40 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] Limited background active list [and pte] scanning 
In-Reply-To: <Pine.LNX.4.30.0101191245100.1137-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0101190757300.5254-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jan 2001, Ingo Molnar wrote:

> 
> Marcelo,
> 
> your patch did not compile as-is because you did not export the
> bp_page_aging variable to mm/swap.c.

Ugh, sorry. Here it goes:

--- linux.orig/include/linux/swap.h     Thu Jan 11 11:13:38 2001
+++ linux/include/linux/swap.h  Thu Jan 11 14:54:57 2001
@@ -101,6 +101,7 @@
 extern void swap_setup(void);

 /* linux/mm/vmscan.c */
+extern int bg_page_aging;
 extern struct page * reclaim_page(zone_t *);
 extern wait_queue_head_t kswapd_wait;
 extern wait_queue_head_t kreclaimd_wait;





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
