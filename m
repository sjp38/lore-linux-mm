Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 809BC6B0266
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k1so2231468pgq.2
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:22 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:21 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 02/10] radix tree test suite: remove ARRAY_SIZE to avoid redefinition
Date: Wed, 29 Nov 2017 21:55:18 +0800
Message-Id: <1511963726-34070-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

ARRAY_SIZE() has been defined in include/linux/kernel.h, and "make"
complains a warning of redefinition of ARRAY_SIZE() in
testing/radix/linux/kernel.h. So, remove ARRAY_SIZE() from there.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 tools/testing/radix-tree/linux/kernel.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index c3bc3f3..426f32f 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -17,6 +17,4 @@
 #define pr_debug printk
 #define pr_cont printk
 
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
 #endif /* _KERNEL_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
