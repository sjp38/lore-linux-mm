Date: Thu, 25 Oct 2007 11:10:24 +0100
Subject: Re: [RFC][PATCH 0/2] Export memblock migrate type to /sysfs
Message-ID: <20071025101024.GA30732@skynet.ie>
References: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com> <20071025093531.d2357422.kamezawa.hiroyu@jp.fujitsu.com> <472020C8.4090007@us.ibm.com> <20071025162118.bb24aa4b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071025162118.bb24aa4b.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Badari <pbadari@us.ibm.com>, melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (25/10/07 16:21), KAMEZAWA Hiroyuki didst pronounce:
> On Wed, 24 Oct 2007 21:51:20 -0700
> Badari <pbadari@us.ibm.com> wrote:
> > > How about showing information as following ?
> > > ==
> > > %cat ./memory/memory0/mem_type
> > >  1 0 0 0 0
> > > %
> > > as 
> > >  Reserved Unmovable Movable Reserve Isolate
> > >
> > >   
> > Personally, I have no problem. But its against the rules of /sysfs - 
> > "one value per file" rule :(
> > I would say, lets keep it simple for now and extend it if needed.
> > 
> Hmm, but misleading information is not good.
> 
> How about adding "Mixed" status for memory section which containes multiple
> page types ? For memory hotplug, it's enough.
> 

"Mixed" to me implies that the section doesn't contain exclusively pages
of that type. It never happens in ZONE_MOVABLE of course, but it can happen
elsewhere due to fragmentation. "Multiple" I'd be happy with. So if we saw
"Movable", it's movable blocks only in that section but "Multiple" means
that there are more than one pageblock type in that section.

At some time in the future, Movable-mixed would imply that this is a
Movable section but memory pressure forced non-movable pages in there.
Again, would never happen in ZONE_MOVABLE.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
