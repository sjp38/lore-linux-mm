Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <20041221002201.GA21986@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au>
	 <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
	 <20041220180435.GG4316@wotan.suse.de>
	 <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
	 <20041220185308.GA24493@wotan.suse.de>
	 <Pine.LNX.4.58.0412201600400.4112@ppc970.osdl.org>
	 <20041221002201.GA21986@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 21 Dec 2004 11:47:58 +1100
Message-Id: <1103590078.5121.15.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-12-21 at 01:22 +0100, Andi Kleen wrote:

> I repeat again: the differences on what code needs
> to be changed between my patchkit and Nick's are quite minor.
> 

The thing I prefer about the pud is that the folding method is identical
to pmd. If you have a look at asm-generic/pgtable-nopmd.h and -nopud.h,
they are the same file, with a few things renamed.

> The main difference is just the naming. And that mine is actually
> tested on many architectures and and has been in -mm* for some time
> and is ready for merging, while Nick's is still in the early stages.
> 

True it will need more testing than yours would, which would almost be
able to go in as soon as 2.6.10 was released... but considering most of
the hard stuff _is_ your work, then hopefully most problems should be
resolved already.

I understand you'd like the 4-levels patch to be present in 2.6.11... I
don't think that going with the "pud" version would necessarily prevent
that from happening.

> > 
> > >>   It's just that once you conceptually do it in the middle, a
> > >> numbered name like "pml4_t" just doesn't make any sense (
> > >
> > > Sorry I didn't invent it, just copied it from the x86-64 architecture
> > > manuals because I didn't see any reason to be different.
> > 
> > The thing is, I doubt the x86-64 architecture manuals use "pgd", "pmd" and 
> > "pte", do they? So regardless, there's no consitent naming.
> 
> There is consistent naming for the highest level at least. 
> 
> They use pte, pde, pdpe, pml4e (for the entries, the levels are
> called pte, pde, pdp, pml4) 
> 

Well I won't argue about naming, because I don't think anyone cares
enough for it to be a problem. But pud is consistent with _Linux_
naming, at least (ie. p?d)...

Anyway, I'll continue to try to get more architecture support, and
let someone else decide between pud and pml4 ;) Although if it looks
like it is going to really slow down progress for you, then I am
happy to abandon it.

Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
