Date: Sat, 23 Feb 2008 00:07:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/17] Slab Fragmentation Reduction V10
Message-Id: <20080223000722.a37983eb.akpm@linux-foundation.org>
In-Reply-To: <20080216004526.763643520@sgi.com>
References: <20080216004526.763643520@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008 16:45:26 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> Slab fragmentation is mainly an issue if Linux is used as a fileserver
> and large amounts of dentries, inodes and buffer heads accumulate. In some
> load situations the slabs become very sparsely populated so that a lot of
> memory is wasted by slabs that only contain one or a few objects. In
> extreme cases the performance of a machine will become sluggish since
> we are continually running reclaim. Slab defragmentation adds the
> capability to recover the memory that is wasted.

I'm somewhat reluctant to consider this because it is slub-only, and slub
doesn't appear to be doing so well on the performance front wrt slab.

We do need to make one of those implementations go away, and if it's slub
that goes, we have a lump of defrag code hanging around in core VFS which
isn't used by anything.

So I think the first thing we need to do is to establish that slub is
viable as our only slab allocator (ignoring slob here).  And if that means
tweaking the heck out of slub until it's competitive, we would be
duty-bound to ask "how fast will slab be if we do that much tweaking to
it as well".

Another basis for comparison is "which one uses the lowest-order
allocations to achieve its performance".

Of course, current performance isn't the only thing - it could be that slub
enables features such as defrag which wouldn't be possible with slab.  We
can discuss that.

But one of these implementations needs to go away, and that decision
shouldn't be driven by the fact that we happen to have already implemented
some additional features on top of one of them.

hm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
