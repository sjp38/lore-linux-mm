Message-ID: <41D471FB.1060805@yahoo.com.au>
Date: Fri, 31 Dec 2004 08:24:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de> <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org> <20041221201927.GD15643@wotan.suse.de> <41C8B678.40007@yahoo.com.au> <20041222103800.GC15894@wotan.suse.de> <41C9582D.5020201@yahoo.com.au> <20041222180748.GB9339@wotan.suse.de>
In-Reply-To: <20041222180748.GB9339@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Wed, Dec 22, 2004 at 10:19:09PM +1100, Nick Piggin wrote:
> 
>>But the advantages I see in the source code are a) pud folding matches 
>>exactly
>>how pmd folding was done on 2 level architectures, and b) it doesn't touch
>>either of the "business ends" of the page table structure (ie. top most or
>>bottom most levels).  I think these two points give some (if only slight)
>>advantage in maintainability and consistency.
> 
> 
> Sure, but when it's merged then pml4_t (or p<whatever>_t) would be 
> the "business end", so it doesn't make much difference longer term.
> After all future linux coders will not really care what was in the
> past, just what is in the code at the time they hack on it.
> 

Yeah OK, raw-code wise the pml4 patch isn't much different. But the
conceptual intrusiveness of having the folding 'magic' in the top
level page table is a bit higher.

Also, pml4 does have some implementation intrusiveness by introducing
a new _way_ of folding the table, whereas pud folds in the same manner
as pmd.

> 
> 
>>If I can get the bulk of the architectures changed and tested, the arch
>>maintainers don't kick up too much fuss, it has a relatively trouble free 
>>run
>>in -mm, and Andrew and Linus are still happy to merge before 2.6.11, would 
>>you
>>be OK with the pud version (in principle)?
> 
> 
> I can't say I'm very enthusiastic about it (but more due to scheduling
> issues than technical issues). I don't see anything wrong with them by itself,
> but I also don't think they have any particular advantages over the
> pml4 version. But in the end the main thing I care about is that
> 4 level pagetables get in in some form, where exactly the
> new level is added and how it is named is secondary.
> 

So long as you are not completely against it, that is a good start ;)

> I would prefer if it happened sooner though because the work
> is not finished (the optimized walking is still needed),
> and i've been just waiting for getting merged and settled
> down a bit before continuing. 
> 

Yeah sure. I can also try to help with that (regardless of which patch
is merged).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
