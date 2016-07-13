Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8806B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:37:05 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so33360027lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:37:05 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id k3si1023036wjo.97.2016.07.13.06.37.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 06:37:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D393299371
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 13:37:02 +0000 (UTC)
Date: Wed, 13 Jul 2016 14:37:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160713133701.GK9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
 <20160713085516.GI9806@techsingularity.net>
 <20160713130415.GB9905@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160713130415.GB9905@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 09:04:15AM -0400, Johannes Weiner wrote:
> > Obviously I found the new names clearer but I was thinking a lot at the
> > time about mapped vs unmapped due to looking closely at both reclaim and
> > [f|m]advise functions at the time. I found it mildly irksome to switch
> > between the semantics of file/anon when looking at the vmstat updates.
> 
> I can see that. It all depends on whether you consider mapping state
> or page type the more fundamental attribute, and coming from the
> mapping perspective those new names make sense as well.
> 

>From a reclaim perspective, I consider the mapped state to be more
important. This is particularly true when the advise calls are taken
into account. For example, madvise unmaps the pages without affecting
memory residency (distinct from RSS) without aging. fadvise ignores mapped
pages so the mapped state is very important for advise hints.  Similarly,
the mapped state can affect how the pages are aged as mapped pages affect
slab scan rates and incur TLB flushes on unmap. I guess I've been thinking
about mapped/unmapped a lot recently which pushed me towards distinct naming.

> However, that leaves the disconnect between the enum name and what we
> print to userspace. I find myself having to associate those quite a
> lot to find all the sites that modify a given /proc/vmstat item, and
> that's a bit of a pain if the names don't match.
> 

I was tempted to rename userspace what is printed to vmstat as well but
worried about breaking tools that parse it.

> I don't care strongly enough to cause a respin of half the series, and
> it's not your problem that I waited until the last revision went into
> mmots to review and comment. But if you agreed to a revert, would you
> consider tacking on a revert patch at the end of the series?
> 

In this case, I'm going to ask the other people on the cc for a
tie-breaker. If someone else prefers the old names then I'm happy for
your patch to be applied on top with my ack instead of respinning the
whole series.

Anyone for a tie breaker?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
