Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDE56B0095
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:53 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so9879719pde.40
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:53 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ch4si34365547pdb.68.2014.12.24.04.23.33
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/38] asm-generic: drop unused pte_file* helpers
Date: Wed, 24 Dec 2014 14:22:16 +0200
Message-Id: <1419423766-114457-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>

All users are gone.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/asm-generic/pgtable.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 177d5973b132..129de9204d18 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -474,21 +474,6 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
 	return pte;
 }
-
-static inline pte_t pte_file_clear_soft_dirty(pte_t pte)
-{
-       return pte;
-}
-
-static inline pte_t pte_file_mksoft_dirty(pte_t pte)
-{
-       return pte;
-}
-
-static inline int pte_file_soft_dirty(pte_t pte)
-{
-       return 0;
-}
 #endif
 
 #ifndef __HAVE_PFNMAP_TRACKING
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
