Date: Sun, 19 Dec 2004 00:07:34 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <41C3D453.4040208@yahoo.com.au>
Message-ID: <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Dec 2004, Nick Piggin wrote:
> 
> Apologies for not making progress on this done sooner, but better late than never.
> 
> First off - don't let all the signed-off-by: things fool you, I'm only intending
> this for comments, not merging. I just spent a bit of time getting the descriptions
> in better shape.
> 
> Second - much of it is Andi's code (especially 4 level core, and x86-64 stuff).
> If any attributions aren't quite accurate at this stage, don't worry too much!
> 
> 
> Anyway, although we have a working 4-level page tables implementation, I am keeping
> with this because my personal taste preference. Not that it is anything against
> Andi's taste or technical implementation... but I wouldn't like progress to be held
> up on account of me, so I wouldn't be too upset to forget about this until 2.7 (or
> for ever)... /end disclaimer
> 
> Well, the patches follow. Tested lightly on i386 32 and 36 bits, ia64, and x86-64
> with full 4 levels.
> 
> Comments?

I had been sceptical whether it's now worth a revised implementation.
But these look like good tasteful patches to me, nicely split up.

In all they will amount to more change than Andi's original version -
partly because of the de-pml4-ing in x86_64, but more because of the
genericizing of nopmd and then nopud - but that's worthwhile.
The changes seem to be the ones which ought to be in there.

I think Andi's work has benefitted from having
your eye and hand go over it for a second round.

> A bit of an aside: I was hoping to have a page table folding implementation that is
> basically transparent to architectures. That is, a 3-level arch could just include
> some generic header to fold the 4th level, and call it a day (without any other mods
> to arch/?/* or include/asm-?/*).
> 
> The reality is, this isn't going to happen with our current semantics. It probably
> isn't a really big deal though, because I don't expect we'd have to support a 5
> level implementation any time soon. But it is something I'd like to explore further.
> 
> I'll illustrate with an example: in the current setup, if the pmd is folded into
> the pgd, pgd_present is always true, and pmd_present is what actually examines the
> entry in the pgd. Now clearly, the architecture has to implement pmd_present, which
> is pgd_present in a 2-level setup.
> 
> I would like to change that so pgd_present really does check the actual pgd entry,
> and pmd_present is unconditionally true. IMO this would work better and be less
> confusing than the current setup... but that's getting off topic...

Thanks for going into that.  Of course I'm disappointed, I had
been hoping that pud would obviate the need for immediate change
in all the arches.  But I trust your explanation for why not, and
after several readings I think I'm beginning to understand it!

My vote is for you (with arch assistants) to extend this work to the
other arches, and these patches to replace the current 4level patches
in -mm.  But what does Andi think - are those "inline"s his only dissent?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
