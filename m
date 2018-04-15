Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D79E76B000C
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:00:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x184so7874149pfd.14
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 08:00:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i127si8020430pgc.568.2018.04.15.08.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 08:00:06 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/12] iommu-helper: unexport iommu_area_alloc
Date: Sun, 15 Apr 2018 16:59:37 +0200
Message-Id: <20180415145947.1248-3-hch@lst.de>
In-Reply-To: <20180415145947.1248-1-hch@lst.de>
References: <20180415145947.1248-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This function is only used by built-in code.

Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 lib/iommu-helper.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
index 23633c0fda4a..ded1703e7e64 100644
--- a/lib/iommu-helper.c
+++ b/lib/iommu-helper.c
@@ -3,7 +3,6 @@
  * IOMMU helper functions for the free area management
  */
 
-#include <linux/export.h>
 #include <linux/bitmap.h>
 #include <linux/bug.h>
 
@@ -38,4 +37,3 @@ unsigned long iommu_area_alloc(unsigned long *map, unsigned long size,
 	}
 	return -1;
 }
-EXPORT_SYMBOL(iommu_area_alloc);
-- 
2.17.0
