Date: Fri, 2 Mar 2007 17:09:50 +0000
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302170950.GD14379@skynet.ie>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <45E842F6.5010105@redhat.com> <20070302085838.bcf9099e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070302085838.bcf9099e.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (02/03/07 08:58), Andrew Morton didst pronounce:
> On Fri, 02 Mar 2007 10:29:58 -0500 Rik van Riel <riel@redhat.com> wrote:
> 
> > Andrew Morton wrote:
> > 
> > > And I'd judge that per-container RSS limits are of considerably more value
> > > than antifrag (in fact per-container RSS might be a superset of antifrag,
> > > in the sense that per-container RSS and containers could be abused to fix
> > > the i-cant-get-any-hugepages problem, dunno).
> > 
> > The RSS bits really worry me, since it looks like they could
> > exacerbate the scalability problems that we are already running
> > into on very large memory systems.
> 
> Using a zone-per-container or N-64MB-zones-per-container should actually
> move us in the direction of *fixing* any such problems.  Because, to a
> first-order, the scanning of such a zone has the same behaviour as a 64MB
> machine.
> 

Quite possibly. Taking software zones from the other large mail I sent,
one could get the 64MB effect by increasing MAX_ORDER_NR_PAGES to be 64MB
in pages. To avoid external fragmentation issues, I'd prefer of course
if these container zones consisted of mainly contiguous memory but with
anti-fragmentation, that would be possible.

> (We'd run into a few other problems, some related to the globalness of the
> dirty-memory management, but that's fixable).
> 

It would be fixable, especially if containers do their own reclaim on their
container zones and not kswapd. Writing dirty data back periodically would
still need to be global in nature but that's no different to today.

> > Linux is *not* happy on 256GB systems.  Even on some 32GB systems
> > the swappiness setting *needs* to be tweaked before Linux will even
> > run in a reasonable way.
> 
> Please send testcases.

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
