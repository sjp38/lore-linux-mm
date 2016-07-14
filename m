Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A29F6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 21:26:36 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j8so126093486itb.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 18:26:36 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e74si268233iof.228.2016.07.13.18.26.35
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 18:26:35 -0700 (PDT)
Date: Thu, 14 Jul 2016 10:27:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160714012752.GC23512@bbox>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
 <20160713085516.GI9806@techsingularity.net>
 <20160713130415.GB9905@cmpxchg.org>
 <20160713133701.GK9806@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160713133701.GK9806@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 02:37:01PM +0100, Mel Gorman wrote:
> On Wed, Jul 13, 2016 at 09:04:15AM -0400, Johannes Weiner wrote:
> > > Obviously I found the new names clearer but I was thinking a lot at the
> > > time about mapped vs unmapped due to looking closely at both reclaim and
> > > [f|m]advise functions at the time. I found it mildly irksome to switch
> > > between the semantics of file/anon when looking at the vmstat updates.
> > 
> > I can see that. It all depends on whether you consider mapping state
> > or page type the more fundamental attribute, and coming from the
> > mapping perspective those new names make sense as well.
> > 
> 
> From a reclaim perspective, I consider the mapped state to be more
> important. This is particularly true when the advise calls are taken
> into account. For example, madvise unmaps the pages without affecting
> memory residency (distinct from RSS) without aging. fadvise ignores mapped
> pages so the mapped state is very important for advise hints.  Similarly,
> the mapped state can affect how the pages are aged as mapped pages affect
> slab scan rates and incur TLB flushes on unmap. I guess I've been thinking
> about mapped/unmapped a lot recently which pushed me towards distinct naming.
> 
> > However, that leaves the disconnect between the enum name and what we
> > print to userspace. I find myself having to associate those quite a
> > lot to find all the sites that modify a given /proc/vmstat item, and
> > that's a bit of a pain if the names don't match.
> > 
> 
> I was tempted to rename userspace what is printed to vmstat as well but
> worried about breaking tools that parse it.
> 
> > I don't care strongly enough to cause a respin of half the series, and
> > it's not your problem that I waited until the last revision went into
> > mmots to review and comment. But if you agreed to a revert, would you
> > consider tacking on a revert patch at the end of the series?
> > 
> 
> In this case, I'm going to ask the other people on the cc for a
> tie-breaker. If someone else prefers the old names then I'm happy for
> your patch to be applied on top with my ack instead of respinning the
> whole series.
> 
> Anyone for a tie breaker?

I have thought it from reclaim perspective for a long time so I tempted to
change the naming like new one but there is no big justification for that.
In this chance, I vote new name.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
