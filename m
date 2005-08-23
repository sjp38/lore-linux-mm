Date: Tue, 23 Aug 2005 14:06:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
In-Reply-To: <430B0662.3060509@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0508231333330.7718@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
 <430A6D08.1080707@yahoo.com.au> <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com>
 <430B0662.3060509@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Nick Piggin wrote:
> 
> Which brings up another issue - this surely conflicts rather
> badly with PageReserved removal :( Not that there is anything
> wrong with that, but I don't like to create these kinds of
> problems for people...

Conflicts in the sense that I'm messing all over source files which
removing PageReserved touches?

Or in some deeper sense, that it makes the whole project of removing
PageReserved more difficult (I don't see how)?

> Do we still want to remove PageReserved sooner rather than
> later?

I'd say remove PageReserved sooner;
or at least your "remove it from the core" subset.

I'll work around whatever goes into each -mm as it happens
(though I won't necessarily post rebased patches).

The main conflict is with the page-fault-patches already in -mm.

What I'd like, if testing results suggest my approach worthwhile,
is that we slip it into -mm underneath Christoph's i.e. rework his
to sit on top - mine should reduce his somewhat.  Perhaps move his
out temporarily and evaluate whether to bring back in, again
dependent on testing results.  Logically (but not chronologically),
at least the narrowing of the page table lock would be a natural
precursor to the anonymous fault xchging, rather than a sequel.

But that's for Andrew and Linus and community to decide.

I'll submit silly little offcuts quite soon, but am not expecting
to submit the bulk of the work for a little while (intentionally
vague term!) - though once the arches are settled, if people are
happy with the direction, I've no reason to delay.

One of the tidyups I would like to send fairly soon, which will
cause some nuisance, would be "aligning" the arguments of the
different do_...._page fault handlers (I haven't looked, but I'd
hope at least some versions of the compiler can make less code
in handle_pte_fault if they all share the same order).

(Actually I'd love to move those and associcated functions out into
their own mm/fault.c: it'd be helpful to group them together, and
mm/memory.c too large.  But let's choose a quieter time to do that.)

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
