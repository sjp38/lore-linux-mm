From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16444.32362.648358.521800@laputa.namesys.com>
Date: Wed, 25 Feb 2004 13:52:26 +0300
Subject: Re: qsbench -m 350 numbers
In-Reply-To: <20040225021113.4171c6ab.akpm@osdl.org>
References: <20040225021113.4171c6ab.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > This is a single-threaded workload.  We've been beating 2.4 on this since
 > forever.
 > 
 > time ./qsbench -m 350, 256MB, SMP:
 > 
 > 2.4.25					2:02.66 2:05.92 1:39.27
 > 
 > blk_congestion_wait-return-remaining	1:56.61 1:55.23 1:52.92
 > kswapd-throttling-fixes			2:06.49 2:05.53 2:06.18 2:06.52
 > vm-dont-rotate-active-list		2:05.73 2:08.44 2:08.86
 > vm-lru-info				2:07.00 2:07.17 2:08.65
 > vm-shrink-zone				2:02.60 2:00.91 2:02.34
 > vm-tune-throttle			2:05.88 1:58.20 1:58.02
 > shrink_slab-for-all-zones		2:00.67 2:02.30 1:58.36
 > zone-balancing-fix			2:06.54 2:08.29 2:07.17
 > zone-balancing-batching			2:36.25 2:38.86 2:43.28
 > 
 > 
 > Pretty much linear regression through all the "improvements" ;)

All regressions (save for zone-balancing-batching) are well in the
noise: I just ran qsbench and it seems to have a large variation of
elapsed time:

$ export TIMEFORMAT="%3R %3S %3U"
$ for i in $(seq 1 7) ;do time ./qsbench -m 350 ;done
106.770 2.834 24.404
111.041 2.975 24.130
108.535 2.796 24.214
108.676 2.894 24.181
109.222 2.719 24.407
114.044 2.878 24.155
108.514 2.801 24.340

Probably tests should be ran with -s option.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
