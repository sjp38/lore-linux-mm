Date: Mon, 15 Nov 2004 21:37:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Possible alternate 4 level pagetables?
In-Reply-To: <4196F12D.20005@yahoo.com.au>
Message-ID: <Pine.LNX.4.44.0411152121340.4171-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2004, Nick Piggin wrote:
> 
> Just looking at your 4 level page tables patch, I wondered why the extra
> level isn't inserted between pgd and pmd, as that would appear to be the
> least intrusive (conceptually, in the generic code). Also it maybe matches
> more closely the way that the 2->3 level conversion was done.

I thought the same, when I finally took a look a week or so ago.

I've scarcely looked at your patches, but notice they change i386.

For me, the attraction of putting the new level in between pgd and pmd
was that it seemed that only common code and x86_64 (and whatever else
comes to use all four levels in future) would need changing (beyond,
perhaps, #including some asm-generic headers).  Some casting to combine
the two levels into pmd in unchanged arch code, or rename pmd to pld in
the changed common code.  Andi's arch patches seemed (all?) to spring
from replacing mm->pgd by mm->pml4.

But I could well be mistaken, I wasn't so industrious as to actually
try it.

> I've been toying with it a little bit. It is mainly just starting with
> your code and doing straight conversions, although I also attempted to
> implement a better compatibility layer that does the pagetable "folding"
> for you if you don't need to use the full range of them.
> 
> Caveats are that there is still something slightly broken with it on i386,
> and so I haven't looked at x86-64 yet. I don't see why this wouldn't work
> though.
> 
> I've called the new level 'pud'. u for upper or something.

Well, yes, your base appetites have led you to the name "pud",
where my refined intellect led me to "phd", with h for higher ;)

> Sorry the patch isn't in very good shape at the moment - I won't have time
> to work on it for a week, so I thought this would be a good point just to
> solicit initial comments.

I doubt it's worthwhile now, particularly if you do have to patch arches.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
