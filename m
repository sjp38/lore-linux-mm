Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AD4816B03B6
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 08:56:44 -0400 (EDT)
Date: Mon, 23 Aug 2010 07:56:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <1282550442-15193-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1008230750380.4094@router.home>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie> <1282550442-15193-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Mel Gorman wrote:

> This patch introduces zone_nr_free_pages() to take a slightly more accurate
> estimate of NR_FREE_PAGES while kswapd is awake. The estimate is not perfect
> and may result in cache line bounces but is expected to be lighter than the
> IPI calls necessary to continually drain the per-cpu counters while kswapd
> is awake.

The delta of the counters could also be reduced to increase accuracy.
See refresh_zone_stat_thresholds().

Also would it be possible to add the summation function to vmstat? It may
be useful elsewhere.

A new function like

	zone_page_state_snapshot()

or so?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
