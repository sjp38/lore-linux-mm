Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF766B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:40 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id e65so176725414pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v86si47916903pfi.16.2016.01.19.06.25.39
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:39 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/8] radix-tree: Add an explicit include of bitops.h
Date: Tue, 19 Jan 2016 09:25:26 -0500
Message-Id: <1453213533-6040-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

The radix-tree header uses the __ffs() function, which is defined
in bitops.h.  The current kernel headers implicitly include bitops.h,
but the userspace test harness does not.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 7c88ad1..35b3d11 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -21,6 +21,7 @@
 #ifndef _LINUX_RADIX_TREE_H
 #define _LINUX_RADIX_TREE_H
 
+#include <linux/bitops.h>
 #include <linux/preempt.h>
 #include <linux/types.h>
 #include <linux/bug.h>
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
