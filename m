Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 761116B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 08:04:44 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9500MVGO6K8QB0@mailout1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Aug 2012 21:04:42 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M95002KKO7FAD90@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Aug 2012 21:04:42 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
In-reply-to: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
Subject: RE: [RFC 0/4] ARM: dma-mapping: IOMMU atomic allocation
Date: Wed, 22 Aug 2012 14:04:26 +0200
Message-id: <005901cd805e$4afd2e40$e0f78ac0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, 'Krishna Reddy' <vdumpa@nvidia.com>, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org

Hi Hiroshi,

On Wednesday, August 22, 2012 12:20 PM Hiroshi Doyu wrote:

> The commit e9da6e9 "ARM: dma-mapping: remove custom consistent dma
> region" breaks the compatibility with existing drivers. This causes
> the following kernel oops(*1). That driver has called dma_pool_alloc()
> to allocate memory from the interrupt context, and it hits
> BUG_ON(in_interrpt()) in "get_vm_area_caller()". This patch seris
> fixes this problem with making use of the pre-allocate atomic memory
> pool which DMA is using in the same way as DMA does now.
> 
> Any comment would be really appreciated.

I was working on the similar patches, but You were faster. ;-)

Basically the patch no 1 and 2 are fine, but I don't like the changes proposed in 
patch 3 and 4. You should not alter the attributes provided by the user nor make any
assumptions that such attributes has been provided - drivers are allowed to call 
dma_alloc_attrs() directly. Please rework your patches to avoid such approach.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
