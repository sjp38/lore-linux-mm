Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBB76B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 08:57:18 -0500 (EST)
Date: Fri, 23 Jan 2009 13:57:00 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090123035503.GD20098@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901231335080.9011@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de> <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
 <20090123035503.GD20098@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jan 2009, Nick Piggin wrote:
> On Wed, Jan 21, 2009 at 06:10:12PM +0000, Hugh Dickins wrote:
> > 
> > That's been making SLUB behave pretty badly (e.g. elapsed time 30%
> > more than SLAB) with swapping loads on most of my machines.  Though
> > oddly one seems immune, and another takes four times as long: guess
> > it depends on how close to thrashing, but probably more to investigate
> > there.  I think my original SLUB versus SLAB comparisons were done on
> > the immune one: as I remember, SLUB and SLAB were equivalent on those
> > loads when SLUB came in, but even with boot option slub_max_order=1,
> > SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> > FWIW - swapping loads are not what anybody should tune for.
> 
> Yeah, that's to be expected with higher order allocations I think. Does
> your immune machine simply have fewer CPUs and thus doesn't use such
> high order allocations?

No, it's just one of the quads.  Whereas the worst affected (laptop)
is a duo.  I should probably be worrying more about that one: it may
be that I'm thrashing it and its results are meaningless, though still
curious that slab and slqb and slob all do so markedly better on it.

It's behaving much better with slub_max_order=1 slub_min_objects=4,
but to get competitive I've had to switch off most of the debugging
options I usually have on that one - and I've not yet tried slab,
slqb and slob with those off too.  Hmm, it looks like its getting
progressively slower.

I'll continue to investigate at leisure,
but can't give it too much attention.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
