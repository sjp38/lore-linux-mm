Date: Wed, 25 Feb 2004 02:11:13 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: qsbench -m 350 numbers
Message-Id: <20040225021113.4171c6ab.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a single-threaded workload.  We've been beating 2.4 on this since
forever.

time ./qsbench -m 350, 256MB, SMP:

2.4.25					2:02.66 2:05.92 1:39.27

blk_congestion_wait-return-remaining	1:56.61 1:55.23 1:52.92
kswapd-throttling-fixes			2:06.49 2:05.53 2:06.18 2:06.52
vm-dont-rotate-active-list		2:05.73 2:08.44 2:08.86
vm-lru-info				2:07.00 2:07.17 2:08.65
vm-shrink-zone				2:02.60 2:00.91 2:02.34
vm-tune-throttle			2:05.88 1:58.20 1:58.02
shrink_slab-for-all-zones		2:00.67 2:02.30 1:58.36
zone-balancing-fix			2:06.54 2:08.29 2:07.17
zone-balancing-batching			2:36.25 2:38.86 2:43.28


Pretty much linear regression through all the "improvements" ;)

zone-balancing-batching hurts.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
