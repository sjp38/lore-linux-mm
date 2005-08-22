Date: Mon, 22 Aug 2005 08:24:50 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use deltas to replace atomic inc
In-Reply-To: <Pine.LNX.4.61.0508221508410.18930@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508220823150.6260@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
 <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
 <20050820005843.21ba4d9b.akpm@osdl.org> <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org>
 <Pine.LNX.4.62.0508212102240.2290@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212112260.3317@g5.osdl.org>
 <Pine.LNX.4.62.0508220617030.4675@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0508221508410.18930@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Aug 2005, Hugh Dickins wrote:

> (Your deltas seem sensible, but hard to place the reaccumulation:
> I worry that you may be taking page_table_lock more just for that.)

The page_table_lock is taken using a spin_trylock. Its skipped if 
contended.

> Just to say, please do remove the anon_rss incrementation from inside
> page_add_anon_rmap if it helps you: I put it there as a lazy way of
> avoiding a bigger patch, but it would be much nicer to count separate
> file_rss and anon_rss, with /proc showing the sum of the two as rss.

Hmm. Thats a big projects. Lets first focus on getting the deltas right.

> Especially since it's anonymous that most concerns you: the present
> setup is biased against anonymous since it's counted in two fields -
> perhaps no issue once you've rearranged, but not good for atomics.

There will be no atomics once the deltas are in.
 
> If you don't get there first, I do intend in due course to replace
> rss and anon_rss by file_rss and anon_rss (and try to sort out the
> the tlb mmu gathering stuff, which is a little odd, in dealing with
> rss but not with anon_rss).

That will be great.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
