Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A39766B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 03:25:56 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1904974pwi.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 00:25:54 -0700 (PDT)
Date: Mon, 30 May 2011 16:25:46 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2 00/10] Prevent LRU churning
Message-ID: <20110530072546.GA1727@barrios-laptop>
References: <cover.1306689214.git.minchan.kim@gmail.com>
 <4DE2F741.7060109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE2F741.7060109@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mgorman@suse.de, riel@redhat.com, aarcange@redhat.com, hannes@cmpxchg.org

On Mon, May 30, 2011 at 10:47:45AM +0900, KOSAKI Motohiro wrote:
> > Minchan Kim (10):
> >   [1/10] Make clear description of isolate/putback functions
> >   [2/10] compaction: trivial clean up acct_isolated
> >   [3/10] Change int mode for isolate mode with enum ISOLATE_PAGE_MODE
> >   [4/10] Add additional isolation mode
> >   [5/10] compaction: make isolate_lru_page with filter aware
> >   [6/10] vmscan: make isolate_lru_page with filter aware
> >   [7/10] In order putback lru core
> >   [8/10] migration: make in-order-putback aware
> >   [9/10] compaction: make compaction use in-order putback
> >   [10/10] add tracepoints
> 
> Minchan,
> 
> I'm sorry I have no chance to review this patch in this week. I'm getting
> stuck for LinuxCon. ;)

I hope you will be free from LinuxCon sometime soon.

> That doesn't mean I dislike this series.

Thanks for the positive feedback, KOSAKI.

I don't think no comment is a negative feedback. 
I think they are very busy these days(ex, memcg typhoon, OOM argument, 
reclaim latency and LinuxCon which I have forgotten.)
This patch isn't urgent so I will wait review of mm folks in patience.

> 
> Thanks.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
