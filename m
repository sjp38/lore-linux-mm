Message-ID: <3D3F521F.ECB4DBC4@zip.com.au>
Date: Wed, 24 Jul 2002 18:19:27 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] updated low-latency zap_page_range
References: <3D3F4A2F.B1A9F379@zip.com.au> <1027559785.17950.3.camel@sinai>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> 
> ...
> I hope it compiles to nothing!  There is a false in an if... oh, wait,
> to preserve possible side-effects gcc will keep the need_resched() call
> so I guess we should reorder it as:
> 
>         if (preempt_count() == 1 && need_resched())
> 
> Then we get "if (0 && ..)" which should hopefully be evaluated away.
> Then the inline is empty and nothing need be done.

I think someone changed the definition of preempt_count()
while you weren't looking.

Plus it's used as an lvalue :(

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
