Date: Mon, 20 Dec 2004 19:04:35 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041220180435.GG4316@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au> <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0412182338040.13356-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 19, 2004 at 12:07:34AM +0000, Hugh Dickins wrote:
> Thanks for going into that.  Of course I'm disappointed, I had
> been hoping that pud would obviate the need for immediate change
> in all the arches.  But I trust your explanation for why not, and
> after several readings I think I'm beginning to understand it!
> 
> My vote is for you (with arch assistants) to extend this work to the
> other arches, and these patches to replace the current 4level patches
> in -mm.  But what does Andi think - are those "inline"s his only dissent?

I don't see the point of redoing the work. IMHO Nick's new patches
only have cosmetic advantages over mine. Seems to be quite a lot of 
work to just rename some data types for me with unclear gain.

And the arch maintainers may be unwilling to redo this multiple times :)

One issue I see is that there is still some work to be done - in particular
the optimized page table walking will need to be added to regain
lmbench fork/exec performance. I've been waiting for my patches
to be merged to then work on top of that. Doing another round
of changes would make this difficult, because it would mean more
delay and/or conflicting patches.

But I'm not strongly opposed to it. If everybody else thinks "pud_t" 
is the greatest thing since sliced bread and much a much better name
than "pml4_t" then I guess we could eat the delay and disruption
that another round of these disruptive patches takes.

But I have my doubts it is worth it. Also who guarantees that
not somebody else turns up and wants to rename it to "pad_t" or 
"pod_t" or somesuch and then we would have to wait even 
longer for things to settle down. ;-) In my patches I avoided
the problem by just picking the name AMD gave it and which
seems to be the standard now in the x86-64 world at least (Intel
uses it too) 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
