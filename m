Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mATAtFZ7021468
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 29 Nov 2008 19:55:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3824045DD76
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:55:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19AC645DD74
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:55:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0B801DB8040
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:55:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A337C1DB803C
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:55:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
In-Reply-To: <20081128231933.8daef193.akpm@linux-foundation.org>
References: <20081128060803.73cd59bd@bree.surriel.com> <20081128231933.8daef193.akpm@linux-foundation.org>
Message-Id: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 29 Nov 2008 19:55:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> We already tried this, or something very similar in effect, I think...
> 
> 
> commit 26e4931632352e3c95a61edac22d12ebb72038fe
> Author: akpm <akpm>
> Date:   Sun Sep 8 19:21:55 2002 +0000
> 
>     [PATCH] refill the inactive list more quickly
>     
>     Fix a problem noticed by Ed Tomlinson: under shifting workloads the
>     shrink_zone() logic will refill the inactive load too slowly.
>     
>     Bale out of the zone scan when we've reclaimed enough pages.  Fixes a
>     rarely-occurring problem wherein refill_inactive_zone() ends up
>     shuffling 100,000 pages and generally goes silly.
>     
>     This needs to be revisited - we should go on and rebalance the lower
>     zones even if we reclaimed enough pages from highmem.
>     
> 
> 
> Then it was reverted a year or two later:
> 
> 
> commit 265b2b8cac1774f5f30c88e0ab8d0bcf794ef7b3
> Author: akpm <akpm>
> Date:   Fri Mar 12 16:23:50 2004 +0000
> 
>     [PATCH] vmscan: zone balancing fix
>     
>     We currently have a problem with the balancing of reclaim between zones: much
>     more reclaim happens against highmem than against lowmem.
>     
>     This patch partially fixes this by changing the direct reclaim path so it
>     does not bale out of the zone walk after having reclaimed sufficient pages
>     from highmem: go on to reclaim from lowmem regardless of how many pages we
>     reclaimed from lowmem.
>     
> 
> My changelog does not adequately explain the reasons.
> 
> But we don't want to rediscover these reasons in early 2010 :(  Some trolling
> of the linux-mm and lkml archives around those dates might help us avoid
> a mistake here.

I hope to digg past discussion archive.
Andrew, plese wait merge this patch awhile.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
