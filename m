Message-ID: <41C411BD.6090901@yahoo.com.au>
Date: Sat, 18 Dec 2004 22:17:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com>
In-Reply-To: <20041218110608.GJ771@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Sat, Dec 18, 2004 at 09:06:29PM +1100, Nick Piggin wrote:
> 
>>Yes I thought about that a bit too.
>>Note that this (4/10) patch should give perfect garbage collection too
>>(modulo bugs). The difference is in where the overheads lie. I suspect
>>refcounting may be too much overhead (at least, SMP overhead); especially
>>in light of Christoph's results.
> 
> 
> If this were so, then clear_page_tables() during process destruction
> would be unnecessary. detach_vmas_to_be_unmapped() makes additional
> work for such schemes, but even improvements are still rather helpful.
> 

If what were so?

> 
> On Sat, Dec 18, 2004 at 09:06:29PM +1100, Nick Piggin wrote:
> 
>>Although I think it would enable you to do page table reclaim when
>>reclaiming mapped, file backed pages quite easily... but I'm not sure if
>>that is enough to offset the slowdowns.
> 
> 
> That would be a far more appropriate response to high multiprogramming
> levels than what is now done.
> 

On a select few workloads, yes.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
