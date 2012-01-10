Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 15E536B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 03:42:44 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LXK00E44QV5DV@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 10 Jan 2012 08:42:41 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LXK003KOQV488@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Jan 2012 08:42:41 +0000 (GMT)
Date: Tue, 10 Jan 2012 09:42:37 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 0/8 v4] ARM: DMA-mapping framework redesign
In-reply-to: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <012601cccf73$ce09a8f0$6a1cfad0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Kukjin Kim' <kgene.kim@samsung.com>'KyongHo Cho' <pullip.cho@samsung.com>

Hello,

To help everyone in testing and adapting our patches for his hardware 
platform I've rebased our patches onto the latest v3.2 Linux kernel and
prepared a few GIT branches in our public repository. These branches
contain our memory management related patches posted in the following
threads:

"[PATCHv18 0/11] Contiguous Memory Allocator":
http://www.spinics.net/lists/linux-mm/msg28125.html
later called CMAv18,

"[PATCH 00/14] DMA-mapping framework redesign preparation":
http://www.spinics.net/lists/linux-sh/msg09777.html
and
"[PATCH 0/8 v4] ARM: DMA-mapping framework redesign":
http://www.spinics.net/lists/arm-kernel/msg151147.html
with the following update:
http://www.spinics.net/lists/arm-kernel/msg154889.html
later called DMAv5.

These branches are available in our public GIT repository:

git://git.infradead.org/users/kmpark/linux-samsung
http://git.infradead.org/users/kmpark/linux-samsung/

The following branches are available:

1) 3.2-cma-v18
Vanilla Linux v3.2 with fixed CMA v18 patches (first patch replaced
with the one from v17 to fix SMP issues, see the respective thread).

2) 3.2-dma-v5
Vanilla Linux v3.2 + iommu/next (IOMMU maintainer's patches) branch
with DMA-preparation and DMA-mapping framework redesign patches.

3) 3.2-cma-v18-dma-v5
Previous two branches merged together (DMA-mapping on top of CMA)

4) 3.2-cma-v18-dma-v5-exynos
Previous branch rebased on top of iommu/next + kgene/for-next (Samsung
SoC platform maintainer's patches) with new Exynos4 IOMMU driver by 
KyongHo Cho and relevant glue code.

5) 3.2-dma-v5-exynos
Branch from point 2 rebased on top of iommu/next + kgene/for-next 
(Samsung SoC maintainer's patches) with new Exynos4 IOMMU driver by 
KyongHo Cho and relevant glue code.

I hope everyone will find a branch that suits his needs. :)

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
