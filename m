Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA00157
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 14:38:15 -0500
Date: Mon, 11 Jan 1999 20:36:50 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <369A2D5E.472B7F75@netplus.net>
Message-ID: <Pine.LNX.3.96.990111202801.565A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 1999, Steve Bergman wrote:

> Here are updated results including arcavm16:
> 
> 
> 116 Image test in 128MB:
> 
> pre6+zlatko's_patch             2:35
> and with requested change       3:09
> pre6                            2:27
> pre5                            1:58
> arcavm13                        9:13
> arcavm15                        1:59
> pre-7                           2:41
> arcavm16			1:54

Cool, now that arcavm16 (in pre6) is faster than pre5 I am courious to see
what will happens with the one liner patch below applyed on the top of
arcavm16 (maybe nothing but... ;). We can call the resulting code arcavm17
against pre6 (that pratically insteaed is arcavm16 applyed on pre5 ;).

Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.7 linux/mm/page_alloc.c:1.1.1.1.2.27
--- linux/mm/page_alloc.c:1.1.1.7	Sat Jan  9 12:58:25 1999
+++ linux/mm/page_alloc.c	Mon Jan 11 19:57:07 1999
@@ -279,7 +279,7 @@
 		{
 			int freed;
 			current->flags |= PF_MEMALLOC;
-			freed = try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);
+			freed = try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
 			current->flags &= ~PF_MEMALLOC;
 			if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 				goto nopage;



Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
