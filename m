Date: Mon, 18 Aug 2008 16:29:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: page allocator minor speedup
Message-Id: <20080818162934.aba8793e.akpm@linux-foundation.org>
In-Reply-To: <20080818122957.GE9062@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de>
	<20080818122957.GE9062@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Aug 2008 14:29:57 +0200
Nick Piggin <npiggin@suse.de> wrote:

> Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> "remove PageReserved from core mm" patch has had a long time to mature,
> let's remove the page reserved logic from the allocator.
> 
> This saves several branches and about 100 bytes in some important paths.

This of course made a big mess against the page reclaim rewrite.  I
think I fixed it up.

I could have merged it ahead, but then that would have made a big mess
of the page reclaim rewrite.

Testing and reviewing the page reclaim rewrite would be a useful
place to spend time..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
