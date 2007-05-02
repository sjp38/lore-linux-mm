Date: Wed, 2 May 2007 21:54:12 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-ID: <20070502195412.GC9044@uranus.ravnborg.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com> <20070501125559.9ab42896.akpm@linux-foundation.org> <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com> <20070501133618.93793687.akpm@linux-foundation.org> <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com> <Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com> <20070502121105.de3433d5.akpm@linux-foundation.org> <Pine.LNX.4.64.0705021234470.1543@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705021234470.1543@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2007 at 12:42:54PM -0700, Christoph Lameter wrote:
> On Wed, 2 May 2007, Andrew Morton wrote:
> 
> > > At some point I dream that SLUB could become the default but I thought 
> > > this would take at least 6 month or so. If want to force this now then I 
> > > will certainly have some busy weeks ahead.
> > 
> > s/dream/promise/ ;)
> > 
> > Six months sounds reasonable - I was kind of hoping for less.  Make it
> > default-to-on in 2.6.23-rc1, see how it goes.
> 
> Here is how I think the future could develop
> 
> Cycle	SLAB		SLUB		SLOB		SLxB
> 
> 2.6.22	API fixes	Stabilization	API fixes
> 
> Major event: SLUB availability as experimental
> 
> 2.6.23	API upgrades	Perf. Valid.	EOL
> 
> Major events: SLUB performance validation. Switch off
> 	experimental (could even be the default) 
> 	Slab allocators support targeted reclaim for at
> 	least one slab cache (dentry?)
> 	(vacate/move all objects in a slab)

To facilitate this do NOT introduce CONFIG_SLAB until we decide
that SLUB are default. In this way we can make CONFIG_SLUB be default
and people will not continue with CONFIG_SLAB because they had it in their
.config already.
Or just rename CONFIG_SLAB to CONFIG_SLAB_DEPRECATED or something.

The point is make sure that LSUB becomes default for people that does
an make oldconfig (explicit or implicit).

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
