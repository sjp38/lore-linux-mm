Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 381D26B0099
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:58 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so9891159pdj.13
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:58 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ci12si34068207pdb.255.2014.12.24.04.23.38
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/38] c6x: drop pte_file()
Date: Wed, 24 Dec 2014 14:22:23 +0200
Message-Id: <1419423766-114457-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <a-jacquiot@ti.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
---
 arch/c6x/include/asm/pgtable.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/c6x/include/asm/pgtable.h b/arch/c6x/include/asm/pgtable.h
index c0eed5b18860..78d4483ba40c 100644
--- a/arch/c6x/include/asm/pgtable.h
+++ b/arch/c6x/include/asm/pgtable.h
@@ -50,11 +50,6 @@ extern void paging_init(void);
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
