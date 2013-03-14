Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6B75C6B0075
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:23 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 06/30] thp, mm: basic defines for transparent huge page cache
Date: Thu, 14 Mar 2013 19:50:11 +0200
Message-Id: <1363283435-7666-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ee1c244..a54939c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -64,6 +64,10 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 #define HPAGE_PMD_MASK HPAGE_MASK
 #define HPAGE_PMD_SIZE HPAGE_SIZE
 
+#define HPAGE_CACHE_ORDER      (HPAGE_SHIFT - PAGE_CACHE_SHIFT)
+#define HPAGE_CACHE_NR         (1L << HPAGE_CACHE_ORDER)
+#define HPAGE_CACHE_INDEX_MASK (HPAGE_CACHE_NR - 1)
+
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 #define transparent_hugepage_enabled(__vma)				\
@@ -181,6 +185,10 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
+#define HPAGE_CACHE_ORDER      ({ BUILD_BUG(); 0; })
+#define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
+#define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
+
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
