Date: Sat, 18 Dec 2004 17:01:51 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
Message-ID: <20041219010151.GO771@holomorphy.com>
References: <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au> <20041219002010.GN771@holomorphy.com> <41C4CDA0.5090504@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C4CDA0.5090504@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 19, 2004 at 11:38:56AM +1100, Nick Piggin wrote:
>> For clear_page_tables() you want to scan as little as possible. The

William Lee Irwin III wrote:
> Sure. I wonder if we could cut down the amount of scanning by keeping
> track of what ranges of vmas have been unmapped... still, I don't think
> I have seen this function high on a profile, so until then I personally
> don't think I'll bother ;)

Probably best to talk to davem about this. Or at least he's a source of
information about this independent from me.


William Lee Irwin III wrote:
>> exit()-time performance issue is tlb_finish_mmu().

On Sun, Dec 19, 2004 at 11:38:56AM +1100, Nick Piggin wrote:
> Makes sense. I guess there is often a lot of memory one has to shoot
> down.

Also, some of the comments in the prior post relate to one of the
differences in how I implemented all this.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
