Date: Wed, 25 Feb 2004 01:47:57 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: More vm benchmarking
Message-Id: <20040225014757.4c79f2af.akpm@osdl.org>
In-Reply-To: <403C66D2.6010302@cyberone.com.au>
References: <403C66D2.6010302@cyberone.com.au>
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
> kernel | run | -j5 | -j10 | -j15 |
>  2.6.3    1     136   886    2511
>  2.6.3    2     150   838    2465
> 
>  -mm2     1     136   646    1484
>  -mm2     2     142   676    1265
> 
>  -mm3     1     135   881    1828
>  -mm3     2     146   790    1844
> 
>  This quite clearly shows your patches hurting as I told you.

Probably.  But these differences are small, relative to some differences
wrt 2.4.x

> Why did it get slower?

Dunno.  Maybe the workload prefers imbalanced zone scanning.

> I assume it is because the batching patch places uneven
>  pressure on normal and DMA zones.

The patch improves highmem-vs-lowmem balancing from 10:1 to 1:1.  What
makes you think that it worsens ZONE_NORMAL-vs-ZONE_DMA balancing?

It's easy enough to instrument - just split pgsteal_lo into pgsteal_normal
and pgsteal_dma.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
