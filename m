Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0471582963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:16:50 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so9328349ier.26
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:16:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id is5si168321pbb.87.2014.05.06.07.16.49
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:16:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: update comment for DEFAULT_MAX_MAP_COUNT
Date: Tue,  6 May 2014 17:16:22 +0300
Message-Id: <1399385782-14081-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With ELF extended numbering 16-bit bound is not hard limit any more.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/sched/sysctl.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index 8045a554cafb..552a2db8b1f5 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -25,6 +25,10 @@ enum { sysctl_hung_task_timeout_secs = 0 };
  * Because the kernel adds some informative sections to a image of program at
  * generating coredump, we need some margin. The number of extra sections is
  * 1-3 now and depends on arch. We use "5" as safe margin, here.
+ *
+ * ELF extended numbering allows more then 65535 sections, so 16-bit bound is
+ * not hard limit any more. Although some userspace tools can be surprised by
+ * that.
  */
 #define MAPCOUNT_ELF_CORE_MARGIN	(5)
 #define DEFAULT_MAX_MAP_COUNT	(USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
