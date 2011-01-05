Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9B56B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 06:15:52 -0500 (EST)
Date: Wed, 5 Jan 2011 12:15:42 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20110105111542.GC4654@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
 <20101208141909.5c9c60e8.akpm@linux-foundation.org>
 <20101209000440.GM2356@cmpxchg.org>
 <20101209131723.fd51b032.akpm@linux-foundation.org>
 <20101210162706.GQ2356@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101210162706.GQ2356@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

On Fri, Dec 10, 2010 at 05:27:06PM +0100, Johannes Weiner wrote:
> On Thu, Dec 09, 2010 at 01:17:23PM -0800, Andrew Morton wrote:
> > Does that mean we can expect a v2?
> 
> Ok, while comparing Mel's patches with this change on IRC, I realized
> that the enterprise kernel the issue was reported against is lacking
> 'de3fab3 vmscan: kswapd: don't retry balance_pgdat() if all zones are
> unreclaimable'.
> 
> The above change fixed the observed malfunction of course, but Occam's
> Razor suggests that de3fab3 will do so, too.  I'll verify that, but I
> don't expect to send another version of this patch.

The problem is not reproducable on a kernel with de3fab3 applied.  You
were right from the start, it was a bug in the all_unreclaimable code.

The hopeless zone patch fixed the bug as well.  So I had a problem, a
working fix for it, and a broken mental image of the code that had me
convinced the all_unreclaimable logic was just not enough.

Maybe there is still a corner case where the all_unreclaimable logic
falls apart, but unless this happens in reality, I don't think there
is any reason to further pursue this.

> Sorry for the noise.
> 
> 	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
