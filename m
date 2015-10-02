Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E747B82F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 01:40:50 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so96480056pab.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 22:40:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ev3si14252109pbc.67.2015.10.01.22.40.50
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 22:40:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] page-flags: add documentation for policies
Date: Fri,  2 Oct 2015 08:40:15 +0300
Message-Id: <1443764416-129688-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch adds description for page flags policies.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 465ca42af633..19e4129f00e5 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -133,7 +133,23 @@ enum pageflags {
 
 #ifndef __GENERATING_BOUNDS_H
 
-/* Page flags policies wrt compound pages */
+/*
+ * Page flags policies wrt compound pages
+ *
+ * PF_ANY:
+ *     the page flag is relevant for small, head and tail pages.
+ *
+ * PF_HEAD:
+ *     for compound page all operations related to the page flag applied to
+ *     head page.
+ *
+ * PF_NO_TAIL:
+ *     modifications of the page flag must be done on small or head pages,
+ *     checks can be done on tail pages too.
+ *
+ * PF_NO_COMPOUND:
+ *     the page flag is not relevant for compound pages.
+ */
 #define PF_ANY(page, enforce)	page
 #define PF_HEAD(page, enforce)	compound_head(page)
 #define PF_NO_TAIL(page, enforce) ({					\
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
