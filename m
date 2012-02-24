Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 743546B00EF
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 08:24:09 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZW009GEFW76N@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Feb 2012 13:24:07 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZW00KE2FW79B@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Feb 2012 13:24:07 +0000 (GMT)
Date: Fri, 24 Feb 2012 14:24:04 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv6 3/7] ARM: dma-mapping: implement dma sg methods on top of
 any generic dma ops
In-reply-to: <20120214150255.GC18359@phenom.dumpdata.com>
Message-id: <013401ccf2f7$9413a0e0$bc3ae2a0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
 <1328900324-20946-4-git-send-email-m.szyprowski@samsung.com>
 <20120214150255.GC18359@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Tuesday, February 14, 2012 4:03 PM Konrad Rzeszutek Wilk wrote:
 
> On Fri, Feb 10, 2012 at 07:58:40PM +0100, Marek Szyprowski wrote:
> > This patch converts all dma_sg methods to be generic (independent of the
> > current DMA mapping implementation for ARM architecture). All dma sg
> > operations are now implemented on top of respective
> > dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.
> 
> Looks good, except the worry I've that the DMA debug API calls are now
> lost.

Could You point me which DMA debug API calls are lost? The inline functions
from include/asm-generic/dma-mapping-common.h already have all required
dma debug calls, which replaced the previous calls in 
arch/arm/include/dma-mapping.h.

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
