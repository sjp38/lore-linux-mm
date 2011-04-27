Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4529000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:43:24 -0400 (EDT)
Date: Wed, 27 Apr 2011 09:43:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
Message-ID: <20110427084319.GM4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
 <1303827785.20212.266.camel@twins>
 <20110426144635.GK4658@suse.de>
 <1303829449.20212.285.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1303829449.20212.285.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>

On Tue, Apr 26, 2011 at 04:50:49PM +0200, Peter Zijlstra wrote:
> On Tue, 2011-04-26 at 15:46 +0100, Mel Gorman wrote:
> > 
> > I did find that only a few route-cache entries should be required. In
> > the original patches I worked with, there was a reservation for the
> > maximum possible number of route-cache entries. I thought this was
> > overkill and instead reserved 1-per-active-swapfile-backed-by-NFS.
> 
> Right, so the thing I was worried about was a route-cache poison attack
> where someone would spam the machine such that it would create a lot of
> route cache entries and might flush the one we needed just as we needed
> it.
> 
> Pinning the one entry we need would solve that (if possible).

That is a possibility all right, nice thoughts there. Ok, as I do
not want this series to grow to the point where it is unreviewable,
I'll mark pinning the routing cache entry for a follow-on series.
In this series, the throttling logic should allow a new routing cache
entry to be allocated by kswapd as it's immune to the throttle.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
