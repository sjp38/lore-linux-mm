Date: Tue, 10 Jul 2001 01:53:29 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.21.0107091740360.1402-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33.0107100146100.5611-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2001, Hugh Dickins wrote:

> I doubt loop unrolling will make much difference.  Mark Hemment tells me
> that lmbench makes very widely spaced accesses in its mmap() tests, so is
> liable to show up the latency from the larger reads.

Err, the difference is that unrolling those loops should allow them to run
with decreased latency as the current code will suffer from a number of
mispredictions.

> (In looking at your do_no_page() code briefly then, I notice addr_min
> and addr_max are first set up with page-table-limits, then immediately
> overwritten with vma-limits - I think you meant to take max and min.)

Not quite -- I just forgot to remove the first two as they're not needed
since everything operates on powers of two.

> I'm interested you're having trouble with the anonymous->swap pages,
> they're one of the reasons I went the large PAGE_SIZE instead of the
> large PAGE_CACHE_SIZE route.  I think there's a lot in my mm/memory.c
> mods which you could apply in yours, so even anonymous pages could use
> PAGE_CACHE_SIZE pages efficiently.

I'm not having trouble with it, I'm just uninterested in implementing it
since it has no effect on the performance measurements.  Namely, if there
is no change in performance, then there is little reason to waste time on
fixing swapping.

> I agree that our approaches are complementary, with a large overlap.
> Shall we aim towards one patch combining configurable PAGE_CACHE_SIZE
> and configurable PAGE_SIZE?  and later discard one or the other if
> it proves redundant.

Sure.  It doesn't look like much work to add in large page support, so let
me know one way or the other.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
