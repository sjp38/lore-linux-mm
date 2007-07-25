Subject: Re: NUMA policy issues with ZONE_MOVABLE
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070725111646.GA9098@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 10:30:23 -0400
Message-Id: <1185373824.5604.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 12:16 +0100, Mel Gorman wrote:
> On (24/07/07 21:20), Christoph Lameter didst pronounce:
> > The outcome of the 2.6.23 merge was surprising. No antifrag but only 
> > ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.
> > 
> > For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated
> > 
> > 1. It is the highest zone.
> > 
> > 2. Thus policy_zone == ZONE_MOVABLE
> > 
> > ZONE_MOVABLE contains only movable allocs by default. That is anonymous 
> > pages and page cache pages?
> > 
> > The NUMA layer only supports NUMA policies for the highest zone. 
> > Thus NUMA policies can control anonymous pages and the page cache pages 
> > allocated from ZONE_MOVABLE. 
> > 
> > However, NUMA policies will no longer affect non pagecache and non 
> > anonymous allocations. So policies can no longer redirect slab allocations 
> > and huge page allocations (unless huge page allocations are moved to 
> > ZONE_MOVABLE). And there are likely other allocations that are not 
> > movable.
> > 
> > If ZONE_MOVABLE is off then things should be working as normal.
> > 
> > Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?
> >  
> 
> No but it has to be dealt with. I would have preferred this was highlighted
> earlier but there is a candidate fix below.  It appears to be the minimum
> solution to allow policies to work as they do today but remaining compatible
> with ZONE_MOVABLE. It works by
> 
> o check_highest_zone will be the highest populated zone that is not ZONE_MOVEABLE

Ah, sick minds think alike...  ;-)

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
