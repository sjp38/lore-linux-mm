Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 47D6A6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 01:38:12 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2314167pvc.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 22:38:09 -0700 (PDT)
Date: Tue, 31 May 2011 14:38:02 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110531053802.GA1519@barrios-laptop>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110531134835.b7c9edc2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110531134835.b7c9edc2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

Hi Kame,

On Tue, May 31, 2011 at 01:48:35PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 30 May 2011 14:13:00 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Asynchronous compaction is used when promoting to huge pages. This is
> > all very nice but if there are a number of processes in compacting
> > memory, a large number of pages can be isolated. An "asynchronous"
> > process can stall for long periods of time as a result with a user
> > reporting that firefox can stall for 10s of seconds. This patch aborts
> > asynchronous compaction if too many pages are isolated as it's better to
> > fail a hugepage promotion than stall a process.
> > 
> > If accepted, this should also be considered for 2.6.39-stable. It should
> > also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
> > compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
> > writeback] would be applied to 2.6.38 before consideration.
> > 
> > Reported-and-Tested-by: Ury Stankevich <urykhy@gmail.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> 
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> BTW, I'm surprised to see both of vmscan.c and compaction.c has too_many_isolated()..
> in different logic ;)
> 
> BTW, compaction ignores UNEVICTABLE LRU ?

Good point.
Yes. now compaction doesn't work with unevictable LRU but I think we have no reason
to work well with unveictable pages. 
If we don't support unevictable lru, it would be a problem in lots of
mlocked pages workload.
It would be a good enhance point on compaction.

> 
> Thanks,
> -Kame
-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
