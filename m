Date: Sat, 18 Dec 2004 10:50:50 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
Message-ID: <20041218095050.GC338@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C3F2D6.6060107@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2004 at 08:05:26PM +1100, Nick Piggin wrote:
> Nick Piggin wrote:
> >4/10
> >
> >
> >------------------------------------------------------------------------
> >
> >
> >
> >Rename clear_page_tables to clear_page_range. clear_page_range takes byte
> >ranges, and aggressively frees page table pages. Maybe useful to control
> >page table memory consumption on 4-level architectures (and even 3 level
> >ones).
> >
> 
> I maybe didn't do this patch justice by hiding it away in this series.
> It may be worthy of its own thread - surely there must be some significant
> downsides if nobody had implemented it in the past (or maybe just a fact
> of "that doesn't happen much").

Yes, more could be done in this area. When I did 4level I just tried
to keep the same semantics without optimizing anything.

Another way I thought about was to have a reference count of the used
ptes/pmds per page table page in struct page and free the page when it goes 
to zero. That would give perfect garbage collection. Drawback is that
it may be a bit intrusive again.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
