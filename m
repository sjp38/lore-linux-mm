Date: Tue, 21 Dec 2004 01:22:01 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041221002201.GA21986@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au> <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain> <20041220180435.GG4316@wotan.suse.de> <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org> <20041220185308.GA24493@wotan.suse.de> <Pine.LNX.4.58.0412201600400.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412201600400.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2004 at 04:04:49PM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 20 Dec 2004, Andi Kleen wrote:
> > 
> > I'm not sure what you mean with that. You have to convert the architectures,
> > otherwise they won't compile. That's true for my patch and true for
> > Nick's (except that he didn't do all the work of converting the archs yet)
> 
> Well, you do have to convert the architectures, in the sense that you need 
> to fix up the types for the "pmd_offset()" etc functions.
> 
> But you shouldn't have to fix up anything else. Especially if "pgd_t" 
> doesn't change, the _only_ things that need fixing up is anything that 
> walks the page tables. Nothing else.

Actually anything that looks up anything in the page tables. 
And there is plenty of that in each architecture.

You have to break this code, otherwise you cannot catch the code
walking page tables and risk unconverted generic code.

I repeat again: the differences on what code needs
to be changed between my patchkit and Nick's are quite minor.

The main difference is just the naming. And that mine is actually
tested on many architectures and and has been in -mm* for some time
and is ready for merging, while Nick's is still in the early stages.

> 
> >>   It's just that once you conceptually do it in the middle, a
> >> numbered name like "pml4_t" just doesn't make any sense (
> >
> > Sorry I didn't invent it, just copied it from the x86-64 architecture
> > manuals because I didn't see any reason to be different.
> 
> The thing is, I doubt the x86-64 architecture manuals use "pgd", "pmd" and 
> "pte", do they? So regardless, there's no consitent naming.

There is consistent naming for the highest level at least. 

They use pte, pde, pdpe, pml4e (for the entries, the levels are
called pte, pde, pdp, pml4) 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
