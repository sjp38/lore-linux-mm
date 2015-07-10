Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 425809003C8
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:42:45 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so171645657pac.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:42:45 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ft7si15500959pdb.150.2015.07.10.10.42.30
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 10:42:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 23/36] tile, thp: remove infrastructure for handling splitting PMDs
Date: Fri, 10 Jul 2015 20:41:57 +0300
Message-Id: <1436550130-112636-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
