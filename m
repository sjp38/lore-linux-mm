Message-ID: <403D4303.1020709@cyberone.com.au>
Date: Thu, 26 Feb 2004 11:51:15 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More vm benchmarking
References: <403C66D2.6010302@cyberone.com.au>	<20040225014757.4c79f2af.akpm@osdl.org>	<403C7181.6050103@cyberone.com.au>	<20040225020425.2c409844.akpm@osdl.org> <20040225035043.6c536d99.akpm@osdl.org>
In-Reply-To: <20040225035043.6c536d99.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Andrew Morton <akpm@osdl.org> wrote:
>
>>I'll do the pgsteal_lo splitup.
>>
>
>OK, did that.   Running `make -j4 vmlinux' on the 2-way with mem=64m:
>
>Count how many pages were reclaimed from the various zones:
>
>					DMA	NORMAL	HIGH
>up to shrink_slab-for-all-zones:	3749	192580	0	(1:51)
>up to zone-balancing-fix:		5816	144545		(1:24)
>up to zone-balancing-batching:		21446	85209		(1:4)
>
>It should be 1:3, but it's tons better than it used to be.
>
>

Yeah I'm not sure if that is entirely true though. You would
expect ZONE_NORMAL to have more pages reclaimed from it
because there should be more pressure on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
