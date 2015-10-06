Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3B19882F68
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:25:18 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so89769412igb.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:25:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id m13si13610139igt.101.2015.10.06.08.25.17
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:25:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 23/37] tile, thp: remove infrastructure for handling splitting PMDs
Date: Tue,  6 Oct 2015 18:23:50 +0300
Message-Id: <1444145044-72349-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop
code to handle this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/tile/include/asm/pgtable.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 2b05ccbebed9..96cecf55522e 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -489,16 +489,6 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define has_transparent_hugepage() 1
 #define pmd_trans_huge pmd_huge_page
-
-static inline pmd_t pmd_mksplitting(pmd_t pmd)
-{
-	return pte_pmd(hv_pte_set_client2(pmd_pte(pmd)));
-}
-
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return hv_pte_get_client2(pmd_pte(pmd));
-}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /*
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
