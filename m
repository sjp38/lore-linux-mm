Date: Mon, 1 Dec 2008 22:55:40 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
In-Reply-To: <1228074124.24749.26.camel@lappy.programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0812012247590.18893@blonde.anvils>
References: <1227886959.4454.4421.camel@twins>
 <alpine.LFD.2.00.0811301123320.24125@nehalem.linux-foundation.org>
 <1228074124.24749.26.camel@lappy.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 30 Nov 2008, Peter Zijlstra wrote:
> 
> Please consider the idea of lockless vma lookup and synchronizing
> against the PTE lock.
> 
> If that primary idea seems feasible, I'll continue working on it and try
> to tackle further obstacles.

I've not studied any of your details (you'll be relieved to know ;),
but this does seem to me like a very promising direction, and fun too!

It is consistent with the nature of faulting (go back and try it again
if any difficulty encountered, just don't take eternity), and the way
we already grab a snapshot of the pte, make decisions based upon that,
get the lock we need, then check pte_same().  I imagine you'll need
something like vma_same(), with a sequence count in the vma (perhaps
you already said as much).

Good luck with it!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
