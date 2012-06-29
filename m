Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 45BFD6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:00:56 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M6D008DJQT0EXA0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jun 2012 22:00:54 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M6D00NWGQT23S00@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 29 Jun 2012 22:00:54 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1339741135-7841-1-git-send-email-m.szyprowski@samsung.com>
 <4FED8D03.10507@ladisch.de>
In-reply-to: <4FED8D03.10507@ladisch.de>
Subject: RE: [PATCH] common: dma-mapping: add support for generic dma_mmap_*
 calls
Date: Fri, 29 Jun 2012 15:00:37 +0200
Message-id: <00a501cd55f7$323946f0$96abd4d0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Clemens Ladisch' <clemens@ladisch.de>
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'David Gibson' <david@gibson.dropbear.id.au>, 'Subash Patel' <subash.ramaswamy@linaro.org>, 'Sumit Semwal' <sumit.semwal@linaro.org>

Hi,

On Friday, June 29, 2012 1:10 PM Clemens Ladisch wrote:

> Marek Szyprowski wrote:
> > +++ b/drivers/base/dma-mapping.c
> > ...
> > +int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
> > +		    void *cpu_addr, dma_addr_t dma_addr, size_t size)
> > +{
> > +	int ret = -ENXIO;
> > +	...
> > +	if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
> > +		return ret;
> 
> This will return -ENXIO if dma_mmap_from_coherent() succeeds.
 
Thanks for spotting this! I will fix it in the next version of the patch.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
