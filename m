Received: from atlas.CARNet.hr (root@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA15165
	for <linux-mm@kvack.org>; Thu, 12 Nov 1998 18:12:34 -0500
Subject: Re: unexpected paging during large file reads in 2.1.127
References: <Pine.LNX.3.96.981112143712.20473B-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 12 Nov 1998 23:45:42 +0100
In-Reply-To: Rik van Riel's message of "Thu, 12 Nov 1998 14:39:53 +0100 (CET)"
Message-ID: <87k910bkdl.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On 12 Nov 1998, Zlatko Calusic wrote:
> > "David J. Fred" <djf@ic.net> writes:
> > 
> > > Summary: When doing large file reads from disk the system pages
> > >          unexpectedly causing moderate to severe degradation in I/O
> > >          and overall system performance even though there is plenty of
> > >          memory.
> > 
> > Page cache is definitely too aggressive on recent kernels. I
> > developed a small patch that avoids excessive swapouts. It helps
> > kswapd to have less trouble reusing pages from page cache. 
> 
> Agreed, we should do something about that.
> 
> > +			age_page(page);
> > +			age_page(page);
> >  			age_page(page);
> 
> Do I hear "priority paging"? :))
> 
> >        count_max = (limit<<2) >> (priority>>1);
> >        count_min = (limit<<2) >> (priority);
> 
> Maybe increasing these has the same effect but with
> the advantage of keeping page aging intact.
> 

Maybe, but then again maybe not.

I have a feeling that change like that could easily make kswapd a CPU
pig.

We are aging pages, so that they don't get reaped easily, and then
trying to compensate that with heavier scanning. Doesn't sound like a
good idea. Sizif's job.

But still, looks interesting, so I'm just going to compile one test
kernel with bigger count limits, for the fun's sake... :)

[Cc: Linux-MM]

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	  A chicken is an egg's way of producing more eggs.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
