Message-ID: <41C9582D.5020201@yahoo.com.au>
Date: Wed, 22 Dec 2004 22:19:09 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de> <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org> <20041221201927.GD15643@wotan.suse.de> <41C8B678.40007@yahoo.com.au> <20041222103800.GC15894@wotan.suse.de>
In-Reply-To: <20041222103800.GC15894@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>I understand you'd be frustrated if 4level wasn't in 2.6.11, but as I
>>said, I don't think the choice of pud over pml4 would necessarily cause
>>such a delay.
> 
> 
> It would require a longer testing cycle in -mm* again, at least
> several weeks and probably some support from the arch maintainers again.
> That may push it too late.
> 

Yes it would ideally need a week or so in -mm. And yes, arch maintainers
would need to give some support again, unfortunately: the proposed
fallback header is only a "dirty-make-this-compile-hack", that shouldn't
be propogated into a 2.6 proper release if possible.

> 
>>As far as I understand, you don't have any problem with the 'pud'
>>implementation in principle?
> 
> 
> I don't have anything directly against the name (although I'm still not sure
> what it actually stands for) or the location (top level or mid level), 
> but I'm worried about the delay of redoing the testing cycle completely.
> 

The name I guess is "upper". So you have a global, upper, middle, page table,
so it sort-of fits :)

But it is the location rather than the name that is the important factor in
my continuing to persue this.

> I don't see any technical advantages of your approach over mine, eventually
> all the work has to be done anyways, so in the end it boils down
> what names are prefered. However I suspect you could use your time
> better, Nick, than redoing things that have been already done ;-) 
> 

Well I suspect there are no advantages at all if you look at the compiled
binary.

But the advantages I see in the source code are a) pud folding matches exactly
how pmd folding was done on 2 level architectures, and b) it doesn't touch
either of the "business ends" of the page table structure (ie. top most or
bottom most levels).  I think these two points give some (if only slight)
advantage in maintainability and consistency.

It is unfortunate, and nobody's fault but my own, that I didn't look at your
patches earlier and work with you while you were still in the earlier stages
of coding. So I apologise for that.

I agree that the situation we now have where I'm essentially posting a
"competing" implementation which is just a slight variation on your patches,
but less testing and arch work is not ideal. The only reason I feel strongly
enough to have gone this far is because it is very core code.

And yeah, I'm sure I could use my time better!! This is just a bed time
project which is why I had been a bit slow with it ;)


I hope we can reach a conclusion. I don't want to (nor am I any way in a
position to) just say no pml4. Nor do I want the situation where nobody can
agree and it comes to the choice being made by a vote or other means. But I
do think there are legitimate reasons for pud over pml4.

If I can get the bulk of the architectures changed and tested, the arch
maintainers don't kick up too much fuss, it has a relatively trouble free run
in -mm, and Andrew and Linus are still happy to merge before 2.6.11, would you
be OK with the pud version (in principle)?

Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
