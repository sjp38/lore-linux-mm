Date: Wed, 2 May 2007 12:42:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <20070502121105.de3433d5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705021234470.1543@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <20070501133618.93793687.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com>
 <20070502121105.de3433d5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Andrew Morton wrote:

> > At some point I dream that SLUB could become the default but I thought 
> > this would take at least 6 month or so. If want to force this now then I 
> > will certainly have some busy weeks ahead.
> 
> s/dream/promise/ ;)
> 
> Six months sounds reasonable - I was kind of hoping for less.  Make it
> default-to-on in 2.6.23-rc1, see how it goes.

Here is how I think the future could develop

Cycle	SLAB		SLUB		SLOB		SLxB

2.6.22	API fixes	Stabilization	API fixes

Major event: SLUB availability as experimental

2.6.23	API upgrades	Perf. Valid.	EOL

Major events: SLUB performance validation. Switch off
	experimental (could even be the default) 
	Slab allocators support targeted reclaim for at
	least one slab cache (dentry?)
	(vacate/move all objects in a slab)

2.6.24	Earliest EOL	Stable		- 		Experiments

Major events: SLUB stable. Stable targeted reclaim
		for all major reclaimable slabs.
		Maybe experiments with another new allocator?

2.6.25	EOL		default		-		?

Death of SLAB. SLUB default. Hopefully new ideas on the horizon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
