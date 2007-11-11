Date: Sun, 11 Nov 2007 09:45:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 0/6] lockless pagecache
Message-ID: <20071111084556.GC19816@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I wonder what everyone thinks about getting the lockless pagecache patch
into -mm? This version uses Hugh's suggestion to avoid a smp_rmb and a load
and branch in the lockless lookup side, and avoids some atomic ops in the
reclaim path, and avoids using a page flag! The coolest thing about it is
that it speeds up single-threaded pagecache lookups...

Patches are against latest git for RFC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
