Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2F2146B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:53:57 -0500 (EST)
Received: by bkwq16 with SMTP id q16so138146bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:53:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329929337-16648-14-git-send-email-m.szyprowski@samsung.com>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com> <1329929337-16648-14-git-send-email-m.szyprowski@samsung.com>
From: Barry Song <21cnbao@gmail.com>
Date: Wed, 29 Feb 2012 17:53:35 +0800
Message-ID: <CAGsJ_4ygM6YAUj5mcskuEYcaJqYVHp_qzbUJvE9_huFhFcWtkg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 13/16] drivers: add Contiguous Memory Allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, DL-SHA-WorkGroupLinux <workgroup.linux@csr.com>

2012/2/23 Marek Szyprowski <m.szyprowski@samsung.com>:
> The Contiguous Memory Allocator is a set of helper functions for DMA
> mapping framework that improves allocations of contiguous memory chunks.
>
> CMA grabs memory on system boot, marks it with MIGRATE_CMA migrate type
> and gives back to the system. Kernel is allowed to allocate only movable
> pages within CMA's managed memory so that it can be used for example for
> page cache when DMA mapping do not use it. On
> dma_alloc_from_contiguous() request such pages are migrated out of CMA
> area to free required contiguous block and fulfill the request. This
> allows to allocate large contiguous chunks of memory at any time
> assuming that there is enough free memory available in the system.
>
> This code is heavily based on earlier works by Michal Nazarewicz.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
> Tested-by: Robert Nelson <robertcnelson@gmail.com>

if there is a /proc/cmainfo like /proc/slabinfo, it might be helpful
to people as we can see the usage of CMA clearly.

Thanks
barry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
