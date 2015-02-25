Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3556B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 10:17:50 -0500 (EST)
Received: by wesw55 with SMTP id w55so4279275wes.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 07:17:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uq6si73626142wjc.12.2015.02.25.07.17.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 07:17:48 -0800 (PST)
Date: Wed, 25 Feb 2015 16:17:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150225151746.GG26680@dhcp22.suse.cz>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <1424765897-27377-3-git-send-email-minchan@kernel.org>
 <20150224161408.GB14939@dhcp22.suse.cz>
 <20150225002728.GB6468@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150225002728.GB6468@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Wed 25-02-15 09:27:28, Minchan Kim wrote:
> On Tue, Feb 24, 2015 at 05:14:08PM +0100, Michal Hocko wrote:
> > On Tue 24-02-15 17:18:16, Minchan Kim wrote:
> > > MADV_FREE is hint that it's okay to discard pages if memory is
> > > pressure and we uses reclaimers(ie, kswapd and direct reclaim)
> > 
> > s@if memory is pressure@if there is memory pressure@
> > 
> > > to free them so there is no worth to remain them in active
> > > anonymous LRU list so this patch moves them to inactive LRU list.
> > 
> > Makes sense to me.
> > 
> > > A arguable issue for the approach is whether we should put it
> > > head or tail in inactive list
> > 
> > Is it really arguable? Why should active MADV_FREE pages appear before
> > those which were living on the inactive list. This doesn't make any
> > sense to me.
> 
> It would be better to drop garbage pages(ie, freed from allocator)
> rather than swap out and now anon LRU aging is seq model so
> inacitve list can include a lot working set so putting hinted pages
> into tail of LRU could enhance reclaim efficiency.
> That's why I said it might be arguble.

OK, maybe I misunderstood what you tried to tell. Sure we can discuss
whether to put all MADV_FREE pages to the tail of inactive list. But
the above wording suggested that _active_ MADV_FREE pages were
discussed and treating them differently from the inactive pages simply
didn't make sense to me.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
