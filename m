Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6BF238D0001
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:11:04 -0400 (EDT)
Date: Mon, 14 May 2012 12:10:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
Message-ID: <20120514111058.GC29102@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <20120511.010445.1020972261904383892.davem@davemloft.net>
 <20120511154540.GV11435@suse.de>
 <20120511.172339.2007927803884694483.davem@davemloft.net>
 <20120511142932.af7851bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120511142932.af7851bd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, May 11, 2012 at 02:29:32PM -0700, Andrew Morton wrote:
> On Fri, 11 May 2012 17:23:39 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Mel Gorman <mgorman@suse.de>
> > Date: Fri, 11 May 2012 16:45:40 +0100
> > 
> > > From my point of view, the ideal would be that all the patches go
> > > through akpm's tree or yours but that probably will cause merge
> > > difficulties.
> > > 
> > > Any recommendations?
> > 
> > I know there will be networking side conflicts very soon, it's not a
> > matter of 'if' but 'when'.
> > 
> > But the trick is that I bet the 'mm' and 'slab' folks are in a similar
> > situation.
> > 
> > In any event I'm more than happy to take it all in my tree.
> 
> I guess either is OK.  The main thing is to get it all reviewed and
> tested, after all.
> 
> I can take all the patches once it's all lined up and everyone is
> happy.  If the net bits later take significant damage then I can squirt them
> at you once the core MM bits are merged.  That would give you a few
> days to check them over and get them into Linus.  If that's a problem,
> we can hold the net bits over for a cycle.
> 
> That's all assuming that the core MM parts are mergeable without the
> net parts being merged.  I trust that's the case!

I expect it to be the case as the series is (or at least should be)
bisect safe. If there is a conflict of some sort, just cut off at that
point and it should be fine until it gets fixed up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
