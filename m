Date: Sun, 1 Feb 2004 16:08:18 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: VM benchmarks
Message-Id: <20040201160818.1499be18.akpm@osdl.org>
In-Reply-To: <401D8D64.8010605@cyberone.com.au>
References: <401D8D64.8010605@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> After playing with the active / inactive list balancing a bit,
> I found I can very consistently take 2-3 seconds off a non
> swapping kbuild, and the light swapping case is closer to 2.4.
> Heavy swapping case is better again. Lost a bit in the middle
> though.
> 
> http://www.kerneltrap.org/~npiggin/vm/4/
> 
> At the end of this I might come up with something that is very
> suited to kbuild and no good at anything else. Do you have any
> other ideas of what I should test?
> 

The thing people most seem to complain about is big compilations.

Things like a bitkeeper consistency check while dinking with the X UI have
also been noted, but that's a bit hard to quantify.

Maybe ask Roger to try his efax workload?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
