Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEA26B02A8
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:25:37 -0400 (EDT)
Date: Thu, 5 Aug 2010 16:25:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/7] vmscan: isolated_lru_pages() stop neighbor search
	if neighbor can't be isolated
Message-ID: <20100805152527.GI25688@csn.ul.ie>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151525.31CC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100805151525.31CC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:16:06PM +0900, KOSAKI Motohiro wrote:
> isolate_lru_pages() doesn't only isolate LRU tail pages, but also
> isolate neighbor pages of the eviction page.
> 
> Now, the neighbor search don't stop even if neighbors can't be isolated.
> It is silly. successful higher order allocation need full contenious
> memory, even though only one page reclaim failure mean to fail making
> enough contenious memory.
> 
> Then, isolate_lru_pages() should stop to search PFN neighbor pages and
> try to search next page on LRU soon. This patch does it. Also all of
> lumpy reclaim failure account nr_lumpy_failed.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Seems reasonable.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
