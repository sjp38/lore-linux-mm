Message-ID: <403C76D8.3000302@cyberone.com.au>
Date: Wed, 25 Feb 2004 21:20:08 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: vm benchmarking
References: <20040224034036.22953169.akpm@osdl.org>
In-Reply-To: <20040224034036.22953169.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>I took the various patches in -mm for a quick ride.  Dual CPU, mem=64m,
>`time make -j4 vmlinux':
>
>
>2.4.25						2:57.34 2:45.62
>
>up to blk_congestion_wait-return-remaining	5:41.52	5:56.37
>up to vmscan-remove-priority
>up to kswapd-throttling-fixes			7:44.53
>up to vm-dont-rotate-active-list		6:29.23
>up to vm-dont-rotate-active-list-padding
>up to vm-lru-info				9:28.47 6:14.70 5:11.99
>up to vm-shrink-zone
>up to vm-shrink-zone-div-by-0-fix		9:13.21 8:17.29
>up to vm-tune-throttle				7:39.89
>up to shrink_slab-for-all-zones			7:06.27
>up to zone-balancing-fix			7:46.15
>up to zone-balancing-batching
>up to zone-balancing-batching-fix		4:44.76 4:27.02 4:05.56 4:31.66 4:06.76
>
>
>Based on this, and on your totally contradictory benchmarking, all I'm
>prepared to say is that kswapd-throttling-fixes slows things down, and we
>don't know why.  The rest appears to be worth zilch.  Possibly they slow
>some things down as much as they speed other things up.
>
>

My machine doesn't touch swap at make -j4 with mem=64m. It is
dual CPU with a SMP kernel but I was using maxcpus=1.

It compiles 2.4.21 with gcc-3.3.3 I think (I can tell you when I
get home).

I can't explain your results. Maybe you have other stuff running.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
