Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5E856B0273
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:58 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g63-v6so12629075pfc.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si22083995pgg.120.2018.11.14.00.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:23:57 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/34] powerpc/pseries: unwind dma_get_required_mask_pSeriesLP a bit
Date: Wed, 14 Nov 2018 09:22:50 +0100
Message-Id: <20181114082314.8965-11-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Call dma_get_required_mask_pSeriesLP directly instead of dma_iommu_ops
to simply the code a bit.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/pseries/iommu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/platforms/pseries/iommu.c b/arch/powerpc/platforms/pseries/iommu.c
index 06f02960b439..da5716de7f4c 100644
--- a/arch/powerpc/platforms/pseries/iommu.c
+++ b/arch/powerpc/platforms/pseries/iommu.c
@@ -1273,7 +1273,7 @@ static u64 dma_get_required_mask_pSeriesLP(struct device *dev)
 			return DMA_BIT_MASK(64);
 	}
 
-	return dma_iommu_ops.get_required_mask(dev);
+	return dma_iommu_get_required_mask(dev);
 }
 
 static int iommu_mem_notifier(struct notifier_block *nb, unsigned long action,
-- 
2.19.1
