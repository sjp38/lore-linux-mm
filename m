Date: Wed, 25 Feb 2004 02:06:01 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: mem01 numbers
Message-Id: <20040225020601.69e5eb0b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not sure what mem01 (from LTP) does.  I think it's just a linear swipe
across a gig of memory.

On the 2-way 256MB box:

2.4.25					31.482 30.691 30.969

blk_congestion_wait-return-remaining	27.509 27.326 27.321
kswapd-throttling-fixes			27.755 27.839 27.807
vm-dont-rotate-active-list		32.491 35.696 29.714
vm-lru-info				34.605 26.118 26.458
vm-shrink-zone-div-by-0-fix		27.401 32.760 25.791
vm-tune-throttle			29.375 29.469 27.638
shrink_slab-for-all-zones		32.274 27.720 26.689
zone-balancing-fix			25.267 26.220 31.772
zone-balancing-batching-fix		24.824 28.653 29.287 28.852

So, tentatively, vm-dont-rotate-active-list hurt a little bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
