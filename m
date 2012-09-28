Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8C8176B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 01:40:12 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:43:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928054330.GA27594@bbox>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120927151159.4427fc8f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Mel Gorman <mgorman@suse.de>

On Thu, Sep 27, 2012 at 03:11:59PM -0700, Andrew Morton wrote:
> On Thu, 27 Sep 2012 13:29:11 +0200
> Thierry Reding <thierry.reding@avionic-design.de> wrote:
> 
> > Hi Marek,
> > 
> > any idea why CMA might be broken in next-20120926. I see that there
> > haven't been any major changes to CMA itself, but there's been quite a
> > bit of restructuring of various memory allocation bits lately. I wasn't
> > able to track the problem down, though.
> > 
> > What I see is this during boot (with CMA_DEBUG enabled):
> > 
> > [    0.266904] cma: dma_alloc_from_contiguous(cma db474f80, count 64, align 6)
> > [    0.284469] cma: dma_alloc_from_contiguous(): memory range at c09d7000 is busy, retrying
> > [    0.293648] cma: dma_alloc_from_contiguous(): memory range at c09d7800 is busy, retrying
> > ...
> > [    2.648619] DMA: failed to allocate 256 KiB pool for atomic coherent allocation
> > ...
> > [    4.196193] WARNING: at /home/thierry.reding/src/kernel/linux-ipmp.git/arch/arm/mm/dma-mapping.c:485 __alloc_from_pool+0xdc/0x110()
> > [    4.207988] coherent pool not initialised!
> > 
> > So the pool isn't getting initialized properly because CMA can't get at
> > the memory. Do you have any hints as to what might be going on? If it's
> > any help, I started seeing this with next-20120926 and it is in today's
> > next as well.
> > 
> 
> Bart and Minchan have made recent changes to CMA.  Let us cc them.

Hi all,

I have no time now so I look over the problem during short time
so I mighte be wrong. Even I should leave the office soon and
Korea will have long vacation from now on so I will be off by next week.
So it's hard to reach on me.

I hope this patch fixes the bug. If this patch fixes the problem
but has some problem about description or someone has better idea,
feel free to modify and resend to akpm, Please.

Thierry, Could you test below patch?
