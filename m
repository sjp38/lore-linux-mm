Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9736C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 14:12:57 -0500 (EST)
Date: Thu, 3 Feb 2011 19:59:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110203185933.GK5843@random.random>
References: <20110124150033.GB9506@random.random>
 <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <20110203131549.GE11958@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110203131549.GE11958@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>

On Thu, Feb 03, 2011 at 01:15:49PM +0000, Mel Gorman wrote:
> I got a chance to test this today and I see similar results. I still do see
> kswapd entering D state occasionally and I'm convinced it's because it's
> calling congestion_wait() i.e. it's not real IO but it's being accounted
> for as an IO-related wait. That said, it's mostly asleep (S) or running (R)
> and free memory is at reasonable levels so it's a big improvement.

I never seen it in D state here but maybe it happens
occasionally and I would expect the R/S/D states not to be altered by
this change, just the free levels should be altered.

> I think this is the best direction to take for the moment to close the obvious
> bug. More thought is required on when exactly kswapd is going to sleep and
> on what zones the allocator should be using but there is no quick answer that
> will simply have other consequences. As much as I'd like to investigate this
> further now, I'm in the process of changing jobs and expect to be heavily
> disrupted for at least a month during the changeover. So, for this;

I full agree we should check (with less hurry) exactly when kswapd is
going to sleep in this load in case it's waken too early. I expect it
will remain an independent issue and I don't expect this patch having
to be reversed once we figure why free levels stays always at "high"
and we don't see them reaching "low".

Thanks for the review,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
