Message-ID: <47AC04CD.9090407@cosmosbay.com>
Date: Fri, 08 Feb 2008 08:29:17 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [git pull] more SLUB updates for 2.6.25
References: <Pine.LNX.4.64.0802071755580.7473@schroedinger.engr.sgi.com> <200802081812.22513.nickpiggin@yahoo.com.au>
In-Reply-To: <200802081812.22513.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin a ecrit :
> On Friday 08 February 2008 13:13, Christoph Lameter wrote:
>> are available in the git repository at:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-linus
>>
>> (includes the cmpxchg_local fastpath since the cmpxchg_local work
>> by Matheiu is in now, and the non atomic unlock by Nick. Verified that
>> this is not doing any harm after some other patches had been removed.
> 
> Ah, good. I think it is always a good thing to be able to remove atomics.
> They place quite a bit of burden on the CPU, especially x86 where it also
> has implicit memory ordering semantics (although x86 can speculatively
> get around much of the problem, it's obviously worse than no restriction)
> 
> Even if perhaps some cache coherency or timing quirk makes the non-atomic
> version slower (all else being equal), then I'd still say that the non
> atomic version should be preferred.
> 

What about IRQ masking then ?

Many CPU pay high cost for cli/sti pair...

And SLAB/SLUB allocators, even if only used from process context, want to 
disable/re-enable interrupts...

I understand kmalloc() want generic pools, but dedicated pools could avoid 
this cli/sti

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
