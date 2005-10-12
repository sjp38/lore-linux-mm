Date: Wed, 12 Oct 2005 13:19:37 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lhms-devel] [PATCH 8/8] Fragmentation Avoidance V17: 008_stats
In-Reply-To: <1129118247.6134.54.camel@localhost>
Message-ID: <Pine.LNX.4.58.0510121318390.25855@skynet>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
 <20051011151302.16178.46089.sendpatchset@skynet.csn.ul.ie>
 <1129118247.6134.54.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, jschopp@austin.ibm.com, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Oct 2005, Dave Hansen wrote:

> On Tue, 2005-10-11 at 16:13 +0100, Mel Gorman wrote:
> > +#ifdef CONFIG_ALLOCSTAT
> > +               memset((unsigned long *)zone->fallback_count, 0,
> > +                               sizeof(zone->fallback_count));
> > +               memset((unsigned long *)zone->alloc_count, 0,
> > +                               sizeof(zone->alloc_count));
> > +               memset((unsigned long *)zone->alloc_count, 0,
> > +                               sizeof(zone->alloc_count));
> > +               zone->kernnorclm_partial_steal=0;
> > +               zone->kernnorclm_full_steal=0;
> > +               zone->reserve_count[RCLM_NORCLM] =
> > +                               realsize >> (MAX_ORDER-1);
> > +#endif
>
> The struct zone is part of the pgdat which is zeroed at boot-time on all
> architectures and configuration that I have ever audited.  Re-zeroing
> parts of it here is unnecessary.
>
> BTW, that '=0' with no spaces is anti-CodingStyle.
>

Blast, true. However, the whole block of code can be simply removed which
I prefer. I didn't like the #ifdef in the middle of the function.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
