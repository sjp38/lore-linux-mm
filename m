Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E892D90012A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 07:51:17 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/8 RESEND] drivers: add Contiguous Memory Allocator
Date: Tue, 5 Jul 2011 13:50:10 +0200
References: <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com> <1309863722-6370-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1309863722-6370-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201107051350.11150.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tuesday 05 July 2011, Marek Szyprowski wrote:
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

Reviewed-by: Arnd Bergmann <arnd@arndb.de>, but I noticed two
one-character mistakes:

> +if CMA
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages (DEVELOPEMENT)"

s/DEVELOPEMENT/DEVELOPMENT/

> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 4c5701c..be6aab4 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -5,6 +5,7 @@ obj-y			:= core.o sys.o bus.o dd.o syscore.o \
>  			   cpu.o firmware.o init.o map.o devres.o \
>  			   attribute_container.o transport_class.o
>  obj-$(CONFIG_DEVTMPFS)	+= devtmpfs.o
> +obj-$(CONFIG_CMA) += dma-contiguous.o
>  obj-y			+= power/
>  obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o

Please add another tab to indent the line in the same way as the others.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
