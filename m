Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 794596B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:29:46 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id q63so6196304pfb.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 21:29:46 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id rx5si2546441pab.151.2016.02.09.21.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 21:29:45 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] mm,thp: fix spellos in describing __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
Date: Wed, 10 Feb 2016 10:59:23 +0530
Message-ID: <1455082163-11588-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-snps-arc@lists.infradead.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/pgtable-generic.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 1ba58213ad65..75664ed7e3ab 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -90,9 +90,9 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
  * ARCHes with special requirements for evicting THP backing TLB entries can
  * implement this. Otherwise also, it can help optimize normal TLB flush in
  * THP regime. stock flush_tlb_range() typically has optimization to nuke the
- * entire TLB TLB if flush span is greater than a threshhold, which will
+ * entire TLB if flush span is greater than a threshhold, which will
  * likely be true for a single huge page. Thus a single thp flush will
- * invalidate the entire TLB which is not desitable.
+ * invalidate the entire TLB which is not desirable.
  * e.g. see arch/arc: flush_pmd_tlb_range
  */
 #define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
