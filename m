Date: Mon, 20 Dec 2004 16:04:49 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <20041220185308.GA24493@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412201600400.4112@ppc970.osdl.org>
References: <41C3D453.4040208@yahoo.com.au>
 <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
 <20041220180435.GG4316@wotan.suse.de> <Pine.LNX.4.58.0412201016260.4112@ppc970.osdl.org>
 <20041220185308.GA24493@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Andi Kleen wrote:
> 
> I'm not sure what you mean with that. You have to convert the architectures,
> otherwise they won't compile. That's true for my patch and true for
> Nick's (except that he didn't do all the work of converting the archs yet)

Well, you do have to convert the architectures, in the sense that you need 
to fix up the types for the "pmd_offset()" etc functions.

But you shouldn't have to fix up anything else. Especially if "pgd_t" 
doesn't change, the _only_ things that need fixing up is anything that 
walks the page tables. Nothing else.

>>   It's just that once you conceptually do it in the middle, a
>> numbered name like "pml4_t" just doesn't make any sense (
>
> Sorry I didn't invent it, just copied it from the x86-64 architecture
> manuals because I didn't see any reason to be different.

The thing is, I doubt the x86-64 architecture manuals use "pgd", "pmd" and 
"pte", do they? So regardless, there's no consitent naming.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
