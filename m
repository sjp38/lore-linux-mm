Message-ID: <4303EBC2.4030603@yahoo.com.au>
Date: Thu, 18 Aug 2005 12:00:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: pagefault scalability patches
References: <20050817151723.48c948c7.akpm@osdl.org>
In-Reply-To: <20050817151723.48c948c7.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>These are getting in the way now, and I need to make a go/no-go decision.
>
>I have vague feelings of ickiness with the patches wrt:
>
>a) general increase of complexity
>
>b) the fact that they only partially address the problem: anonymous page
>   faults are addressed, but lots of other places aren't.
>
>c) the fact that they address one particular part of one particular
>   workload on exceedingly rare machines.
>
>I believe that Nick has plans to address b).
>
>I'd like us to thrash this out (again), please.  Hugh, could you (for the
>nth and final time) describe your concerns with these patches?
>
>

That's true I do have a more general API that gives a bit more
flexibility in the arch implementation, and allows complete removal
of ptl...

I'd like to get time to finish that up and get it working on ppc64
and see it in the kernel, however it is very intrusive (eg. does
things like remove ptl from around mmu gather operations).

Basically it is going to take a long time to get everyone on side
even if the patch was 100% ready today (which it isn't).

If the big ticket item is taking the ptl out of the anonymous fault
path, then we probably should forget my stuff and consider Christoph's
on its own merits.

FWIW, I don't think it is an unreasonable approach to solving the
problem at hand in a fairly unintrusive manner.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
