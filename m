Date: Fri, 26 Oct 2007 17:14:06 +0100
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
Message-ID: <20071026161406.GB19443@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com> <1193331162.4039.141.camel@localhost> <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com> <1193332528.4039.156.camel@localhost> <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com> <20071025180514.GB20345@skynet.ie> <1193335935.24087.22.camel@localhost> <20071026095043.GA14347@skynet.ie> <1193413936.24087.91.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193413936.24087.91.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (26/10/07 08:52), Dave Hansen didst pronounce:
> On Fri, 2007-10-26 at 10:50 +0100, Mel Gorman wrote:
> > I think that's overkill, especially as any awkward page would give the
> > section a score of 0. 
> 
> But, if we have a choice, shouldn't we go for a section that is
> completely free instead of one that has pages that need some kind of
> reclaim first?
> 

I would think that if memory is being shrunk in the system, the monitoring
software would not particularly care. If you think that might be the case,
then rename mem_removable to mem_removable_score and have it print out 0 or
1 for the moment based on the current criteria. Tell userspace developers
that the higher the score, the more suitable it is for removing.  That will
allow the introduction of a proper scoring mechanism later if there is a
good reason for it without breaking backwards compatability.

> We also don't have to have awkward pages keep giving a 0 score, as long
> as we have _some_ way of reclaiming them.  If we can't reclaim them,
> then I think it *needs* to be 0.
> 
> -- Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
