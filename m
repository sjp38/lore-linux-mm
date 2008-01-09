Subject: Re: [patch 0/6] lockless pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 09 Jan 2008 16:45:30 +0100
Message-Id: <1199893530.7143.95.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-11-11 at 09:45 +0100, Nick Piggin wrote:
> Hi,
> 
> I wonder what everyone thinks about getting the lockless pagecache patch
> into -mm? This version uses Hugh's suggestion to avoid a smp_rmb and a load
> and branch in the lockless lookup side, and avoids some atomic ops in the
> reclaim path, and avoids using a page flag! The coolest thing about it is
> that it speeds up single-threaded pagecache lookups...
> 
> Patches are against latest git for RFC.

How are we doing with this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
