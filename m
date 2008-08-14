Date: Thu, 14 Aug 2008 14:20:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
In-Reply-To: <20080814123546.GA29727@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0808141410490.14452@blonde.site>
References: <20080814094537.GA741@wotan.suse.de> <Pine.LNX.4.64.0808141210200.4398@blonde.site>
 <20080814123546.GA29727@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Aug 2008, Nick Piggin wrote:
> On Thu, Aug 14, 2008 at 12:55:46PM +0100, Hugh Dickins wrote:
> 
> Maybe I've found another one: ppc64's set_pte_at seems to clear
> the pte, and lots of pte accessors are implemented with set_pte_at.
> mprotect's modify_prot_commit for example.
> 
> Even if I'm wrong and we happen to be safe everywhere, it seems
> really fragile to ask that no architectures ever allow transient
> !pte_present in cases  where it matters, and no generic code
> emit the wrong sequence either. Or is there some reason I'm missing
> that makes this more robust?

I agree completely that should be allowed (within pagetable lock)
and is sometimes essential, mprotect being the classic example.

So I'll try to think through your case later on, focussing on
mprotect instead, and report back once I've pictured it.

> Hmm, vma_wants_writenotify is only true if VM_WRITE, and in that
> case we might be OK?

Yes, that's what I'd missed: with that worry out of the way,
I should think a bit clearer.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
