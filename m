Message-ID: <466E06CA.9030302@yahoo.com.au>
Date: Tue, 12 Jun 2007 12:36:58 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <20070608145011.GE11115@waste.org>
In-Reply-To: <20070608145011.GE11115@waste.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
> On Fri, Jun 08, 2007 at 12:25:05PM +0900, Paul Mundt wrote:
> 
>>Well, this doesn't all have to be dynamic either. I opted for the
>>mpolinit= approach first so we wouldn't make the accounting for the
>>common case heavier, but certainly having it dynamic is less hassle. The
>>asymmetric case will likely be the common case for embedded, but it's
>>obviously possible to try to work that in to SLOB or something similar,
>>if making SLUB or SLAB lighterweight and more tunable for these cases
>>ends up being a real barrier.
>>
>>On the other hand, as we start having machines with multiple gigs of RAM
>>that are stashed in node 0 (with many smaller memories in other nodes),
>>SLOB isn't going to be a long-term option either.
> 
> 
> SLOB in -mm should scale to this size reasonably well now, and Nick
> and I have another tweak planned that should make it quite fast here.

Indeed. The existing code in -mm should hopefully get merged next cycle,
so if you have ever wanted to use SLOB but had performance problems, please
reevaluate and report if you still hit problems.

Even on small SMPs, it might be a reasonable choice, although it won't be
able to match the other allocators for performance. Again, if you have
problems with SMP scalability of SLOB, then please let us know too, because
as Matt said there are a few things we could do (such as multiple freelists)
which may improve performance quite a bit without hurting complexity or
memory usage much.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
