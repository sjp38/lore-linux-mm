Date: Tue, 14 Dec 2004 13:48:49 -0600
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
In-Reply-To: <20041214191348.GA27225@wotan.suse.de>
Message-ID: <Pine.SGI.4.61.0412141333500.22462@kzerza.americas.sgi.com>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
 <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Erik Jacobson <erikj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2004, Andi Kleen wrote:

> I originally was a bit worried about the TLB usage, but it doesn't
> seem to be a too big issue (hopefully the benchmarks weren't too
> micro though)

I had the same thought about TLB usage.  I would have liked a way
to map larger sections of memory with each TLB.  For example,
if we were going to allocate 128 pages on a 32 node system, it
would be nice to do 32 4 page allocations rather than 128 1 page
allocations.  But I didn't see any suitable infrastructure in
vmalloc or elsewhere to make that easily possible, so I didn't
pursue it.

As far as benchmarks -- I was happy just to find a suitable TCP
benchmark, though I share some of the same concern.  Other than
the netperf TCP_CC and TCP_CRR I couldn't find anything that seemed
like it might be a good test and could be set up with the resources
at hand (i.e. I don't have a large cluster to pound on a web server
benchmark).  That said, if someone does find an unresolvable problem
with the TCP portion (3/3) of the patch, I hope 1/3 and 2/3 are still
worthy of consideration.

> I talked about it, but never implemented it. I am not aware of any
> other implementation of this before Brent's.

To give credit where it's due, Erik Jacobson, also at SGI, proposed
pretty much the same idea on 2003-11-12 in "available memory imbalance
on large NUMA systems".  Andrew responded to that patch in a generally
favorable manner, though asked whether we needed closer scrutinization
of whether hashes were being sized appropriately on large systems
(something that could still use further examination, BTW, particularly
for the TCP ehash).  I used Erik's patch to identify the particular
hashes I needed to tackle in this set.

Thanks,
Brent

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
