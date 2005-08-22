Date: Mon, 22 Aug 2005 17:43:00 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Use deltas to replace atomic inc
Message-ID: <20050822154300.GA29976@wotan.suse.de>
References: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org> <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com> <20050820005843.21ba4d9b.akpm@osdl.org> <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org> <Pine.LNX.4.62.0508212102240.2290@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0508212112260.3317@g5.osdl.org> <Pine.LNX.4.62.0508220617030.4675@schroedinger.engr.sgi.com> <Pine.LNX.4.61.0508221508410.18930@goblin.wat.veritas.com> <Pine.LNX.4.62.0508220823150.6260@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0508220823150.6260@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 22, 2005 at 08:24:50AM -0700, Christoph Lameter wrote:
> On Mon, 22 Aug 2005, Hugh Dickins wrote:
> 
> > (Your deltas seem sensible, but hard to place the reaccumulation:
> > I worry that you may be taking page_table_lock more just for that.)
> 
> The page_table_lock is taken using a spin_trylock. Its skipped if 
> contended.

Hmm - doesn't try lock cause a cache line bounce on the bus too? 
I think it does. That would mean its latency is not much better 
than a real spinlock (assuming it doesn't have to spin) 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
