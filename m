Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C6DA76B0078
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 23:14:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o883EVZN014774
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Sep 2010 12:14:31 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6480645DE55
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 12:14:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4399A45DE4F
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 12:14:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 23BC11DB803C
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 12:14:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DAFD61DB803A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 12:14:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/9] Reduce latencies and improve overall reclaim efficiency v1
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Message-Id: <20100908115807.C916.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Sep 2010 12:14:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> There have been numerous reports of stalls that pointed at the problem being
> somewhere in the VM. There are multiple roots to the problems which means
> dealing with any of the root problems in isolation is tricky to justify on
> their own and they would still need integration testing. This patch series
> gathers together three different patch sets which in combination should
> tackle some of the root causes of latency problems being reported.
> 
> The first patch improves vmscan latency by tracking when pages get reclaimed
> by shrink_inactive_list. For this series, the most important results is
> being able to calculate the scanning/reclaim ratio as a measure of the
> amount of work being done by page reclaim.
> 
> Patches 2 and 3 account for the time spent in congestion_wait() and avoids
> calling going to sleep on congestion when it is unnecessary. This is expected
> to reduce stalls in situations where the system is under memory pressure
> but not due to congestion.
> 
> Patches 4-8 were originally developed by Kosaki Motohiro but reworked for
> this series. It has been noted that lumpy reclaim is far too aggressive and
> trashes the system somewhat. As SLUB uses high-order allocations, a large
> cost incurred by lumpy reclaim will be noticeable. It was also reported
> during transparent hugepage support testing that lumpy reclaim was trashing
> the system and these patches should mitigate that problem without disabling
> lumpy reclaim.

Wow, I'm sorry my lazyness bother you. I'll join to test this patch series
ASAP and take a feedback soon.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
