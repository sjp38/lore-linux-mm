Message-ID: <413BC227.2070006@yahoo.com.au>
Date: Mon, 06 Sep 2004 11:49:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au> <Pine.LNX.4.58.0409050911450.2331@ppc970.osdl.org> <413BB55B.9000106@yahoo.com.au>
In-Reply-To: <413BB55B.9000106@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

>>
>> Notice how you may need to free 20% of memory to get a 2**3 
>> allocation, if you have totally depleted your pages. And it's much 
>> worse if you have very little memory to begin with.
>>
>> Anyway. I haven't debugged this program, so it may have serious bugs, 
>> and be off by an order of magnitude or two. Whatever. If I'm wrong, 
>> somebody can fix the program/script and see what the real numbers are.
>>
>>
>
> No, Andrew just recently reported that order-1 allocations were 
> needing to
> free 20MB or more (on systems with not really huge memories IIRC). So I
> think your program could be reasonably close to real life.
>
>

But yeah, that is when your memory is completely depleted. A small
modification to your program to make it just keep scanning until we've
freed a set amount of memory obviously shows that the more you've freed,
the easier it becomes to free higher order areas... In this way, having
kswapd batch up the freeing might possibly make it *more* efficient than
only freeing the single higher order area when we've absolutely run out
of areas (and simply failing !wait allocations altogether).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
