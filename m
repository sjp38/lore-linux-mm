Message-ID: <413C25F4.8030501@yahoo.com.au>
Date: Mon, 06 Sep 2004 18:55:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au>	<20040904230939.03da8d2d.akpm@osdl.org>	<20040905062743.GG7716@krispykreme>	<413AE5DA.9070208@yahoo.com.au> <20040905203331.7a2a2fad.davem@davemloft.net>
In-Reply-To: <20040905203331.7a2a2fad.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: anton@samba.org, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> On Sun, 05 Sep 2004 20:09:30 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Yeah I had seen a few, surprisingly few though. Sorry I'm a bit clueless
>>about networking - I suppose there is a good reason for the 16K MTU? My
>>first thought might be that a 4K one could be better on CPU cache as well
>>as lighter on the mm. I know the networking guys know what they're doing
>>though...
> 
> 
> It's better to get as long a stride as possible for the copy
> from userspace, and yes as you get larger you run into cache
> issues.  16K turned out the be the break point considering those
> two attributes when I did my testing.
> 

OK. Makes sense.

> Just fool around with ifconfig lo mtu XXX and TCP bandwidth tests.
> See what you come up with.
> 

Thanks, I'll give that a try. I don't nearly have access to a
representitive range of architectures, but if I see anything
interesting on what I've got, I'll ping you.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
