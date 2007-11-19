Date: Mon, 19 Nov 2007 23:58:24 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/6] lockless pagecache
Message-ID: <20071119225824.GB24255@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de> <Pine.LNX.4.64.0711172001420.9287@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711172001420.9287@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 17, 2007 at 08:16:18PM +0000, Hugh Dickins wrote:
> On Sun, 11 Nov 2007, Nick Piggin wrote:
> > 
> > I wonder what everyone thinks about getting the lockless pagecache patch
> > into -mm? This version uses Hugh's suggestion to avoid a smp_rmb and a load
> > and branch in the lockless lookup side, and avoids some atomic ops in the
> > reclaim path, and avoids using a page flag! The coolest thing about it is
> > that it speeds up single-threaded pagecache lookups...
> 
> I've liked this in the past, with the exception of PageNoNewRefs which
> seemed an unnecessary ugliness.  Now you've eliminated that, thank you,
> I expect I should like it through and through (if I actually found time
> to redigest it).  A moment came up and I thought I'd give it a spin...

Yeah I decided it is actually just as good or better at it's job --
neither really protects against an errant get_page() or put_page(),
however at least this scheme will go bug with CONFIG_DEBUG_VM, as opposed
to the current or old lockless schemes (which I guess will silently allow
it).


> > Patches are against latest git for RFC.
> 
> ... but they're not.  You seem to have descended into sending out
> ?cleanup? patches at intervals, and recursive dependence upon them.
> This set relies on there being something called __set_page_locked()
> in include/linux/pagemap.h, but there isn't in latest git (nor mm).
> Ah, you posted a patch earlier which introduced that, but it relies on
> there being something called set_page_locked() in include/linux/pagemap.h,
> but there isn't in latest git (nor mm).  Ah, you posted a patch earlier
> which introduced that ... I gave up at this point.
> 
> We've all got lots of other things to do, please make it easier.

Sorry, I honestly didn't pay enough attention there because I didn't
think anybody would run it! I'll update it and resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
