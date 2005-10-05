Date: Wed, 5 Oct 2005 17:57:03 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/7] Fragmentation Avoidance V16: 003_fragcore
In-Reply-To: <1128530908.26009.28.camel@localhost>
Message-ID: <Pine.LNX.4.58.0510051749510.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
 <20051005144602.11796.53850.sendpatchset@skynet.csn.ul.ie>
 <1128530908.26009.28.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Oct 2005, Dave Hansen wrote:

> On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> >
> > @@ -1483,8 +1540,10 @@ void show_free_areas(void)
> >
> >                 spin_lock_irqsave(&zone->lock, flags);
> >                 for (order = 0; order < MAX_ORDER; order++) {
> > -                       nr = zone->free_area[order].nr_free;
> > -                       total += nr << order;
> > +                       for (type=0; type < RCLM_TYPES; type++) {
> > +                               nr = zone->free_area_lists[type][order].nr_free;
> > +                               total += nr << order;
> > +                       }
>
> Can that use the new for_each_ macro?
>

Yes, yes it can. Not sure why I dismissed it the first time around.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
