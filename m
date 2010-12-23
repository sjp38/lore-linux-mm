Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A1EB86B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 05:58:19 -0500 (EST)
Received: from epmmp1 (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTP id <0LDV00F0VNT5Y010@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 19:58:17 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0LDV00873NSXWU@mmp1.samsung.com> for linux-mm@kvack.org; Thu,
 23 Dec 2010 19:58:17 +0900 (KST)
Date: Thu, 23 Dec 2010 11:58:08 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <20101223100642.GD3636@n2100.arm.linux.org.uk>
Message-id: <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Kyungmin Park' <kmpark@infradead.org>
Cc: 'Michal Nazarewicz' <m.nazarewicz@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Thursday, December 23, 2010 11:07 AM Russell King - ARM Linux wrote:

> On Thu, Dec 23, 2010 at 06:30:57PM +0900, Kyungmin Park wrote:
> > Hi Andrew,
> >
> > any comments? what's the next step to merge it for 2.6.38 kernel. we
> > want to use this feature at mainline kernel.
> 
> Has anyone addressed my issue with it that this is wide-open for
> abuse by allocating large chunks of memory, and then remapping
> them in some way with different attributes, thereby violating the
> ARM architecture specification?

Actually this contiguous memory allocator is a better replacement for
alloc_pages() which is used by dma_alloc_coherent(). It is a generic
framework that is not tied only to ARM architecture.

> In other words, do we _actually_ have a use for this which doesn't
> involve doing something like allocating 32MB of memory from it,
> remapping it so that it's DMA coherent, and then performing DMA
> on the resulting buffer?

This is an arm specific problem, also related to dma_alloc_coherent()
allocator. To be 100% conformant with ARM specification we would
probably need to unmap all pages used by the dma_coherent allocator
from the LOW MEM area. This is doable, but completely not related
to the CMA and this patch series.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
