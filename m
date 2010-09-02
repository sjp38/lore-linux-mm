Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 786346B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:43:46 -0400 (EDT)
Date: Wed, 1 Sep 2010 19:43:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <1283276257-1793-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009011942150.21189@router.home>
References: <1283276257-1793-1-git-send-email-mel@csn.ul.ie> <1283276257-1793-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010, Mel Gorman wrote:

> +#ifdef CONFIG_SMP
> +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> +unsigned long zone_nr_free_pages(struct zone *zone)
> +{
> +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);

You cannot call zone_page_state here because zone_page_state clips the
counter at zero. The nr_free_pages needs to reflect the unclipped state
and then the deltas need to be added. Then the clipping at zero can be
done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
