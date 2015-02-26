Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1F56B0075
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:46 -0500 (EST)
Received: by padfb1 with SMTP id fb1so13330104pad.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:45 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fd2si716171pbc.110.2015.02.26.03.35.36
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 17/17] mm: do not add nr_pmds into mm_struct if PMD is folded
Date: Thu, 26 Feb 2015 13:35:20 +0200
Message-Id: <1424950520-90188-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

CONFIG_PGTABLE_LEVELS is now available on every architecture and we can
use it to check if we need to add nr_pmds into mm_struct.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 include/linux/mm_types.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03aab8dc..590630eb59ba 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -364,7 +364,9 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	atomic_long_t nr_ptes;			/* PTE page table pages */
+#if CONFIG_PGTABLE_LEVELS > 2
 	atomic_long_t nr_pmds;			/* PMD page table pages */
+#endif
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
