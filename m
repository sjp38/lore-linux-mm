Date: Thu, 24 May 2007 05:39:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524033925.GD14349@wotan.suse.de>
References: <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com> <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com> <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 12:59:05PM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Matt Mackall wrote:
> 
> >  748K SLUB
> > 1068K SLOB    (old SLOB saves 320K)
> > 1140K SLOB++  (Nick's improvements save an additional 72K for 392K total)
> > 
> > (It'd be nice to have a SLAB number in there for completeness.)
> > 
> > Nick's patches also make SLOB reasonably performant on larger machines
> > (and can be a bit faster with a little tweaking). But it'll never be
> > as fast as SLAB or SLUB - it has to walk lists. Similarly, I think
> > it's basically impossible for a SLAB-like system that segregates
> > objects of different sizes onto different pages to compete with a
> > linked-list allocator on size. Especially now that Nick's reduced the
> > kmalloc overhead to 2 bytes!
> > 
> > So as long as there are machines where 100K or so makes a difference,
> > there'll be a use for a SLOB-like allocator.
> 
> Hummm... We have not tested with my patch yet. May save another 200k.

Saved 12K. Shuld it have been more? I only applied the last patch you
sent (plus the initial SLUB_DEBUG fix).

 
> And also the situation that Nick created is a bit artificial. One should 
> at least have half the memory available for user space I would think. If 
> there is a small difference after bootup then its not worth to keep SLOB 
> around.

Admittedly, I am not involved with any such tiny Linux projects, however
why should half of memory be available to userspace? What about a router
or firewall that basically does all work in kernel?

I think a really stripped down system can boot in 2MB of RAM these days,
so after the kernel actually boots, a few K probably == a few % of
remaining available memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
