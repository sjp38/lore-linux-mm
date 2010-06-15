Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7610F6B01E7
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:47:09 -0400 (EDT)
Date: Tue, 15 Jun 2010 06:47:01 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/12] vmscan: Setup pagevec as late as possible in
 shrink_inactive_list()
Message-ID: <20100615104701.GA31051@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 12:17:49PM +0100, Mel Gorman wrote:
>  /*
> + * TODO: Try merging with migrations version of putback_lru_pages
> + */
> +static noinline_for_stack void putback_lru_pages(struct zone *zone,
> +				struct zone_reclaim_stat *reclaim_stat,
> +				unsigned long nr_anon, unsigned long nr_file,
> + 				struct list_head *page_list)
> +{

I hate to nitpick on this, but with noinline_for_stack a prototype
really is unreadbale unless the function identifier goes to the next
line.  Compare the one above with:

static noinline_for_stack void
putback_lru_pages(struct zone *zone, struct zone_reclaim_stat *reclaim_stat,
		unsigned long nr_anon, unsigned long nr_file,
		struct list_head *page_list)

> -static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> +static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to_scan,
>  			struct zone *zone, struct scan_control *sc,
>  			int priority, int file)

Same here, just even worse due to the spill over ove 80 characters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
