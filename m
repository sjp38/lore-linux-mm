Message-ID: <41C3E04F.5020607@yahoo.com.au>
Date: Sat, 18 Dec 2004 18:46:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
References: <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de>
In-Reply-To: <20041218073100.GA338@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Sat, Dec 18, 2004 at 06:01:05PM +1100, Nick Piggin wrote:
> 
>>10/10
> 
> 
>>
>>Convert some pagetable walking functions over to be inline where
>>they are only used once. This is worth a percent or so on lmbench
>>fork.
> 
> 
> Any modern gcc (3.4+ or 3.3-hammer) should use unit-at-a-time anyways,
> which automatically inlines all static functions that are only used once.
> 
> I like it because during debugging you can turn it off and it makes
> it much easier to read oopses when not everything is inlined.  And 
> when turned on it generates much smaller and faster as you've shown
> code.
> 

Yep, that makes a lot of sense.

> Ok except on i386 where someone decided to explicitely turn it off 
> all the time :/
> 
> I've been reenabling it on the suse kernel for a long time because
> it doesn't seem to have any bad side effects and makes the code
> considerably smaller.  It would be better to just turn it on in mainline 
> again, then you'll see much more gain everywhere.
> 

I won't get into this argument ;)

But I'll just say that this inline patch isn't very important at all -
it seems to be worth about 1% at best.

> BTW we can do much better with all the page table walking by
> adding some bitmaps about used ptes to struct page and skipping
> holes quickly. DaveM has a patch for that in the queue, I hope a patch 
> similar to his can be added once 4level page tables are in.
> 

Hmm, haven't seen them. Would be interesting - I guess you can get
a pretty big cache saving by testing a single bit rather than a
full word, assuming the common case is pretty sparse. I wonder how
it goes in practice?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
