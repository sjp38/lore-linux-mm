Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 98D6B6B005C
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 15:20:26 -0500 (EST)
Date: Wed, 4 Jan 2012 12:20:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
Message-Id: <20120104122025.b0890e7e.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1201031900140.1378@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
	<alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
	<20111229145548.e34cb2f3.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
	<4EFD04B2.7050407@gmail.com>
	<alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
	<20111229195917.13f15974.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1112312302010.18500@eggly.anvils>
	<20120103151236.893d2460.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1201031900140.1378@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Tue, 3 Jan 2012 19:22:42 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> > > > 
> > > > Now, a way out here is to remove lumpy reclaim (please).  And make the
> > > > problem not come back by promising to never call putback_lru_pages(lots
> > > > of pages) (how do we do this?).
> > > 
> > > We can very easily put a counter in it, doing a spin_unlock_irq every
> > > time we hit the max.  Nothing prevents that, it's just an excrescence
> > > I'd have preferred to omit and have not today implemented.
> > 
> > Yes.  It's ultra-cautious, but perhaps we should do this at least until
> > lumpy goes away.
> 
> I don't think you'll accept my observations above as excuse to do
> nothing, but please clarify which you think is more cautious.  Should
> I or should I not break up the isolating end in the same way as the
> putting back?

If we already have the latency problem at the isolate_lru_pages() stage
then I suppose we can assume that nobody is noticing it, so we'll
probably be OK.

For a while.  Someone will complain at some stage and we'll probably
end up busting this work into chunks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
