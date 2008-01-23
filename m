Date: Wed, 23 Jan 2008 14:15:01 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86 II
Message-ID: <20080123141500.GB14175@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <200801231215.56741.andi@firstfloor.org> <20080123112436.GF21455@csn.ul.ie> <200801231448.09514.andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200801231448.09514.andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (23/01/08 14:48), Andi Kleen didst pronounce:
> On Wednesday 23 January 2008 12:24:36 Mel Gorman wrote:
> > On (23/01/08 12:15), Andi Kleen didst pronounce:
> > > Anyways from your earlier comments it sounds like you're trying to add
> > > SRAT parsing to CONFIG_NUMAQ. Since that's redundant with the old
> > > implementation it doesn't sound like a very useful thing to do.
> >
> > No, that would not be useful at all as it's redundant as you point out. The
> > only reason to add it is if the Opteron box can figure out the CPU-to-node
> > affinity. 
> 
> Assuming srat_32.c was fixed to not crash on Opteron it would likely
> do that already without further changes.
> 

Understood.

> > :| The patches applied so far are about increasing test coverage, not SRAT
> > messing. 
> 
> Test coverage of the NUMAQ kernel?
> 

NUMA in general. I don't really care about NUMAQ as such except that it
continues to shake out the occasional bug that can be difficult to reproduce
elsewhere.

> If you wanted to increase test coverage of 32bit NUMA kernels the right
> strategy would be to fix srat_32.
> 

I will try and do that then instead of trying to merge the SRAT parsers.
Based on this thread, my understanding is that an attempted merge would only
open up a can of hurt, probably causing regressions in the process.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
