Date: Tue, 21 Dec 2004 21:19:27 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041221201927.GD15643@wotan.suse.de>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de> <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> That's true, but it's not an issue for several reasons:
> 
>  - we can easily update just _x86_ to be type-safe (ie add the fourth 
>    level to x86 just to get type safety, even if it's folded). That 
>    doesn't mean that we have to worry about 20 _other_ architectures, that 
>    most developers can't even test.

I already covered near all of them anyways (m68k is the main exception) 
And quite a few of them have been even tested, thanks to the port
maintainers.

> > Also is the flag day really that bad?
> 
> I think that _avoiding_ a flag-day is always good. Also, more importantly,
> it looks like this approach allows each patch to be smaller and more 
> self-contained, ie we never have the situation where "uhhuh, now it won't 
> compile on arch Xxxx for ten patches, until we turn things on". The 
> smaller the patches are, the more obvious any problems will be.

With the warnings the port maintainers will need to do the conversion
work anyways, they can't just leave the warnings in (at least if they
care to still maintain their code in the future) 

> 
> Think of it this way: for random architecture X, the four-level page table 
> patches really should make _no_ difference until they are enabled. So you 
> can do 90% of the work, and be pretty confident that things work. Most 
> importantly, if things _don't_ work before the thing has been enabled, 
> that's a big clue ;)

My approach was to just do the straight forward conversions. The only
risk (from experience) so far was that things not compile when I forgot
one replacement, but when they compile they tend to work.

I must say I would still prefer if my patches were applied instead

of going through all of this again in a slightly different form.
e.g. who is doing all this "PUD" stuff? Nick's patch so far was only
a prototype and probably needs quite a bit more work and then a new
-mm testing cycle. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
