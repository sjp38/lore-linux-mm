Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AE7CA6B0078
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:23 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10016013pab.28
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id mm8si17586481pbc.198.2014.12.24.04.23.07
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 14/38] blackfin: drop pte_file()
Date: Wed, 24 Dec 2014 14:22:22 +0200
Message-Id: <1419423766-114457-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steven Miao <realmz6@gmail.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Steven Miao <realmz6@gmail.com>
---
 arch/blackfin/include/asm/pgtable.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/blackfin/include/asm/pgtable.h b/arch/blackfin/include/asm/pgtable.h
index 0b049019eba7..b88a1558b0b9 100644
--- a/arch/blackfin/include/asm/pgtable.h
+++ b/arch/blackfin/include/asm/pgtable.h
@@ -45,11 +45,6 @@ extern void paging_init(void);
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-static inline int pte_file(pte_t pte)
-{
-	return 0;
-}
-
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
 #define set_pte_at(mm, addr, ptep, pteval) set_pte(ptep, pteval)
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
