Date: Sun, 5 Sep 2004 16:27:43 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
Message-ID: <20040905062743.GG7716@krispykreme>
References: <413AA7B2.4000907@yahoo.com.au> <20040904230939.03da8d2d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040904230939.03da8d2d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> There have been few reports, and I believe that networking is getting
> changed to reduce the amount of GFP_ATOMIC higher-order allocation
> attempts.

FYI I seem to remember issues on loopback due to its large MTU. Also the
printk_ratelimit stuff first appeared because the e1000 was spewing so
many higher order page allocation failures on some boxes.

But yes, the e1000 guys were going to look into multiple buffer mode so
they dont need a high order allocation.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
