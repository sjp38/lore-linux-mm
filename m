Message-ID: <41C4CDA0.5090504@yahoo.com.au>
Date: Sun, 19 Dec 2004 11:38:56 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au> <20041219002010.GN771@holomorphy.com>
In-Reply-To: <20041219002010.GN771@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> William Lee Irwin III wrote:
> 
>>>vmas are unmapped one-by-one during process destruction.
> 
> 
> On Sun, Dec 19, 2004 at 11:05:22AM +1100, Nick Piggin wrote:
> 
>>Yeah but clear_page_tables isn't called for each vma that is unmapped
>>at exit time. Rather, one big one is called at the end - I suspect
>>this is usually more efficient.
> 
> 
> For clear_page_tables() you want to scan as little as possible. The

Sure. I wonder if we could cut down the amount of scanning by keeping
track of what ranges of vmas have been unmapped... still, I don't think
I have seen this function high on a profile, so until then I personally
don't think I'll bother ;)

> exit()-time performance issue is tlb_finish_mmu().
> 

Makes sense. I guess there is often a lot of memory one has to shoot
down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
