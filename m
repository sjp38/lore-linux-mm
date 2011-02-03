Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E6F38D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 14:12:26 -0500 (EST)
Date: Thu, 3 Feb 2011 20:11:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110203191157.GN5843@random.random>
References: <20110124150033.GB9506@random.random>
 <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <4D4ABD7F.2060208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D4ABD7F.2060208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On Thu, Feb 03, 2011 at 09:36:47AM -0500, Rik van Riel wrote:
> On 02/02/2011 09:58 PM, Andrea Arcangeli wrote:
> 
> > Comments welcome,
> > Thanks!
> > Andrea
> >
> >> ====
> >> Subject: vmscan: kswapd must not free more than high_wmark pages
> 
> NAK
> 
> I believe we need a little bit of slack above high_wmark_pages,
> to be able to even out memory pressure between zones.
> 
> Maybe free up to high_wmark_pages + min_wmark_pages ?

If this can only go in with high+min that's still better than *8, but
in prev email on this thread I explained why I think it's not
beneficial for lru balancing and this level can't affect kswapd wakeup
times either, so I personally prefer just "high". I don't think out of
memory has anything to do with this the "min" level is all about the
PF_MEMALLOC and OOM levels. The zone balancing as well has nothing to
do with this and the only "hard" thing that guarantees balancing is
the lowmem reserve ratio (high ptes allocated in lowmem zones aren't
relocatable etc..).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
