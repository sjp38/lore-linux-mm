Message-ID: <41C41ACE.7060002@yahoo.com.au>
Date: Sat, 18 Dec 2004 22:55:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com>
In-Reply-To: <20041218113252.GK771@holomorphy.com>
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
>>>If this were so, then clear_page_tables() during process destruction
>>>would be unnecessary. detach_vmas_to_be_unmapped() makes additional
>>>work for such schemes, but even improvements are still rather helpful.
> 
> 
> On Sat, Dec 18, 2004 at 10:17:17PM +1100, Nick Piggin wrote:
> 
>>If what were so?
> 
> 
> If clear_page_tables() implemented perfect GC.
> 

Oh... well it does perfectly free memory in the context of what ranges
have been previously cleared with clear_page_tables. So that doesn't
free you from the requirement of calling clear_page_tables at some
point.

I suspect though, you are referring to refcounting, in which case yes,
GC could probably be performed at unmap time, and clear_page_tables
could disappear. I still think it would be too costly to refcount down
to the pte_t level, especially SMP-wise.... but I'm just basing that
on a few minutes of thought, so - I don't really know.

> 
> On Sat, Dec 18, 2004 at 09:06:29PM +1100, Nick Piggin wrote:
> 
>>>>Although I think it would enable you to do page table reclaim when
>>>>reclaiming mapped, file backed pages quite easily... but I'm not sure if
>>>>that is enough to offset the slowdowns.
> 
> 
> William Lee Irwin III wrote:
> 
>>>That would be a far more appropriate response to high multiprogramming
>>>levels than what is now done.
> 
> 
> On Sat, Dec 18, 2004 at 10:17:17PM +1100, Nick Piggin wrote:
> 
>>On a select few workloads, yes.
> 
> 
> Counterexamples would be illustrative.
> 

Oh, just workloads where memory is fairly dense in virtual space, and
not shared (much). Non-oracle workloads, perhaps? :)

Seriously? On my typical desktop, I have 250MB used, of which 1MB is
page tables, I suspect this is a pretty typical ratio on desktops,
but I have less experience with high end database servers and that type
of stuff.

I was hoping you could provide an example rather than me a counter ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
