Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4E26B0022
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:04:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k9so4745382pgo.15
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:04:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a17-v6si12582106plm.151.2018.04.23.10.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Apr 2018 10:04:44 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/12] iommu-helper: unexport iommu_area_alloc
Date: Mon, 23 Apr 2018 19:04:09 +0200
Message-Id: <20180423170419.20330-3-hch@lst.de>
In-Reply-To: <20180423170419.20330-1-hch@lst.de>
References: <20180423170419.20330-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This function is only used by built-in code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
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
