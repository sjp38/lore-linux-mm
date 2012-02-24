Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2FE7F6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 10:30:22 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZW00E9TLQKPO00@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Feb 2012 15:30:20 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZW00C0WLQJQZ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Feb 2012 15:30:20 +0000 (GMT)
Date: Fri, 24 Feb 2012 16:30:16 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv6 7/7] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <201202241431.02170.arnd@arndb.de>
Message-id: <017701ccf309$357d6f90$a0784eb0$%szyprowski@samsung.com>
Content-language: pl
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
 <201202241249.44731.arnd@arndb.de>
 <013301ccf2f6$bc4ad840$34e088c0$%szyprowski@samsung.com>
 <201202241431.02170.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: 'Krishna Reddy' <vdumpa@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>

Hello,

On Friday, February 24, 2012 3:31 PM Arnd Bergmann wrote:

> On Friday 24 February 2012, Marek Szyprowski wrote:
> > I want to use some kind of chained arrays, each of at most of PAGE_SIZE. This code
> > doesn't really need to keep these page pointers in contiguous virtual memory area, so
> > it will not be a problem here.
> >
> Sounds like sg_alloc_table(), could you reuse that instead of rolling your own?

I only need to store 'struct page *' there. sg_alloc_table() operates on 'struct statterlist'
entries, which are 4 to 6 times larger than a simple 'struct page *' entry. I don't want to waste
so much memory just for reusing a two function. Implementing the same idea with pure 
'struct page *' pointers will be just a matter of a few lines.

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
