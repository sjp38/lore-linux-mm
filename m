Message-ID: <41C40D3E.9050507@yahoo.com.au>
Date: Sat, 18 Dec 2004 21:58:06 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <20041218104522.GI771@holomorphy.com>
In-Reply-To: <20041218104522.GI771@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Sat, Dec 18, 2004 at 05:57:12PM +1100, Nick Piggin wrote:
> 
>>Rename clear_page_tables to clear_page_range. clear_page_range takes byte
>>ranges, and aggressively frees page table pages. Maybe useful to control
>>page table memory consumption on 4-level architectures (and even 3 level
>>ones).
>>Possible downsides are:
>>- flush_tlb_pgtables gets called more often (only a problem for sparc64
>>  AFAIKS).
>>- the opportunistic "expand to fill PGDIR_SIZE hole" logic that ensures
>>  something actually gets done under the old system is still in place.
>>  This could sometimes make unmapping small regions more inefficient. There
>>  are some other solutions to look at if this is the case though.
>>Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> 
> 
> I wrote something equivalent to this in September, but dropped it on the
> floor after some private replies etc. indicated no one gave a damn about
> the testcase I posted in Message-ID: <20040908110718.GX3106@holomorphy.com>
> where the pagetable leak fooled the OOM killer into shooting the wrong
> processes long enough to trigger a panic() in oom_kill.c
> 
> 

Hmm... I actually didn't see your post, but it seems like something
worth pursuing.

My incling is that the hybrid expand-to-hole / refcounting approach
I outlined earlier in the thread might be the way to go.

I'll be interested to hear what the powers that be think.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
