Date: Wed, 23 May 2007 10:03:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523071200.GB9449@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
References: <20070523045938.GA29045@wotan.suse.de>
 <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com>
 <20070523071200.GB9449@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> On Tue, May 22, 2007 at 11:28:18PM -0700, Christoph Lameter wrote:
> > On Wed, 23 May 2007, Nick Piggin wrote:
> > 
> > > If you want to do a memory consumption shootout with SLOB, you need
> > > all the help you can get ;)
> > 
> > No way. And first you'd have to make SLOB functional. Among other 
> > things it does not support slab reclaim.
> 
> What do you mean by slab reclaim? SLOB doesn't have slabs and it
> never keeps around unused pages so I can't see how it would be able
> to do anything more useful. SLOB is fully functional here, on my 4GB
> desktop system, even.

SLOB does not f.e. handle the SLAB ZVCs. The VM will think there is no 
slab use and never shrink the slabs.
 
> The numbers indicate that SLUB would be the one which is not functional
> in a tiny memory constrained environment ;)

Well, apart from the red herring: That is likely an issue of properly 
configuring the system and slowing down the allocator by not keeping
too much memory in its queues. If we do not consider the code size issues: 
How much memory are we talking about?

What is the page size? We likely have one potentially empty cpu slab
for each of the 50 or so slabs used during boot. This is already 200k 
given a 4K page size. That could be released by shrinking and if you just 
run bash the most of them are not going to be used anyways.
 
> > Hmm.... Can I see the .config please?
> 
> Here is the one I used for SLOB (SLUB is otherwise the same, and
> without SLOB_DEBUG). BTW, the system booted fine with SLUB and the
> fix you sent.

Looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
