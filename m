Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CBE2B6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 10:17:09 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LYG00CZMQGJR1@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 27 Jan 2012 15:17:07 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYG001FEQGJVA@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Jan 2012 15:17:07 +0000 (GMT)
Date: Fri, 27 Jan 2012 16:17:03 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory
 Allocator
In-reply-to: 
 <CAK=WgbZWHBKNQwcoY9OiXXH-r1n3XxB=ZODZJN-3vZopU2yhJA@mail.gmail.com>
Message-id: <010501ccdd06$b9844f20$2c8ced60$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
 <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com>
 <CAO8GWqnQg-W=TEc+CUc8hs=GrdCa9XCCWcedQx34cqURhNwNwA@mail.gmail.com>
 <010301ccdd03$1ad15ab0$50741010$%szyprowski@samsung.com>
 <CAK=WgbZWHBKNQwcoY9OiXXH-r1n3XxB=ZODZJN-3vZopU2yhJA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Ohad Ben-Cohen' <ohad@wizery.com>
Cc: "'Clark, Rob'" <rob@ti.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hello,

On Friday, January 27, 2012 3:59 PM Ohad Ben-Cohen wrote:

> 2012/1/27 Marek Szyprowski <m.szyprowski@samsung.com>:
> > Ohad, could you tell a bit more about your issue?
> 
> Sure, feel free to ask.
> 
> > Does this 'large region'
> > is a device private region (declared with dma_declare_contiguous())
> 
> Yes, it is.
> 
> See omap_rproc_reserve_cma() in:
> 
> http://git.kernel.org/?p=linux/kernel/git/ohad/remoteproc.git;a=commitdiff;h=dab6a2584550a6297
> 46fa1dea2be8ffbe1910277

There have been some vmalloc layout changes merged to v3.3-rc1. Please check
if the hardcoded OMAP_RPROC_CMA_BASE+CONFIG_OMAP_DUCATI_CMA_SIZE fits into kernel
low-memory. Some hints you can find after the "Virtual kernel memory layout:" 
message during boot and using "cat /proc/iomem".

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
