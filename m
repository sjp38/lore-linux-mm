Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D86BA6B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 12:51:41 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9H0008D5HYQ9G0@mailout1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Aug 2012 01:51:40 +0900 (KST)
Received: from [106.210.21.42] by mmp1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTPA id <0M9H00IPX5H28Z30@mmp1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Aug 2012 01:51:40 +0900 (KST)
Message-id: <503CF6F4.7060702@samsung.com>
Date: Tue, 28 Aug 2012 18:51:00 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [v4 0/4] ARM: dma-mapping: IOMMU atomic allocation
References: <1346130784-23571-1-git-send-email-hdoyu@nvidia.com>
In-reply-to: <1346130784-23571-1-git-send-email-hdoyu@nvidia.com>
Content-type: text/plain; charset=ISO-8859-2; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

Hello,

On 8/28/2012 7:13 AM, Hiroshi Doyu wrote:
> The commit e9da6e9 "ARM: dma-mapping: remove custom consistent dma
> region" breaks the compatibility with existing drivers. This causes
> the following kernel oops(*1). That driver has called dma_pool_alloc()
> to allocate memory from the interrupt context, and it hits
> BUG_ON(in_interrpt()) in "get_vm_area_caller()". This patch seris
> fixes this problem with making use of the pre-allocate atomic memory
> pool which DMA is using in the same way as DMA does now.
>
> Any comment would be really appreciated.

Looks fine now. I will do some tests and apply them to my fixes-for-3.6
branch. Thanks for Your contribution!

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
