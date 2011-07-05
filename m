Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D2FC900122
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 06:25:36 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LNU009MFVMJ9W00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Jul 2011 11:25:31 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNU00GI8VMHEB@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Jul 2011 11:25:30 +0100 (BST)
Date: Tue, 05 Jul 2011 12:24:58 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 6/8] drivers: add Contiguous Memory Allocator
In-reply-to: <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com>
Message-id: <000101cc3afd$cac46ff0$604d4fd0$%szyprowski@samsung.com>
Content-language: pl
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Tuesday, July 05, 2011 9:42 AM Marek Szyprowski wrote:

> The Contiguous Memory Allocator is a set of helper functions for DMA
> mapping framework that improves allocations of contiguous memory chunks.
> 
> CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
> gives back to the system. Kernel is allowed to allocate movable pages
> within CMA's managed memory so that it can be used for example for page
> cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
> request such pages are migrated out of CMA area to free required
> contiguous block and fulfill the request. This allows to allocate large
> contiguous chunks of memory at any time assuming that there is enough
> free memory available in the system.
> 
> This code is heavily based on earlier works by Michal Nazarewicz.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> ---
>  drivers/base/Kconfig           |   77 +++++++++
>  drivers/base/Makefile          |    1 +
>  drivers/base/dma-contiguous.c  |  367
> ++++++++++++++++++++++++++++++++++++++++
>  include/linux/dma-contiguous.h |  104 +++++++++++
>  4 files changed, 549 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/base/dma-contiguous.c
>  create mode 100644 include/linux/dma-contiguous.h
> 
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index d57e8d0..95ae1a7 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -168,4 +168,81 @@ config SYS_HYPERVISOR
>  	bool
>  	default n
> 
> +config CMA
> +	bool "Contiguous Memory Allocator"
> +	depends HAVE_DMA_CONTIGUOUS && HAVE_MEMBLOCK

The above line should be obviously "depends on HAVE_DMA_CONTIGUOUS &&
HAVE_MEMBLOCK".
I'm sorry for posting broken version. 

(snipped)

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
