Message-ID: <41C8B678.40007@yahoo.com.au>
Date: Wed, 22 Dec 2004 10:49:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de> <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org> <20041221201927.GD15643@wotan.suse.de>
In-Reply-To: <20041221201927.GD15643@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>>Think of it this way: for random architecture X, the four-level page table 
>>patches really should make _no_ difference until they are enabled. So you 
>>can do 90% of the work, and be pretty confident that things work. Most 
>>importantly, if things _don't_ work before the thing has been enabled, 
>>that's a big clue ;)
> 
> 
> My approach was to just do the straight forward conversions. The only
> risk (from experience) so far was that things not compile when I forgot
> one replacement, but when they compile they tend to work.
> 

That is more or less the same with the 'pud' patches - the hard part
is in the infrastructure and generic code, architectures are generally
pretty simple.

> I must say I would still prefer if my patches were applied instead
> 
> of going through all of this again in a slightly different form.
> e.g. who is doing all this "PUD" stuff? Nick's patch so far was only
> a prototype and probably needs quite a bit more work and then a new
> -mm testing cycle. 
> 

To summarise my position,

I would like 'pud' to go in, because once one of the implementations gets
into 2.6, it is going to be a lot harder to justify changing. And I
personally like pud better (not the name, but the place) so I would prefer
that to get in. Again, that is nothing against your implementation or your
personal taste.

So all I can do is put up my suggestion, and leave it to someone else to
decide. I'm not so established/experienced in this code to be making big
choices.

I understand you'd be frustrated if 4level wasn't in 2.6.11, but as I
said, I don't think the choice of pud over pml4 would necessarily cause
such a delay.

As far as I understand, you don't have any problem with the 'pud'
implementation in principle?

Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
