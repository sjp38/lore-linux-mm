Date: Sat, 17 Nov 2007 20:16:18 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 0/6] lockless pagecache
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0711172001420.9287@blonde.wat.veritas.com>
References: <20071111084556.GC19816@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Nov 2007, Nick Piggin wrote:
> 
> I wonder what everyone thinks about getting the lockless pagecache patch
> into -mm? This version uses Hugh's suggestion to avoid a smp_rmb and a load
> and branch in the lockless lookup side, and avoids some atomic ops in the
> reclaim path, and avoids using a page flag! The coolest thing about it is
> that it speeds up single-threaded pagecache lookups...

I've liked this in the past, with the exception of PageNoNewRefs which
seemed an unnecessary ugliness.  Now you've eliminated that, thank you,
I expect I should like it through and through (if I actually found time
to redigest it).  A moment came up and I thought I'd give it a spin...

> Patches are against latest git for RFC.

... but they're not.  You seem to have descended into sending out
?cleanup? patches at intervals, and recursive dependence upon them.
This set relies on there being something called __set_page_locked()
in include/linux/pagemap.h, but there isn't in latest git (nor mm).
Ah, you posted a patch earlier which introduced that, but it relies on
there being something called set_page_locked() in include/linux/pagemap.h,
but there isn't in latest git (nor mm).  Ah, you posted a patch earlier
which introduced that ... I gave up at this point.

We've all got lots of other things to do, please make it easier.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
