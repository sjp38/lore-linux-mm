Date: Wed, 5 May 2004 17:09:45 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.6-rc3-mm1
In-Reply-To: <20040505161416.A4008@infradead.org>
Message-ID: <Pine.LNX.4.44.0405051653010.2328-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, Rajesh Venkatasubramanian <vrajesh@umich.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 May 2004, Christoph Hellwig wrote:
> On Fri, Apr 30, 2004 at 01:46:58AM -0700, Andrew Morton wrote:
> > +rmap-14-i_shared_lock-fixes.patch
> > +rmap-15-vma_adjust.patch
> > +rmap-16-pretend-prio_tree.patch
> > +rmap-17-real-prio_tree.patch
> > +rmap-18-i_mmap_nonlinear.patch
> > +rmap-19-arch-prio_tree.patch
> > 
> >  More VM work from Hugh

Of course, all the hard work here is actually from Rajesh.

> That's about 600 lines of additional code.  And that prio tree code is
> used a lot, so even worse for that caches.

Fair concern.  It has been discussed offlist, and you're certainly not
the only one to feel that way.  I'm neutral, just making the patches
available.  Even Rajesh is firmly of the opinion that it has to be
thrown out if it doesn't pay off.

> Do we have some benchmarks of real-life situation where the prio trees
> show a big enough improvement or some 'exploits' where the linear list
> walking leads to DoS situtations?

Andrew and Ingo wrote "exploits", though whether they amount to DoS
I'm not convinced.  We do feel vulnerable to corner cases, and more
secure with Rajesh's work in place.  But I don't believe anyone has
shown a _real-life_ case for it yet - nor a case against it either.
Rajesh has certainly shown its value in the corner cases.

> The bases objrmap/anonrmap changes keep the LOC pretty much the same as
> the old pte-chain based code, but this is really a whole lot of code bloating
> up the kernel and I'd prefer to see some numbers before it's going in..

I'm hoping someone (at OSDL?) will do those numbers: probably easiest
once the basic objrmap+anonrmap has gone into 2.6.7-pre, then that can
be compared against the same with the prio_tree patches added (and fair
to include Rajesh's latest work, the prefetching, in any such testing).

I don't place a lot of faith in numbers coming from me!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
