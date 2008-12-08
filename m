Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB82nN06029213
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Dec 2008 11:49:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3445E45DE52
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 11:49:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F92545DD7A
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 11:49:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1DA91DB803F
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 11:49:22 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 83A711DB803B
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 11:49:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: improve reclaim throuput to bail out patch take2
In-Reply-To: <20081206192806.7bfba95b.akpm@linux-foundation.org>
References: <20081204102729.1D5C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081206192806.7bfba95b.akpm@linux-foundation.org>
Message-Id: <20081208110909.53E4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Dec 2008 11:49:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


I think my last explain was too poor.


> If this improved the throughput of direct-reclaim callers then one
> would expect it to make larger improvements for kswapd (assuming 
> that all other things are equal for those tasks, which they are not).
> 
> What is your direct-reclaim to kswapd-reclaim ratio for that workload?
> (grep pgscan /proc/vmstat)
> 

because that benchmark is direct reclaim torturess workload.

/proc/vmstat changing was

<before>
pgscan_kswapd_dma 1152
pgscan_kswapd_normal 2400
pgscan_kswapd_movable 0
pgscan_direct_dma 32
pgscan_direct_normal 512
pgscan_direct_movable 0

<after>
pgscan_kswapd_dma 3520
pgscan_kswapd_normal 12160
pgscan_kswapd_movable 0
pgscan_direct_dma 10048
pgscan_direct_normal 31904
pgscan_direct_movable 0

	-> kswapd:direct = 1 : 3.4


Why I test non typical extreame woakload?
I have two reason.

1. nobody want to regression although workload isn't typical.

2. if the patch can scale performance although extreme case,
   of cource it also can works well on light weight workload.


if my patch have any regression, it definityly is valueless.
my patch only solve extreme case.
but I don't think it has.


> Does that patch make any change to the amount of CPU time which kswapd
> consumed?

I don't mesure it yet.
but at least, top coomand didn't find any consumption increasing.


> 
> Or you can not bother doing this work ;) The patch looks sensible
> anyway.  It's just that the numbers look whacky.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
