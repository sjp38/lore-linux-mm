Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C94EF82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 08:26:21 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so29179854pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:26:21 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id sk2si2214293pac.33.2015.11.04.05.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 05:26:21 -0800 (PST)
Received: by pasz6 with SMTP id z6so54904042pas.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:26:20 -0800 (PST)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [PATCH v2] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Date: Wed,  4 Nov 2015 13:26:07 +0000
Message-Id: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
used any more. That is, no code refers to the definition.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
---
I've kept Acked-by from Christoph since there is no change in generic
percpu code between v1 and v2.

Changes since v1:
- Removed PERCPU_ENOUGH_ROOM from ia64

 arch/ia64/include/asm/percpu.h | 2 --
 include/linux/percpu.h         | 6 ------
 2 files changed, 8 deletions(-)

diff --git a/arch/ia64/include/asm/percpu.h b/arch/ia64/include/asm/percpu.h
index 0ec484d..b929579 100644
--- a/arch/ia64/include/asm/percpu.h
+++ b/arch/ia64/include/asm/percpu.h
@@ -6,8 +6,6 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#define PERCPU_ENOUGH_ROOM PERCPU_PAGE_SIZE
-
 #ifdef __ASSEMBLY__
 # define THIS_CPU(var)	(var)  /* use this to mark accesses to per-CPU variables... */
 #else /* !__ASSEMBLY__ */
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index caebf2a..4bc6daf 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -18,12 +18,6 @@
 #define PERCPU_MODULE_RESERVE		0
 #endif
 
-#ifndef PERCPU_ENOUGH_ROOM
-#define PERCPU_ENOUGH_ROOM						\
-	(ALIGN(__per_cpu_end - __per_cpu_start, SMP_CACHE_BYTES) +	\
-	 PERCPU_MODULE_RESERVE)
-#endif
-
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
