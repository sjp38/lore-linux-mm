Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0F86B0389
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:39:34 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 89so8835154wrr.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:39:33 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id n132si6709673wmf.91.2017.02.09.08.39.32
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 08:39:33 -0800 (PST)
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 3/8] mm: cma: Export a few symbols
Date: Thu,  9 Feb 2017 17:39:17 +0100
Message-Id: <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
In-Reply-To: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Maxime Ripard <maxime.ripard@free-electrons.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Modules might want to check their CMA pool size and address for debugging
and / or have additional checks.

The obvious way to do this would be through dev_get_cma_area and
cma_get_base and cma_get_size, that are currently not exported, which
results in a build failure.

Export them to prevent such a failure.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/base/dma-contiguous.c | 1 +
 mm/cma.c                      | 2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index e167a1e1bccb..60f5c2591ccd 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -35,6 +35,7 @@
 #endif
 
 struct cma *dma_contiguous_default_area;
+EXPORT_SYMBOL(dma_contiguous_default_area);
 
 /*
  * Default global CMA area size can be defined in kernel's .config.
diff --git a/mm/cma.c b/mm/cma.c
index c960459eda7e..b50245282a18 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -47,11 +47,13 @@ phys_addr_t cma_get_base(const struct cma *cma)
 {
 	return PFN_PHYS(cma->base_pfn);
 }
+EXPORT_SYMBOL(cma_get_base);
 
 unsigned long cma_get_size(const struct cma *cma)
 {
 	return cma->count << PAGE_SHIFT;
 }
+EXPORT_SYMBOL(cma_get_size);
 
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 					     int align_order)
-- 
git-series 0.8.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
