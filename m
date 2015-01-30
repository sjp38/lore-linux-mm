Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E2DE6828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:50 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so53127634pac.2
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id jj1si14112951pac.5.2015.01.30.06.43.41
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 19/19] mm: do not add nr_pmds into mm_struct if PMD is folded
Date: Fri, 30 Jan 2015 16:43:28 +0200
Message-Id: <1422629008-13689-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

CONFIG_PGTABLE_LEVELS is now available on every architecture and we can
use it to check if we need to add nr_pmds into mm_struct.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
