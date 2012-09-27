Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 60D266B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:12:01 -0400 (EDT)
Date: Thu, 27 Sep 2012 15:11:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: CMA broken in next-20120926
Message-Id: <20120927151159.4427fc8f.akpm@linux-foundation.org>
In-Reply-To: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@avionic-design.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>Marek Szyprowski <m.szyprowski@samsung.com>Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Thu, 27 Sep 2012 13:29:11 +0200
Thierry Reding <thierry.reding@avionic-design.de> wrote:

> Hi Marek,
> 
> any idea why CMA might be broken in next-20120926. I see that there
> haven't been any major changes to CMA itself, but there's been quite a
> bit of restructuring of various memory allocation bits lately. I wasn't
> able to track the problem down, though.
> 
> What I see is this during boot (with CMA_DEBUG enabled):
> 
> [    0.266904] cma: dma_alloc_from_contiguous(cma db474f80, count 64, align 6)
> [    0.284469] cma: dma_alloc_from_contiguous(): memory range at c09d7000 is busy, retrying
> [    0.293648] cma: dma_alloc_from_contiguous(): memory range at c09d7800 is busy, retrying
> ...
> [    2.648619] DMA: failed to allocate 256 KiB pool for atomic coherent allocation
> ...
> [    4.196193] WARNING: at /home/thierry.reding/src/kernel/linux-ipmp.git/arch/arm/mm/dma-mapping.c:485 __alloc_from_pool+0xdc/0x110()
> [    4.207988] coherent pool not initialised!
> 
> So the pool isn't getting initialized properly because CMA can't get at
> the memory. Do you have any hints as to what might be going on? If it's
> any help, I started seeing this with next-20120926 and it is in today's
> next as well.
> 

Bart and Minchan have made recent changes to CMA.  Let us cc them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
