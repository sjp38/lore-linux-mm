Date: Sun, 21 Mar 2004 21:32:46 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
 fix
In-Reply-To: <20040322004652.GF3649@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0403212131100.20045-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rajesh Venkatasubramanian <vrajesh@umich.edu>, akpm@osdl.org, torvalds@osdl.org, hugh@veritas.com, mbligh@aracnet.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Mar 2004, Andrea Arcangeli wrote:

> It would be curious to test it after changing the return 1 to return 0
> in the page_referenced trylock failures?

In the case of a trylock failure, it should probably return a
random value.  For heavily page faulting multithreaded apps,
that would mean we'd tend towards random replacement, instead
of FIFO.

Then again, the locking problems shouldn't be too bad in most
cases.  If you're swapping the program will be waiting on IO
and if it's not waiting on IO there's no problem.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
