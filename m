Message-ID: <418AD20D.4000201@yahoo.com.au>
Date: Fri, 05 Nov 2004 12:06:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] higher order watermarks
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <20041104085745.GA7186@logos.cnet> <418A1EA6.70500@yahoo.com.au> <20041104095545.GA7902@logos.cnet>
In-Reply-To: <20041104095545.GA7902@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> Hi Nick!
> 
> On Thu, Nov 04, 2004 at 11:20:54PM +1100, Nick Piggin wrote:
> 

>>So now what we need to do in order to calculate, say the amount of memory
>>that will satisfy order-2 *and above* (this is important) is the following:
>>
>>	z->free_pages - (order[0].nr_free << 0) - (order[1].nr_free << 1)
> 
> 
> Shouldnt that be then
> 
> free_pages -= z->free_area[o].nr_free << o;
> 
> instead of the current 
> 
> free_pages -= z->free_area[order].nr_free << o;
> 
> No?
> 

Yes, you're absolutely right. Sorry, this is what you were getting
at all along :P

> 
>>to find order-3 and above, you also need to subtract (order[2].nr_free << 
>>2).
>>
>>I quite liked this method because it has progressively less cost on lower
>>order allocations, and for order-0 we don't need to do any calculation.
> 
> 
> OK, now I get it. The only think which bugs me is the multiplication of 
> values with different meanings.
> 

Yeah it's wrong, of course. Good catch, thanks.

If you would care to send a patch Marcelo? I don't have a recent
-mm on hand at the moment. Would that be alright?

Thanks,
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
