Date: Thu, 24 May 2007 06:39:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524043928.GC12121@wotan.suse.de>
References: <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com> <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com> <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com> <20070524041339.GC20252@wotan.suse.de> <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com> <20070524043144.GB12121@wotan.suse.de> <Pine.LNX.4.64.0705232133130.24738@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705232133130.24738@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 09:35:52PM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Nick Piggin wrote:
> 
> > I'll take an educated guess and say that SLUB would have more external
> > fragmentation which would be especially pronounced in small memory
> > setups. Also, that SLUB's kmalloc slabs would suffer from a lot more
> > internal fragmentation too, which could be equally significant if not
> > more (I think this would become relatively more significant than external
> > fregmentation as you increased memory size).
> 
> Hmmmm... Could be. The kmalloc array is potentially wasting a lot of 
> memory. I added more smaller kmalloc array elements to SLUB to avoid that 
> but maybe that is not enough.

Don't forget that on small memory systems, this could actually be _worse_
because you might be increasing external fragmentation (ie. if there are
only few kmallocs in each slab).

So it might also be an idea to try reducing them as well.
 
> > If you don't think the test is very interesting, I could try any other
> > sort of test and with i386 or x86-64 if you like.
> 
> Let me try some tests on my own first. Just ran a SLOB baseline, should 
> have some numbers soon.

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
