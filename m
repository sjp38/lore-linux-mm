Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E9E536B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 05:26:47 -0400 (EDT)
Date: Sat, 16 May 2009 17:26:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090516092645.GA11652@localhost>
References: <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090507134410.0618b308.akpm@linux-foundation.org> <20090508081608.GA25117@localhost> <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025058.GA7518@localhost> <4A09778B.5030809@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A09778B.5030809@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 12, 2009 at 09:20:11PM +0800, Rik van Riel wrote:
> Wu Fengguang wrote:
> 
> >> Also, the change makes this comment:
> >>
> >> 	spin_lock_irq(&zone->lru_lock);
> >> 	/*
> >> 	 * Count referenced pages from currently used mappings as
> >> 	 * rotated, even though they are moved to the inactive list.
> >> 	 * This helps balance scan pressure between file and anonymous
> >> 	 * pages in get_scan_ratio.
> >> 	 */
> >> 	reclaim_stat->recent_rotated[!!file] += pgmoved;
> >>
> >> inaccurate.
> > 
> > Good catch, I'll just remove the stale "even though they are moved to
> > the inactive list".
> 
> Well, it is still true for !VM_EXEC pages.

This comment?

        Count referenced pages from currently used mappings as rotated, even
        though only some of them are actually re-activated. This helps...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
