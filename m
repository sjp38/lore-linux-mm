Date: Wed, 25 Feb 2004 03:50:43 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: More vm benchmarking
Message-Id: <20040225035043.6c536d99.akpm@osdl.org>
In-Reply-To: <20040225020425.2c409844.akpm@osdl.org>
References: <403C66D2.6010302@cyberone.com.au>
	<20040225014757.4c79f2af.akpm@osdl.org>
	<403C7181.6050103@cyberone.com.au>
	<20040225020425.2c409844.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: piggin@cyberone.com.au, linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> I'll do the pgsteal_lo splitup.

OK, did that.   Running `make -j4 vmlinux' on the 2-way with mem=64m:

Count how many pages were reclaimed from the various zones:

					DMA	NORMAL	HIGH
up to shrink_slab-for-all-zones:	3749	192580	0	(1:51)
up to zone-balancing-fix:		5816	144545		(1:24)
up to zone-balancing-batching:		21446	85209		(1:4)

It should be 1:3, but it's tons better than it used to be.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
