Message-ID: <401D95C2.3080208@cyberone.com.au>
Date: Mon, 02 Feb 2004 11:11:46 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: VM benchmarks
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org>
In-Reply-To: <20040201160818.1499be18.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>After playing with the active / inactive list balancing a bit,
>>I found I can very consistently take 2-3 seconds off a non
>>swapping kbuild, and the light swapping case is closer to 2.4.
>>Heavy swapping case is better again. Lost a bit in the middle
>>though.
>>
>>http://www.kerneltrap.org/~npiggin/vm/4/
>>
>>At the end of this I might come up with something that is very
>>suited to kbuild and no good at anything else. Do you have any
>>other ideas of what I should test?
>>
>>
>
>The thing people most seem to complain about is big compilations.
>
>Things like a bitkeeper consistency check while dinking with the X UI have
>also been noted, but that's a bit hard to quantify.
>
>Maybe ask Roger to try his efax workload?
>
>
>

efax is a compilation as well. I would be up for trying it, but it
needs quite a lot of GUI dev libraries installed to compile it.
I'll get onto it sometime I suppose, but for now I'll try to leave
my test box unchanged.

Unfortunately starting mozilla / kde / openoffice is another one
people complain about but harder to test...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
