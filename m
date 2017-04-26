Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F52E6B02EE
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 09:38:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o52so41181wrb.10
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 06:38:09 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id o9si7557940wma.137.2017.04.26.06.38.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 06:38:08 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
Date: Wed, 26 Apr 2017 16:35:49 +0300
Message-ID: <20170426133549.22603-2-igor.stoppa@huawei.com>
In-Reply-To: <20170426133549.22603-1-igor.stoppa@huawei.com>
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

The bitmasks used for ___GFP_xxx can be defined in terms of an enum,
which doesn't require manual updates to its values.

As bonus, __GFP_BITS_SHIFT is automatically kept consistent.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/gfp.h | 82 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 27 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0fe0b62..2f894c5 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -14,33 +14,62 @@ struct vm_area_struct;
  * include/trace/events/mmflags.h and tools/perf/builtin-kmem.c
  */
 
+enum gfp_bitmask_shift {
+	__GFP_DMA_SHIFT = 0,
+	__GFP_HIGHMEM_SHIFT,
+	__GFP_DMA32_SHIFT,
+	__GFP_MOVABLE_SHIFT,
+	__GFP_RECLAIMABLE_SHIFT,
+	__GFP_HIGH_SHIFT,
+	__GFP_IO_SHIFT,
+	__GFP_FS_SHIFT,
+	__GFP_COLD_SHIFT,
+	__GFP_NOWARN_SHIFT,
+	__GFP_REPEAT_SHIFT,
+	__GFP_NOFAIL_SHIFT,
+	__GFP_NORETRY_SHIFT,
+	__GFP_MEMALLOC_SHIFT,
+	__GFP_COMP_SHIFT,
+	__GFP_ZERO_SHIFT,
+	__GFP_NOMEMALLOC_SHIFT,
+	__GFP_HARDWALL_SHIFT,
+	__GFP_THISNODE_SHIFT,
+	__GFP_ATOMIC_SHIFT,
+	__GFP_ACCOUNT_SHIFT,
+	__GFP_NOTRACK_SHIFT,
+	__GFP_DIRECT_RECLAIM_SHIFT,
+	__GFP_WRITE_SHIFT,
+	__GFP_KSWAPD_RECLAIM_SHIFT,
+	__GFP_BITS_SHIFT
+};
+
+
 /* Plain integer GFP bitmasks. Do not use this directly. */
-#define ___GFP_DMA		0x01u
-#define ___GFP_HIGHMEM		0x02u
-#define ___GFP_DMA32		0x04u
-#define ___GFP_MOVABLE		0x08u
-#define ___GFP_RECLAIMABLE	0x10u
-#define ___GFP_HIGH		0x20u
-#define ___GFP_IO		0x40u
-#define ___GFP_FS		0x80u
-#define ___GFP_COLD		0x100u
-#define ___GFP_NOWARN		0x200u
-#define ___GFP_REPEAT		0x400u
-#define ___GFP_NOFAIL		0x800u
-#define ___GFP_NORETRY		0x1000u
-#define ___GFP_MEMALLOC		0x2000u
-#define ___GFP_COMP		0x4000u
-#define ___GFP_ZERO		0x8000u
-#define ___GFP_NOMEMALLOC	0x10000u
-#define ___GFP_HARDWALL		0x20000u
-#define ___GFP_THISNODE		0x40000u
-#define ___GFP_ATOMIC		0x80000u
-#define ___GFP_ACCOUNT		0x100000u
-#define ___GFP_NOTRACK		0x200000u
-#define ___GFP_DIRECT_RECLAIM	0x400000u
-#define ___GFP_WRITE		0x800000u
-#define ___GFP_KSWAPD_RECLAIM	0x1000000u
-/* If the above are modified, __GFP_BITS_SHIFT may need updating */
+#define ___GFP_DMA		(1u << __GFP_DMA_SHIFT)
+#define ___GFP_HIGHMEM		(1u << __GFP_HIGHMEM_SHIFT)
+#define ___GFP_DMA32		(1u << __GFP_DMA32_SHIFT)
+#define ___GFP_MOVABLE		(1u << __GFP_MOVABLE_SHIFT)
+#define ___GFP_RECLAIMABLE	(1u << __GFP_RECLAIMABLE_SHIFT)
+#define ___GFP_HIGH		(1u << __GFP_HIGH_SHIFT)
+#define ___GFP_IO		(1u << __GFP_IO_SHIFT)
+#define ___GFP_FS		(1u << __GFP_FS_SHIFT)
+#define ___GFP_COLD		(1u << __GFP_COLD_SHIFT)
+#define ___GFP_NOWARN		(1u << __GFP_NOWARN_SHIFT)
+#define ___GFP_REPEAT		(1u << __GFP_REPEAT_SHIFT)
+#define ___GFP_NOFAIL		(1u << __GFP_NOFAIL_SHIFT)
+#define ___GFP_NORETRY		(1u << __GFP_NORETRY_SHIFT)
+#define ___GFP_MEMALLOC		(1u << __GFP_MEMALLOC_SHIFT)
+#define ___GFP_COMP		(1u << __GFP_COMP_SHIFT)
+#define ___GFP_ZERO		(1u << __GFP_ZERO_SHIFT)
+#define ___GFP_NOMEMALLOC	(1u << __GFP_NOMEMALLOC_SHIFT)
+#define ___GFP_HARDWALL		(1u << __GFP_HARDWALL_SHIFT)
+#define ___GFP_THISNODE		(1u << __GFP_THISNODE_SHIFT)
+#define ___GFP_ATOMIC		(1u << __GFP_ATOMIC_SHIFT)
+#define ___GFP_ACCOUNT		(1u << __GFP_ACCOUNT_SHIFT)
+#define ___GFP_NOTRACK		(1u << __GFP_NOTRACK_SHIFT)
+#define ___GFP_DIRECT_RECLAIM	(1u << __GFP_DIRECT_RECLAIM_SHIFT)
+#define ___GFP_WRITE		(1u << __GFP_WRITE_SHIFT)
+#define ___GFP_KSWAPD_RECLAIM	(1u << __GFP_KSWAPD_RECLAIM_SHIFT)
 
 /*
  * Physical address zone modifiers (see linux/mmzone.h - low four bits)
@@ -180,7 +209,6 @@ struct vm_area_struct;
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT 25
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
