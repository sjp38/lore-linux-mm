Date: Fri, 29 Feb 2008 14:32:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] Remember what the preferred zone is for zone_statistics
Message-ID: <20080229143254.GC6045@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214728.6858.79000.sendpatchset@localhost> <20080229113016.346f9cc5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080229113016.346f9cc5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (29/02/08 11:30), KAMEZAWA Hiroyuki didst pronounce:
> On Wed, 27 Feb 2008 16:47:28 -0500
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > From: Mel Gorman <mel@csn.ul.ie>
> > [PATCH 3/6] Remember what the preferred zone is for zone_statistics
> > 
> > V11r3 against 2.6.25-rc2-mm1
> > 
> > On NUMA, zone_statistics() is used to record events like numa hit, miss
> > and foreign. It assumes that the first zone in a zonelist is the preferred
> > zone. When multiple zonelists are replaced by one that is filtered, this
> > is no longer the case.
> > 
> > This patch records what the preferred zone is rather than assuming the
> > first zone in the zonelist is it. This simplifies the reading of later
> > patches in this set.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> 
> I have no objection to the direction but
> 
> 
> > +static struct page *buffered_rmqueue(struct zone *preferred_zone,
> >  			struct zone *zone, int order, gfp_t gfp_flags)
> >  {
> 
> Can't this be written like this ?
> 
> struct page *
> buffered_rmqueue(struct zone *zone, int order, gfp_t gfp_flags, bool numa_hit)
> 
> Can't caller itself  set this bool value ?
> 

Going that direction, the caller could call zone_statistics() instead of
buffered_rmqueue() and it would be one less parameter to pass. However,
as buffered_rmqueue() is probably inlined, I'm not sure a change would
be beneficial.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
