Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 006246B0298
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 10:18:40 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LSN00KHLEF1DI@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 06 Oct 2011 15:18:37 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSN003OGEF00M@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Oct 2011 15:18:37 +0100 (BST)
Date: Thu, 06 Oct 2011 16:18:36 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/7] ARM: integrate CMA with DMA-mapping subsystem
In-reply-to: <1317909290-29832-8-git-send-email-m.szyprowski@samsung.com>
Message-id: <000201cc8432$d642b930$82c82b90$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-8-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>

Hello,

On Thursday, October 06, 2011 3:55 PM Marek Szyprowski wrote:

> This patch adds support for CMA to dma-mapping subsystem for ARM
> architecture. By default a global CMA area is used, but specific devices
> are allowed to have their private memory areas if required (they can be
> created with dma_declare_contiguous() function during board
> initialization).
> 
> Contiguous memory areas reserved for DMA are remapped with 2-level page
> tables on boot. Once a buffer is requested, a low memory kernel mapping
> is updated to to match requested memory access type.
> 
> GFP_ATOMIC allocations are performed from special pool which is created
> early during boot. This way remapping page attributes is not needed on
> allocation time.
> 
> CMA has been enabled unconditionally for ARMv6+ systems.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Please ignore this patch. The patch named as "[PATCH 8/9] ARM: integrate
CMA with DMA-mapping subsystem" in this thread is the correct one.

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
