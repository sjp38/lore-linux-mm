Date: Wed, 24 Sep 2008 18:10:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080924171003.GD10837@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080923194655.GA25542@csn.ul.ie> <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080924154120.GA10837@csn.ul.ie> <1222272395.15523.3.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1222272395.15523.3.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, agl@us.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/09/08 09:06), Dave Hansen didst pronounce:
> On Wed, 2008-09-24 at 16:41 +0100, Mel Gorman wrote:
> > I admit it's ppc64-specific. In the latest patch series, I made this a
> > separate patch so that it could be readily dropped again for this reason.
> > Maybe an alternative would be to display MMUPageSize *only* where it differs
> > from KernelPageSize. Would that be better or similarly confusing?
> 
> I would also think that any arch implementing fallback from large to
> small pages in a hugetlbfs area (Adam needs to post his patches :) would
> also use this.
> 

Fair point. Maybe the thing to do is backburner this patch for the moment and
reintroduce it when/if an architecture supports demotion? The KernelPageSize
reporting in smaps and what the hpagesize in maps is still useful though
I believe. Any comment?

(future stuff from here on)

In the future if demotion does happen then the MMUPageSize information may
be genuinely useful instead of just a curious oddity on ppc64. As you point
out, Adam (added to cc) has worked on this area (starting with x86 demotion)
in the past but it's a while before it'll be considered for merging I believe.

That aside, more would need to be done with the page size reporting then
anyway. For example, it maybe indicate how much of each pagesize is in a VMA
or indicate that KernelPageSize is what is being requested but in reality
it is mixed like;

KernelPageSize:		2048 kB (mixed)

or

KernelPageSize:		2048 kB * 5, 4096 kB * 20


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
