Message-ID: <41C4CC54.4010900@yahoo.com.au>
Date: Sun, 19 Dec 2004 11:33:24 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Sat, 18 Dec 2004, Nick Piggin wrote:
> 

>>Well, the patches follow. Tested lightly on i386 32 and 36 bits, ia64, and x86-64
>>with full 4 levels.
>>
>>Comments?
> 
> 
> I had been sceptical whether it's now worth a revised implementation.
> But these look like good tasteful patches to me, nicely split up.
> 
> In all they will amount to more change than Andi's original version -
> partly because of the de-pml4-ing in x86_64, but more because of the
> genericizing of nopmd and then nopud - but that's worthwhile.
> The changes seem to be the ones which ought to be in there.
> 
> I think Andi's work has benefitted from having
> your eye and hand go over it for a second round.
> 

Well yes - and let's not lose sight of what the patches actually consist
of: _most_ of the hard work is Andi's, and fortunately things are clean
enough that moving from pml4 to pud wasn't a lot harder than a
s/pgd/pud, s/pml4/pgd!

- even for x86-64, which I had expected to be a much harder job.

[snip]

> My vote is for you (with arch assistants) to extend this work to the
> other arches, and these patches to replace the current 4level patches
> in -mm.  But what does Andi think - are those "inline"s his only dissent?
> 

The rest of the architectures shouldn't be much problem I hope. If
there were any difficulties, then Andi should already have them covered,
and the rest is more or less a straight search-replace.

But yeah we obviously want to get Andi on side _if_ we are to go with
`pud`...

Thanks for the comments Hugh.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
