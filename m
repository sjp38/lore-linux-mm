From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16443.15622.571180.974245@laputa.namesys.com>
Date: Tue, 24 Feb 2004 15:01:10 +0300
Subject: Re: vm benchmarking
In-Reply-To: <20040224034036.22953169.akpm@osdl.org>
References: <20040224034036.22953169.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > I took the various patches in -mm for a quick ride.  Dual CPU, mem=64m,
 > `time make -j4 vmlinux':
 > 
 > 
 > 2.4.25						2:57.34 2:45.62
 > 
 > up to blk_congestion_wait-return-remaining	5:41.52	5:56.37
 > up to vmscan-remove-priority
 > up to kswapd-throttling-fixes			7:44.53
 > up to vm-dont-rotate-active-list		6:29.23
 > up to vm-dont-rotate-active-list-padding
 > up to vm-lru-info				9:28.47 6:14.70 5:11.99
 > up to vm-shrink-zone
 > up to vm-shrink-zone-div-by-0-fix		9:13.21 8:17.29
 > up to vm-tune-throttle				7:39.89
 > up to shrink_slab-for-all-zones			7:06.27
 > up to zone-balancing-fix			7:46.15
 > up to zone-balancing-batching
 > up to zone-balancing-batching-fix		4:44.76 4:27.02 4:05.56 4:31.66 4:06.76

Can you clarify what these numbers mean?

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
