Date: Wed, 25 Feb 2004 02:04:25 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: More vm benchmarking
Message-Id: <20040225020425.2c409844.akpm@osdl.org>
In-Reply-To: <403C7181.6050103@cyberone.com.au>
References: <403C66D2.6010302@cyberone.com.au>
	<20040225014757.4c79f2af.akpm@osdl.org>
	<403C7181.6050103@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> >Dunno.  Maybe the workload prefers imbalanced zone scanning.
>  >
>  >
> 
>  Seriously? I find that a bit hard to swallow. Especially
>  considering I wouldn't have anything that uses ZONE_DMA
>  on this system.

Could be.  Suppose we have a bunch of really-hard-to-reclaim pages which
only get reclaimed when we're under extreme pressure.  The pages which get
placed there live longer than they should, thus avoiding later periods of
extreme pressure.   Sounds like crap, but it might be true ;)

I'll do the pgsteal_lo splitup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
