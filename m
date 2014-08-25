Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACA06B0044
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 21:25:14 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so18983321pde.23
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 18:25:14 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id va2si50785721pbc.204.2014.08.24.18.25.12
        for <linux-mm@kvack.org>;
        Sun, 24 Aug 2014 18:25:13 -0700 (PDT)
Date: Mon, 25 Aug 2014 10:26:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Message-ID: <20140825012600.GN17372@bbox>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> Russell King recently noticed that limiting default CMA region only to
> low memory on ARM architecture causes serious memory management issues
> with machines having a lot of memory (which is mainly available as high
> memory). More information can be found the following thread:
> http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
> 
> Those two patches removes this limit letting kernel to put default CMA
> region into high memory when this is possible (there is enough high
> memory available and architecture specific DMA limit fits).

Agreed. It should be from the beginning because CMA page is effectly
pinned if it is anonymous page and system has no swap.

> 
> This should solve strange OOM issues on systems with lots of RAM
> (i.e. >1GiB) and large (>256M) CMA area.

I totally agree with the patchset although I didn't review code
at all.

Another topic:
It means it should be a problem still if system has CMA in lowmem
by some reason(ex, hardware limit or other purpose of CMA
rather than DMA subsystem)?

In that case, an idea that just popped in my head is to migrate
pages from cma area to highest zone because they are all
userspace pages which should be in there but not sure it's worth
to implement at this point because how many such cripple platform
are.

Just for the recording.

> 
> Best regards
> Marek Szyprowski
> Samsung R&D Institute Poland
> 
> 
> Marek Szyprowski (2):
>   mm: cma: adjust address limit to avoid hitting low/high memory
>     boundary
>   ARM: mm: don't limit default CMA region only to low memory
> 
>  arch/arm/mm/init.c |  2 +-
>  mm/cma.c           | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+), 1 deletion(-)
> 
> -- 
> 1.9.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
