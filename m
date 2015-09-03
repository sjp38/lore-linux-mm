Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EE3686B0264
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:14:05 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so49520212pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:14:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q4si6730109pap.168.2015.09.03.08.13.54
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:13:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 23/36] tile, thp: remove infrastructure for handling splitting PMDs
Date: Thu,  3 Sep 2015 18:13:09 +0300
Message-Id: <1441293202-137314-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
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
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
