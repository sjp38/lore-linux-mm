Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98DA46B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:16:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d13so14860562pfn.21
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:16:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z2-v6si15601207plo.489.2018.04.24.22.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 22:16:01 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/13] iommu-helper: unexport iommu_area_alloc
Date: Wed, 25 Apr 2018 07:15:28 +0200
Message-Id: <20180425051539.1989-3-hch@lst.de>
In-Reply-To: <20180425051539.1989-1-hch@lst.de>
References: <20180425051539.1989-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

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
