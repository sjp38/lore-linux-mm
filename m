Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB33F6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:58:09 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w22so1384015pge.10
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:58:09 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g188si1079666pgc.386.2017.12.13.02.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 02:58:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 02/12] arc: Use generic_pmdp_establish as pmdp_establish
Date: Wed, 13 Dec 2017 13:57:46 +0300
Message-Id: <20171213105756.69879-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>

ARC doesn't support hardware dirty/accessed bits.
generic_pmdp_establish() is suitable in this case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/hugepage.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arc/include/asm/hugepage.h b/arch/arc/include/asm/hugepage.h
index b18fcb606908..dc8ee011882f 100644
--- a/arch/arc/include/asm/hugepage.h
+++ b/arch/arc/include/asm/hugepage.h
@@ -74,4 +74,7 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 extern void flush_pmd_tlb_range(struct vm_area_struct *vma, unsigned long start,
 				unsigned long end);
 
+/* We don't have hardware dirty/accessed bits, generic_pmdp_establish is fine.*/
+#define pmdp_establish generic_pmdp_establish
+
 #endif
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
