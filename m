Date: Fri, 2 Mar 2007 16:58:57 +0000
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302165857.GB14379@skynet.ie>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (01/03/07 16:44), Linus Torvalds didst pronounce:
> 
> 
> On Thu, 1 Mar 2007, Andrew Morton wrote:
> > 
> > So some urgent questions are: how are we going to do mem hotunplug and
> > per-container RSS?
> 
> Also: how are we going to do this in virtualized environments? Usually the 
> people who care abotu memory hotunplug are exactly the same people who 
> also care (or claim to care, or _will_ care) about virtualization.
> 

I sent a mail out with a fairly detailed treatment of how RSS could be done.
Essentially, I feel that containers should simply limit the number of
pages used by the container, and not try and do anything magic with a
poorly defined concept like RSS. It would do this by creating a
"software zone" and taking pages from a "hardware zone" at creation
time. It has a similar affect to RSS limits except it's better defined.

In that setup, a virtualized environment would create it's own software
zone. It would hand that over to the guest OS and the guest OS could do
whatever it liked. It would be responsible for it's own reclaim and so on
and not have to worry about other containers (or virtualized environments
for that matter) or kswapd interfering with it.

> My personal opinion is that while I'm not a huge fan of virtualization, 
> these kinds of things really _can_ be handled more cleanly at that layer, 
> and not in the kernel at all. Afaik, it's what IBM already does, and has 
> been doing for a while. There's no shame in looking at what already works, 
> especially if it's simpler.
> 
> 		Linus

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
