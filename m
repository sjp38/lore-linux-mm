Message-ID: <413AAF49.5070600@yahoo.com.au>
Date: Sun, 05 Sep 2004 16:16:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au> <20040904230210.03fe3c11.davem@davemloft.net>
In-Reply-To: <20040904230210.03fe3c11.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> On Sun, 05 Sep 2004 15:44:18 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>So my solution? Just teach kswapd and the watermark code about higher
>>order allocations in a fairly simple way. If pages_low is (say), 1024KB,
>>we now also require 512KB of order-1 and above pages, 256K of order-2
>>and up, 128K of order 3, etc. (perhaps we should stop at about order-3?)
> 
> 
> Whether to stop at order 3 is indeed an interesting question.
> 
> The reality is that the high-order allocations come mostly from folks
> using jumbo 9K MTUs on gigabit and faster technologies.  On x86, an
> order 2 would cover those packet allocations, but on sparc64 for example
> order 1 would be enough, whereas on a 2K PAGE_SIZE system order 3 would
> be necessary.
> 

Yeah I see.

> People using e1000 cards are hitting this case, and some of the e1000
> developers are going to play around with using page array based SKBs
> (via the existing SKB page frags mechanism).  So instead of allocating
> a huge linear chunk for RX packets, they'll allocate a header area of
> 256 bytes then an array of pages to cover the rest.
> 

Yes, I guess that would be ideal from the memory manager's POV.

> Right now, my current suggestion would not be to stop at a certain order.
> 

OK I'll keep it as is and we'll see how that goes. Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
