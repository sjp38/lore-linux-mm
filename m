Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 687CC6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 01:58:55 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9700M0F1X9MHQ0@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Aug 2012 14:58:53 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9700LB31XOHH20@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 23 Aug 2012 14:58:53 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
 <1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
 <CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
 <20120822.163648.3800987367886904.hdoyu@nvidia.com>
In-reply-to: <20120822.163648.3800987367886904.hdoyu@nvidia.com>
Subject: RE: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with
 GFP_ATOMIC
Date: Thu, 23 Aug 2012 07:58:34 +0200
Message-id: <012401cd80f4$59727020$0c575060$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>, pullip.cho@samsung.com
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, 'Krishna Reddy' <vdumpa@nvidia.com>, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org

Hello,

On Wednesday, August 22, 2012 3:37 PM Hiroshi Doyu wrote:

> KyongHo Cho <pullip.cho@samsung.com> wrote @ Wed, 22 Aug 2012 14:47:00 +0200:
> 
> > vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic context.
> 
> Right.
> 
> I've been thinking that kzalloc() may be enough here, since
> vzalloc() was introduced to avoid allocation failure for big chunk of
> memory, but I think that it's unlikely that the number of page array
> can be so big. So I propose to drop vzalloc() here, and just simply to
> use kzalloc only as below(*1).

We already had a discussion about this, so I don't think it makes much sense to
change it back to kzalloc. This vmalloc() call won't hurt anyone. It should not
be considered a problem for atomic allocations, because no sane driver will try
to allocate buffers larger than a dozen KiB with GFP_ATOMIC flag. I would call
such try a serious bug, which we should not care here.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
