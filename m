Message-ID: <413AE5DA.9070208@yahoo.com.au>
Date: Sun, 05 Sep 2004 20:09:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au> <20040904230939.03da8d2d.akpm@osdl.org> <20040905062743.GG7716@krispykreme>
In-Reply-To: <20040905062743.GG7716@krispykreme>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Anton Blanchard wrote:
>>There have been few reports, and I believe that networking is getting
>>changed to reduce the amount of GFP_ATOMIC higher-order allocation
>>attempts.
> 
> 
> FYI I seem to remember issues on loopback due to its large MTU. Also the

Yeah I had seen a few, surprisingly few though. Sorry I'm a bit clueless
about networking - I suppose there is a good reason for the 16K MTU? My
first thought might be that a 4K one could be better on CPU cache as well
as lighter on the mm. I know the networking guys know what they're doing
though...

> printk_ratelimit stuff first appeared because the e1000 was spewing so
> many higher order page allocation failures on some boxes.
> 
> But yes, the e1000 guys were going to look into multiple buffer mode so
> they dont need a high order allocation.
> 

Well let me be the first to say I don't want to stop that from happening.

With regard to getting this patchset tested, I might see if I can hunt
down another e1000 and give it a try at the end of the week. If anyone
would like to beat me to it, just let me know and I'll send out a new
set of patches with those couple of required fixes.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
