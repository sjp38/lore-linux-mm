Date: Fri, 26 Oct 2007 10:50:43 +0100
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
Message-ID: <20071026095043.GA14347@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com> <1193331162.4039.141.camel@localhost> <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com> <1193332528.4039.156.camel@localhost> <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com> <20071025180514.GB20345@skynet.ie> <1193335935.24087.22.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193335935.24087.22.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (25/10/07 11:12), Dave Hansen didst pronounce:
> On Thu, 2007-10-25 at 19:05 +0100, Mel Gorman wrote:
> > I think Dave has a point so I would be happy with a boolean. We don't really
> > care what the type is, we care about if it can be removed or not.
> > 
> > It also occurs to me from the "can we remove it perspective" that you may
> > also want to check if the pageblock is entirely free or not. You can encounter
> > a pageblock that is "Unmovable" but entirely free so it could be removed. 
> 
> The other option is to make it somewhat of a "removability score".  If
> it has non-relocatable pages, then it gets a crappy score.  If it is
> relocatable, give it more points.  If it has more free pages, give it
> even more.  If the pages contain images of puppies, take points away.
> 
> That way, if something in userspace says, "we need to give memory back",
> it can go find the _best_ section from which to give it.
> 
> But, maybe I'm just over-enginnering now. ;)
> 

I think that's overkill, especially as any awkward page would give the
section a score of 0.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
