Date: Wed, 25 Feb 2004 02:09:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: qsbench -p 4 -m 96 numbers
Message-Id: <20040225020932.14ca489a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

qsbench is a pretty stupid thing - doesn't seem to have reference
patternswhich are similar to anything apart from qsbench.  But whatever -
getting good numbers herre doesn't hurt anyone.

On the 256MB 2-way:

time ./qsbench -p 4 -m 96, 256MB, SMP:

2.4.25					5:41.67 1:48.89 1:45.38 1:32.43 1:37.42 1:47.30

blk_congestion_wait-return-remaining	1:20.81 0:49.29 1:18.58 1:13.27 1:02.09 2:24.03
kswapd-throttling-fixes			2:54.43 1:24.68 1:51.04 1:25.22 1:40.19 1:28.94
vm-dont-rotate-active-list		2:48.75 1:27.53 1:26.01 1:27.45 1:31.19 1:38.54
vm-lru-info				2:00.34 1:36.97 1:17.76 1:24.51 1:28.87 1:24.44
vm-shrink-zone				1:22.98 1:19.26 1:16.56 1:21.34 1:28.13 1:31.37
vm-tune-throttle			3:05.30 1:18.04 0:38.51 1:11.96 1:26.31 1:16.74
shrink_slab-for-all-zones		2:17.82 3:11.73 0:52.00 2:12.91 1:07.56 4:12.44
zone-balancing-fix			4:32.52 1:01.63 0:38.13 0:51.90 1:25.36 1:33.31
zone-balancing-batching			2:43.35 1:27.16 0:35.27 1:48.07 1:45.85 0:41.59

We seem to be beating 2.4 on this nowadays.  It was not always that way -
we used to have real problems with multiprocess workloads.

It's a shame that vm-tune-throttle is such a jumble of different things. 
But these numbers show so much variance it's hard to know what's happening.
Apart from "not much".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
